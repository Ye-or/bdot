#!/usr/bin/env bash
# ==============================================================================
# PROJECT: Dotfiles Deployer
# FILE: deploy_user_space.sh
# DESCRIPTION: Управление пользовательскими конфигами в $HOME с помощью GNU Stow.
#              Запускается от имени обычного пользователя (не root).
# USAGE: ./deploy_user_space.sh [--stow | --delete | --restow] [--dry-run]
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'
umask 077

# Определяем пути и подключаем библиотеку
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
source "${SCRIPT_DIR}/.lib/logging.sh"

readonly DOTFILES_DIR="${DOTFILES_DIR:-${SCRIPT_DIR}/home_space}"
readonly HOME_DIR="${HOME:?Переменная HOME не задана}"

# Состояние скрипта
DRY_RUN=0
STOW_ACTION="--stow" # Действие по умолчанию
CLEAN_HOME=""
packages=()

# Обработчик ошибок (ERR trap)
on_error() {
  local exit_code=$?
  log_error "Команда завершилась с кодом ${exit_code}: ${BASH_COMMAND}"
}

# Очистка временных файлов (EXIT trap)
cleanup() {
  if [[ -n "${CLEAN_HOME:-}" && -d "$CLEAN_HOME" ]]; then
    rm -rf -- "$CLEAN_HOME"
  fi
}

# Разбор аргументов командной строки
parse_args() {
  while (($# > 0)); do
    case "$1" in
    --dry-run | -n) DRY_RUN=1 ;;
    --stow | -S) STOW_ACTION="--stow" ;;
    --delete | -D) STOW_ACTION="--delete" ;;
    --restow | -R) STOW_ACTION="--restow" ;;
    --help | -h)
      printf "Использование: %s [ДЕЙСТВИЕ] [--dry-run]\n\n" "$0"
      printf "Действия (может быть указано только одно):\n"
      printf "  -S, --stow    Установить пакеты (по умолчанию)\n"
      printf "  -D, --delete  Удалить (деинсталлировать) пакеты\n"
      printf "  -R, --restow  Переустановить пакеты (удалить и накатать заново)\n\n"
      printf "Опции:\n"
      printf "  -n, --dry-run Симуляция выполнения без внесения изменений\n"
      exit 0
      ;;
    *) log_fatal "Неизвестный аргумент: $1" ;;
    esac
    shift
  done
}

# Проверка окружения и зависимостей
check_env() {
  if ((EUID == 0)); then
    log_fatal "Этот скрипт нельзя запускать от root или через sudo."
  fi

  if [[ ! -d "$HOME_DIR" || ! -O "$HOME_DIR" ]]; then
    log_fatal "Домашний каталог не существует или не принадлежит пользователю: $HOME_DIR"
  fi

  if ! command -v stow >/dev/null 2>&1; then
    log_fatal "GNU Stow не найден в PATH. Установите его перед запуском."
  fi
}

# Сбор списка директорий-пакетов для Stow
collect_pkgs() {
  local pkg_path pkg_name
  packages=()
  shopt -s nullglob

  for pkg_path in "${DOTFILES_DIR}"/*; do
    # Пропускаем файлы, симлинки
    [[ -d "$pkg_path" && ! -L "$pkg_path" ]] || continue
    pkg_name="${pkg_path##*/}"

    packages+=("$pkg_name")
  done

  if ((${#packages[@]} == 0)); then
    log_info "Пакеты для обработки не найдены."
    exit 0
  fi
}

# Выполнение GNU Stow
run_stow() {
  local pkg

  # Создаем изолированный HOME для предотвращения конфликтов
  CLEAN_HOME="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-stow.XXXXXX")"

  # Перебираем каждый пакет отдельно, чтобы Stow читал локальный .stowrc пакета
  for pkg in "${packages[@]}"; do
    local -a stow_args=(
      --dir="${DOTFILES_DIR}"
      --target="${HOME_DIR}"
      "${STOW_ACTION}"
    )

    if ((DRY_RUN)); then
      stow_args+=(--simulate --verbose)
    fi

    log_info "Обработка пакета: ${pkg}"
    (
      # Заходим прямо в директорию пакета, чтобы Stow подцепил находящийся там .stowrc
      cd "${DOTFILES_DIR}/${pkg}"
      env HOME="${CLEAN_HOME}" \
        stow "${stow_args[@]}" "${pkg}"
    )
  done
}

# Главная точка входа
main() {
  trap 'on_error' ERR
  trap 'cleanup' EXIT

  parse_args "$@"
  check_env
  collect_pkgs

  log_title "Управление пользовательскими конфигами (GNU Stow)"
  log_info "Выбираемое действие: ${STOW_ACTION}"
  log_info "Каталог пакетов: ${DOTFILES_DIR}"
  log_info "Каталог назначения: ${HOME_DIR}"
  log_info "Пакеты: ${packages[*]}"

  run_stow

  if ((DRY_RUN)); then
    log_info "Предварительный просмотр (dry-run) завершён."
  else
    log_info "Все пакеты успешно обработаны (действие: ${STOW_ACTION})."
  fi
}

main "$@"
