#!/usr/bin/env zsh
set -euo pipefail

setopt ALIASES
source ~/.zshrc.d/01-zalias.zsh

# Первый запуск: показываем список действий
if [ "$#" -eq 0 ]; then
  printf '%s\n' \
    "Lock" \
    "Suspend" \
    "Reboot" \
    "Shutdown"
  exit 0
fi

# Если пользователь выбрал подтверждение
if [[ "$1" == Confirm:* ]]; then
  action="${1#Confirm: }"

  case "$action" in
  Lock)
    swaylock
    ;;
  Suspend)
    echo "TODO"
    ;;
  Reboot)
    shutdown -r now
    ;;
  Shutdown)
    shutdown -h now
    ;;
  *)
    exit 0
    ;;
  esac

  exit 0
fi

# Если выбрано обычное действие — показываем подтверждение
if [[ "$1" == "Lock" || "$1" == "Suspend" || "$1" == "Reboot" || "$1" == "Shutdown" ]]; then
  printf '%s\n' "Confirm: $1" "Cancel"
  exit 0
fi

# Cancel или неизвестный пункт
exit 0
