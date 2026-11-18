#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_NAME=${0##*/}
readonly DEFAULT_TERMINAL=alacritty
readonly CLASS_TAIL=power-menu
readonly POWERCTL_NAME=powerctl
readonly SK_PROMPT_POWER="Power > "
readonly CONFIRM_CHOICES=$'No\nYes'

readonly -a SK_COMMON=(--no-multi --reverse)

readonly -a MENU_ITEMS=(
  $'\uf011 Shutdown\tpoweroff'
  $'\uf01e Reboot\treboot'
  $'\uf186 Suspend\tsuspend'
  $'\uf023 Lock\tlock'
  $'\uf08b Logout\tlogout'
)

declare -rA CONFIRM_TEXT=(
  [poweroff]="Shutdown the computer"
  [reboot]="Reboot the computer"
  [suspend]="Suspend the system"
  [logout]="Exit niri session"
)

die() {
  printf '%s: %s\n' "$SCRIPT_NAME" "$*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "not found: $1"
}

SELF=$(readlink -f -- "${BASH_SOURCE[0]}") || die "cannot resolve script path"
readonly SELF

init_terminal() {
  TERMINAL=${TERMINAL:-$DEFAULT_TERMINAL}
  read -r -a TERM_CMD <<<"$TERMINAL"
  TERM_NAME=${TERM_CMD[0]##*/}

  case "$TERM_NAME" in
  ghostty | alacritty)
    TERM_ARGS=(--class="${TERM_NAME}.${CLASS_TAIL}" -e)
    ;;
  foot)
    TERM_ARGS=(--app-id="${TERM_NAME}.${CLASS_TAIL}" -e)
    ;;
  kitty)
    TERM_ARGS=(--class="${TERM_NAME}.${CLASS_TAIL}" --)
    ;;
  wezterm)
    TERM_ARGS=(start --class="${TERM_NAME}.${CLASS_TAIL}" --)
    ;;
  *)
    TERM_ARGS=(-e)
    ;;
  esac
}

parse_args() {
  POPUP=0
  local arg
  for arg in "$@"; do
    [[ $arg == "--popup" ]] && POPUP=1
  done
}

resolve_powerctl() {
  POWERCTL="${SELF%/*}/$POWERCTL_NAME"
  if [[ ! -x $POWERCTL ]]; then
    POWERCTL=$(command -v "$POWERCTL_NAME") || die "$POWERCTL_NAME not found"
  fi
}

run() {
  if ! "$@"; then
    printf '\nFailed: %s\nPress any key...' "$*" >&2
    read -rn1 || true
    return 1
  fi
}

confirm() {
  local prompt="$1? > " answer
  answer=$(printf '%s\n' "$CONFIRM_CHOICES" |
    sk --prompt="$prompt" "${SK_COMMON[@]}") || return 1
  [[ $answer == "Yes" ]]
}

choose_action() {
  local choice
  choice=$(printf '%s\n' "${MENU_ITEMS[@]}" |
    sk --prompt="$SK_PROMPT_POWER" --delimiter=$'\t' --with-nth=1 "${SK_COMMON[@]}") || return 0
  [[ -n $choice ]] || return 0
  printf '%s\n' "${choice#*$'\t'}"
}

execute() {
  case "$1" in
  poweroff | reboot | suspend | lock)
    run "$POWERCTL" "$1"
    ;;
  logout)
    run niri msg action quit --skip-confirmation
    ;;
  *)
    die "unknown action: $1"
    ;;
  esac
}

main() {
  init_terminal
  parse_args "$@"

  if [[ ! -t 0 && $POPUP -eq 0 ]]; then
    need "${TERM_CMD[0]}"
    exec "${TERM_CMD[@]}" "${TERM_ARGS[@]}" "$SELF" --popup
  fi

  need sk
  resolve_powerctl

  local action prompt
  action=$(choose_action)
  [[ -n $action ]] || exit 0

  prompt=${CONFIRM_TEXT[$action]:-}
  if [[ -n $prompt ]]; then
    confirm "$prompt" || exit 0
  fi

  execute "$action"
}

main "$@"
