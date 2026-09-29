#!/usr/bin/env bash

#~/dotfiles/
#├── deploy.sh          <-- ГЛАВНЫЙ СКРИПТ (запуск: sudo ./deploy.sh)
#├── deploy-user.sh     <-- Запускается внутри главного от обычного юзера
#├── deploy-system.sh   <-- Запускается внутри главного от root
#├── fish/
#├── nvim/
#└── swaylock/

# Строгая обработка ошибок
set -euo pipefail
IFS=$'\n\t'

# 1. Проверка прав: скрипт ДОЛЖЕН быть запущен через sudo
if [[ ${EUID} -ne 0 || -z "${SUDO_USER:-}" ]]; then
  echo -e "\033[0;31m[ОШИБКА] Этот скрипт должен запускаться через sudo: 'sudo $0'\033[0m" >&2
  exit 1
fi

# Определение директории дотфайлов и имени реального пользователя
readonly REAL_USER="$SUDO_USER"
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

log_title() {
  echo -e "\n\033[1;35m=== $1 ===\033[0m"
}

log_error() {
  echo -e "\033[0;31m[ОШИБКА] $1\033[0m" >&2
}

# --- ШАГ 1: Запуск пользовательского скрипта ---
log_title "1. Запуск пользовательской настройки (Stow)"

# Проверяем наличие дочернего скрипта
if [[ ! -f "./deploy-user.sh" ]]; then
  log_error "Файл deploy-user.sh не найден!"
  exit 1
fi

# Понижаем права до исходного пользователя для выполнения Stow в его $HOME
if ! sudo -u "$REAL_USER" ./deploy-user.sh; then
  log_error "Пользовательская настройка завершилась с ошибкой."
  exit 1
fi

# --- ШАГ 2: Запуск системного скрипта ---
log_title "2. Запуск системной настройки (/etc)"

# Проверяем наличие дочернего скрипта
if [[ ! -f "./deploy-system.sh" ]]; then
  log_error "Файл deploy-system.sh не найден!"
  exit 1
fi

# Выполняем напрямую от root, так как главный скрипт уже запущен через sudo
if ! ./deploy-system.sh; then
  log_error "Системная настройка завершилась с ошибкой."
  exit 1
fi

log_title "Все этапы развертывания успешно выполнены!"
