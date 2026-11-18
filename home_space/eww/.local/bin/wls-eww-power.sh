#!/usr/bin/env bash

set -euo pipefail
## Files and cmd
#declare -r CFG="$HOME/.config/eww/power"

EWW=$(command -v eww) || {
  echo "Ошибка: eww не установлен в системе." >&2
  exit 1
}
readonly EWW

declare -r SV_EWW="eww"

declare -ra EWW_WIN=(
  "lock"
  "sleep"
  "reboot"
  "poweroff"
)
#declare -ra EWW_CFG=("--config" "$CFG")
declare -r EWW_OPEN="open-many"
declare -r EWW_CLOSE="close"

#---
command -v niri >/dev/null || {
  echo "Ошибка: niri не установлен в системе." >&2
  exit 1
}
command -v jq >/dev/null || {
  echo "Ошибка: jq не установлен в системе." >&2
  exit 1
}
ACTIVE_MONITOR=$(niri msg --json focused-output | jq -r '.model') || {
  echo "Ошибка: активный монитор не найден." >&2
  exit 1
}
readonly ACTIVE_MONITOR
#declare -ra EWW_AM=(
#  "--screen" "${ACTIVE_MONITOR}"
#)

#---
check_up_sv() {
  local service="$1"
  sv status "${service}" >/dev/null 2>&1
}

try_run_sv() {
  local service="$1"

  if sv start "${service}" >/dev/null; then
    echo "Сервис ${service} успешно запущен."
    sleep 0.3
  else
    echo "Ошибка: Не удалось запустить сервис ${service}!" >&2
    exit 1
  fi
}

check_active_windows() {
  local -n ref_win="$1"
  #old_IFS="$IFS"
  ### local "IFS" is safety
  local IFS="|"
  local search_str="${ref_win[*]}"
  #IFS="$old_IFS"

  "${EWW}" active-windows 2>/dev/null | grep -E -q "$search_str"
}

run_eww() {
  declare -a cmd_run=(
    "${EWW}"
  )
  if ! check_active_windows EWW_WIN; then
    #cmd_run+=("${EWW_AM[@]}")
    cmd_run+=("${EWW_OPEN}")
    cmd_run+=("${EWW_WIN[@]}")
    for win in "${EWW_WIN[@]}"; do
      cmd_run+=("--arg")
      cmd_run+=("${win}:screen=${ACTIVE_MONITOR}")
    done
  else
    cmd_run+=("${EWW_CLOSE}")
    cmd_run+=("${EWW_WIN[@]}")
  fi

  "${cmd_run[@]}"
}

main() {
  if ! check_up_sv "${SV_EWW}"; then
    try_run_sv "${SV_EWW}"
  fi
  run_eww
}

main "${@}"

## Open widgets
#run_eww() {
#  ${EWW} --config "$CFG" open-many \
#    background \
#    profile \
#    system \
#    clock \
#    uptime \
#    music \
#    github \
#    reddit \
#    twitter \
#    youtube \
#    weather \
#    apps \
#    mail \
#    logout \
#    sleep \
#    reboot \
#    poweroff \
#    folders
#}

## Launch or close widgets accordingly
#if [[ ! -f "$FILE" ]]; then
#  touch "$FILE"
#  run_eww
#else
#  ${EWW} --config "$CFG" close \
#    background profile system clock uptime music github \
#    reddit twitter youtube weather apps mail logout sleep reboot poweroff folders
#  rm "$FILE"
#fi
