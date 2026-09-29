#!/usr/bin/env bash

set -Eeuo pipefail

readonly GROUP_NAME="voidbuild"
readonly INSTALL_DIR="/opt/void-packages"
readonly REPOSITORY_URL="https://github.com/void-linux/void-packages.git"

error() {
  printf 'Ошибка: %s\n' "$*" >&2
  exit 1
}

if [[ "${EUID}" -ne 0 ]]; then
  error "скрипт нужно запускать от root или через sudo"
fi

# Пользователь, запустивший sudo.
# Если скрипт запущен напрямую от root, можно передать пользователя первым аргументом:
# sudo ./deploy-void-packages.sh username
TARGET_USER="${1:-${SUDO_USER:-}}"

if [[ -z "${TARGET_USER}" || "${TARGET_USER}" == "root" ]]; then
  error "не удалось определить обычного пользователя.
Запустите через sudo или укажите пользователя:
sudo $0 username"
fi

if ! id "${TARGET_USER}" &>/dev/null; then
  error "пользователь '${TARGET_USER}' не существует"
fi

TARGET_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"

if [[ -z "${TARGET_HOME}" || ! -d "${TARGET_HOME}" ]]; then
  error "не удалось определить домашний каталог пользователя '${TARGET_USER}'"
fi

printf 'Пользователь сборки: %s\n' "${TARGET_USER}"
printf 'Группа сборки:       %s\n' "${GROUP_NAME}"
printf 'Каталог:             %s\n' "${INSTALL_DIR}"

# Создать системную группу, если она ещё не существует.
if ! getent group "${GROUP_NAME}" >/dev/null; then
  groupadd --system "${GROUP_NAME}"
fi

# Добавить пользователя в группу, если он ещё не состоит в ней.
if ! id -nG "${TARGET_USER}" | tr ' ' '\n' | grep -qx "${GROUP_NAME}"; then
  usermod --append --groups "${GROUP_NAME}" "${TARGET_USER}"
  printf 'Пользователь %s добавлен в группу %s.\n' \
    "${TARGET_USER}" "${GROUP_NAME}"
fi

# Создать каталог с setgid:
# новые файлы и каталоги будут наследовать группу voidbuild.
install -d \
  -o root \
  -g "${GROUP_NAME}" \
  -m 2775 \
  "${INSTALL_DIR}"

if [[ -e "${INSTALL_DIR}/.git" ]]; then
  printf 'Репозиторий уже существует: %s\n' "${INSTALL_DIR}"
else
  if [[ -n "$(find "${INSTALL_DIR}" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    error "каталог ${INSTALL_DIR} не пуст и не является git-репозиторием"
  fi

  printf 'Клонирование репозитория...\n'

  # Клонировать от обычного пользователя, а не от root.
  runuser -u "${TARGET_USER}" -- \
    env HOME="${TARGET_HOME}" \
    bash -c "
            umask 0002
            git clone \
                '${REPOSITORY_URL}' \
                '${INSTALL_DIR}'
        "
fi

# Настройки git для совместной работы группы.
runuser -u "${TARGET_USER}" -- \
  env HOME="${TARGET_HOME}" \
  git -C "${INSTALL_DIR}" config core.sharedRepository group

# На случай, если каталог был создан ранее с неправильными правами.
chown -R "root:${GROUP_NAME}" "${INSTALL_DIR}"
chmod -R g+rwX "${INSTALL_DIR}"

# Вернуть setgid на все каталоги.
find "${INSTALL_DIR}" \
  -type d \
  -exec chmod g+s {} +

printf '\nГотово.\n\n'
printf 'Репозиторий установлен в:\n  %s\n\n' "${INSTALL_DIR}"
printf 'Пользователь сборки:\n  %s\n\n' "${TARGET_USER}"
printf 'Группа:\n  %s\n\n' "${GROUP_NAME}"

printf 'Чтобы активировать новую группу, перелогиньтесь.\n'
printf 'После этого выполните от имени обычного пользователя:\n\n'
printf '  cd %s\n' "${INSTALL_DIR}"
printf '  ./xbps-src binary-bootstrap\n'
printf '  ./xbps-src pkg <имя-пакета>\n'
