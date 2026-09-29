#!/usr/bin/env bash
# ==============================================================================
# PROJECT: Dotfiles Deployer
# FILE: pkginstaller.sh
# DESCRIPTION: Утилита для пакетной установки программ с контролем жизненно
#              важных звеньев (vital/non-vital).
# USAGE: ./pkginstaller.sh <install|dry-run> [options]
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
source "${SCRIPT_DIR}/.lib/logging.sh"

# Конфигурация (переопределяется через переменные окружения)
readonly INSTALLER="${INSTALLER:-xbps-install}"
readonly INSTALLER_OPT="${INSTALLER_OPT:--Su}"
readonly DRY_RUN_OPT="${DRY_RUN_OPT:---dry-run}"
readonly DIR_BATCHES_PKG="${DIR_BATCHES_PKG:-${SCRIPT_DIR}/pkglists.d}"

# Состояние приложения
ACTION=""
VERBOSE="false"
SKIP_NON_VITAL="false"

# ==============================================================================
# MODULE: pkg (Работа со списками пакетов и пакетным менеджером)
# ==============================================================================

# Получение отсортированного списка файлов списков пакетов
pkg::get_files() {
  local -n ref_files="$1"
  shopt -s nullglob
  ref_files=("${DIR_BATCHES_PKG}"/*.txt "${DIR_BATCHES_PKG}"/*.list)
  shopt -u nullglob

  if ((${#ref_files[@]} == 0)); then
    log_warn "В директории ${DIR_BATCHES_PKG} не найдено файлов *.txt или *.list"
    exit 0
  fi
}

# Чтение пакетов из конкретного файла (игнорирует комментарии и пустые строки)
pkg::read_file() {
  local file="$1"
  local -n ref_array="$2"

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    [[ "$line" =~ ^#.* || -z "$line" ]] && continue
    ref_array+=("$line")
  done <"$file"
}

# Проверка: является ли файл жизненно важным (vital)
pkg::is_vital() {
  [[ "$1" == *".vital."* ]]
}

# Сборка команды для пакетного менеджера
pkg::build_command() {
  local -n ref_cmd="$1"
  local mode="$2"
  local verbose="$3"
  shift 3
  local pkgs=("$@")

  ref_cmd=("${INSTALLER}")

  # Безопасная разбивка строк с опциями в массивы
  read -ra opt_array <<<"${INSTALLER_OPT}"
  ref_cmd+=("${opt_array[@]}")

  if [[ "$mode" == "dry-run" ]]; then
    read -ra dry_array <<<"${DRY_RUN_OPT}"
    ref_cmd+=("${dry_array[@]}")
  elif [[ "$mode" == "install" && "$verbose" == "true" ]]; then
    ref_cmd+=("-v")
  fi

  ref_cmd+=("${pkgs[@]}")
}

# Исполнение сформированной команды
pkg::run_command() {
  local -n ref_cmd="$1"
  log_info "Выполняется: ${ref_cmd[*]}"
  printf -- "----------------------------------------\n"

  # Выполняем в подпроцессе, чтобы set +e не сломал основной скрипт
  (
    set +e
    "${ref_cmd[@]}"
  )
}

# ==============================================================================
# MODULE: app (Управление жизненным циклом приложения и парсинг)
# ==============================================================================

# Вывод справки
app::show_help() {
  cat <<EOF
Использование: $(basename "$0") <команда> [опции]

Команды:
  install    Установка пакетов из списков последовательно.
  dry-run    Симуляция установки (показ списков пакетов к установке).

Опции для install:
  -v, --verbose          Подробный вывод процесса установки.
  -s, --skip-non-vital   Пропускать ошибки в некритичных (non-vital) звеньях.
  -h, --help             Показать эту справку.
EOF
}

# Парсинг аргументов командной строки
app::parse_arguments() {
  if (($# == 0)); then
    app::show_help
    exit 1
  fi

  ACTION="$1"
  shift

  case "$ACTION" in
  install)
    while (($# > 0)); do
      case "$1" in
      -v | --verbose) VERBOSE="true" ;;
      -s | --skip-non-vital) SKIP_NON_VITAL="true" ;;
      -h | --help)
        app::show_help
        exit 0
        ;;
      *) log_fatal "Неизвестный параметр для 'install': $1" ;;
      esac
      shift
    done
    ;;
  dry-run)
    while (($# > 0)); do
      case "$1" in
      -h | --help)
        app::show_help
        exit 0
        ;;
      *) log_fatal "Неизвестный параметр для 'dry-run': $1" ;;
      esac
      shift
    done
    ;;
  -h | --help)
    app::show_help
    exit 0
    ;;
  *) log_fatal "Неизвестная команда: ${ACTION}" ;;
  esac
}

# Обработка цепочки пакетов
app::process_chain() {
  local files=("$@")
  local failed_files=()
  local skipped_remaining="false"

  log_title "РЕЖИМ: ${ACTION^^}"

  for file in "${files[@]}"; do
    local filename
    filename=$(basename "$file")

    if [[ "$skipped_remaining" == "true" ]]; then
      log_warn "Шаг [${filename}] -> ПРОПУЩЕН (цепочка разорвана)"
      failed_files+=("${filename} (не запускался)")
      continue
    fi

    local is_vital="false"
    pkg::is_vital "$filename" && is_vital="true"

    local meta_info=""
    [[ "$is_vital" == "true" ]] && meta_info=" [VITAL]"

    printf "\n"
    log_info "Обработка звена:${meta_info} ${filename}"
    printf -- "----------------------------------------\n"

    local current_packages=()
    pkg::read_file "$file" current_packages

    if ((${#current_packages[@]} == 0)); then
      log_info "Файл ${filename} пуст. Пропускаем."
      continue
    fi

    local cmd=()
    pkg::build_command cmd "$ACTION" "$VERBOSE" "${current_packages[@]}"

    if ! pkg::run_command cmd; then
      log_error "Не удалось обработать звено ${filename}"
      failed_files+=("${filename} (ошибка, vital: ${is_vital})")

      if [[ "$ACTION" == "install" ]]; then
        if [[ "$SKIP_NON_VITAL" == "false" || "$is_vital" == "true" ]]; then
          log_error "Прерывание цепочки установки."
          skipped_remaining="true"
        fi
      fi
    else
      log_info "Успешно: Звено ${filename} обработано."
    fi
  done

  app::display_summary "${failed_files[@]}"
}

# Вывод итогов выполнения
app::display_summary() {
  local failed_files=("$@")
  printf "\n========================================\n"

  if ((${#failed_files[@]} == 0)); then
    log_info "Все звенья цепочки успешно обработаны!"
    exit 0
  else
    log_error "Были проблемы со следующими файлами:"
    for failed in "${failed_files[@]}"; do
      log_error "  - ${failed}"
    done
    [[ "$ACTION" == "install" ]] && exit 1
  fi
}

# Главная точка входа
main() {
  app::parse_arguments "$@"

  if [[ ! -d "$DIR_BATCHES_PKG" ]]; then
    log_fatal "Директория со списками пакетов не найдена: ${DIR_BATCHES_PKG}"
  fi

  local files=()
  pkg::get_files files
  app::process_chain "${files[@]}"
}

main "$@"
