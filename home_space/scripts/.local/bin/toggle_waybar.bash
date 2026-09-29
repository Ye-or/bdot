#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

# toggle-waybar.sh — запускает waybar с аргументами или завершает все экземпляры.
# Передаёт все параметры командной строки в waybar при запуске.

readonly WAYBAR_CMD="waybar"
declare -a PIDS=()

cmd_exists() {
  local cmd="${1:-}"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Ошибка: ${cmd} не найден в PATH" >&2
    exit 2
  fi
}

# Находит все процессы waybar текущего пользователя
find_processes() {
  local cmd="$1"
  local -n pids_ref="$2"

  if command -v pgrep >/dev/null 2>&1; then
    # Используем pgrep для надёжности
    if ! pgrep -u "$(id -u)" -x "${cmd}" >/dev/null 2>&1; then
      pids_ref=()
      return
    fi
    local -a pids
    mapfile -t pids < <(pgrep -u "$(id -u)" -x "${cmd}" 2>/dev/null)
    pids_ref=("${pids[@]}")
  else
    # Fallback: ps + grep
    while IFS= read -r pid; do
      [[ -n "$pid" ]] && pids_ref+=("$pid")
    done < <(ps -u "$(id -u)" -o pid= -o comm= 2>/dev/null |
      awk -v cmd="$cmd" '$2 == cmd {print $1}')
  fi
}

main() {
  cmd_exists "${WAYBAR_CMD}"
  find_processes "${WAYBAR_CMD}" PIDS

  if [[ "${#PIDS[@]}" -eq 0 ]]; then
    # Нет запущенных экземпляров — запускаем waybar
    "${WAYBAR_CMD}" "$@" >/dev/null 2>&1 &
    exit 0
  else
    # Есть запущенные экземпляры — корректно завершаем
    echo "Найдены экземпляры waybar: ${PIDS[*]}" >&2

    # SIGTERM
    kill "${PIDS[@]}" 2>/dev/null || true

    # Ждём graceful shutdown
    local timeout=5
    local interval=0.5
    local attempts=$((timeout * 2))
    local -a alive

    for ((i = 0; i < attempts; i++)); do
      alive=()
      for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
          alive+=("$pid")
        fi
      done

      [[ "${#alive[@]}" -eq 0 ]] && break
      sleep "$interval"
    done

    # SIGKILL для оставшихся
    if [[ "${#alive[@]}" -gt 0 ]]; then
      echo "Принудительное завершение: ${alive[*]}" >&2
      kill -9 "${alive[@]}" 2>/dev/null || true
    fi

    echo "Все экземпляры завершены." >&2
    exit 0
  fi
}

main "$@"
