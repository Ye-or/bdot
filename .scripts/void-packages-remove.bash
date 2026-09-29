#!/usr/bin/env bash

set -Eeuo pipefail

readonly GROUP_NAME="voidbuild"
readonly INSTALL_DIR="/opt/void-packages"

error() {
  printf 'Ошибка: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

if [[ "${EUID}" -ne 0 ]]; then
  error "скрипт нужно запускать от root или через sudo"
fi

# Пользователь, от имени которого был вызван sudo.
# Если скрипт запущен непосредственно от root, пользователь передаётся аргументом.
TARGET_USER="${1:-${SUDO_USER:-}}"

if [[ -z "${TARGET_USER}" || "${TARGET_USER}" == "root" ]]; then
  error "не удалось определить обычного пользователя.

Запустите так:
  sudo $0

или из root-shell:
  $0 имя_пользователя"
fi

if ! id "${TARGET_USER}" &>/dev/null; then
  error "пользователь '${TARGET_USER}' не существует"
fi

if ! getent group "${GROUP_NAME}" >/dev/null; then
  warn "группа '${GROUP_NAME}' не существует"
else
  GROUP_EXISTS=1
fi

# Защита от случайного удаления другого пути.
if [[ -e "${INSTALL_DIR}" || -L "${INSTALL_DIR}" ]]; then
  if [[ -L "${INSTALL_DIR}" ]]; then
    error "${INSTALL_DIR} является символической ссылкой; удаление остановлено"
  fi

  if [[ ! -d "${INSTALL_DIR}" ]]; then
    error "${INSTALL_DIR} существует, но не является каталогом"
  fi

  # Не удаляем каталог, если на нём смонтирована отдельная файловая система.
  if command -v findmnt >/dev/null 2>&1 &&
    findmnt -T "${INSTALL_DIR}" -n -o TARGET |
    grep -qxF "${INSTALL_DIR}"; then
    error "на ${INSTALL_DIR} смонтирована файловая система; сначала размонтируйте её"
  fi

  printf 'Будет полностью удалён каталог:\n  %s\n' "${INSTALL_DIR}"
else
  info "каталог ${INSTALL_DIR} отсутствует"
fi

if [[ "${GROUP_EXISTS:-0}" -eq 1 ]]; then
  printf 'Пользователь будет удалён из группы:\n  %s -> %s\n' \
    "${TARGET_USER}" "${GROUP_NAME}"
fi

printf '\nДля продолжения введите точно: REMOVE\n'
read -r confirmation

if [[ "${confirmation}" != "REMOVE" ]]; then
  info "отмена"
  exit 0
fi

# Удалить дерево сборки, включая hostdir, masterdir и локальные пакеты.
if [[ -d "${INSTALL_DIR}" ]]; then
  info "удаление ${INSTALL_DIR}"
  rm -rf --one-file-system "${INSTALL_DIR}"
fi

# Удалить пользователя из группы.
if [[ "${GROUP_EXISTS:-0}" -eq 1 ]]; then
  if id -nG "${TARGET_USER}" |
    tr ' ' '\n' |
    grep -qxF "${GROUP_NAME}"; then

    info "удаление пользователя '${TARGET_USER}' из группы '${GROUP_NAME}'"
    gpasswd --delete "${TARGET_USER}" "${GROUP_NAME}" >/dev/null
  else
    info "пользователь '${TARGET_USER}' уже не состоит в группе '${GROUP_NAME}'"
  fi
fi

# Удалить группу только если она больше никому не нужна.
if getent group "${GROUP_NAME}" >/dev/null; then
  mapfile -t remaining_members < <(
    getent group "${GROUP_NAME}" |
      awk -F: '{print $4}' |
      tr ',' '\n' |
      sed '/^$/d'
  )

  if ((${#remaining_members[@]} == 0)); then
    info "удаление пустой группы '${GROUP_NAME}'"
    groupdel "${GROUP_NAME}"
  else
    warn "группа '${GROUP_NAME}' сохранена: в ней ещё есть пользователи:"
    printf '  %s\n' "${remaining_members[@]}"
  fi
fi

printf '\nГотово. Настройка void-packages отменена.\n'
printf 'Чтобы обновить список групп в текущем сеансе, выйдите из системы и войдите снова.\n'
