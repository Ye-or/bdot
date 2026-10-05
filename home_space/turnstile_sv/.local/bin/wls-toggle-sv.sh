#!/usr/bin/env sh

SERVICE_NAME="$1"

if [ -z "$SERVICE_NAME" ]; then
  echo "Использование: $0 <имя_сервиса>"
  exit 1
fi

if sv status "$SERVICE_NAME" | grep -q "^run:"; then
  sv down "$SERVICE_NAME"
else
  sv up "$SERVICE_NAME"
fi
