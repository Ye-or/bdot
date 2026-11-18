#!/usr/bin/env bash

set -euo pipefail

CONTAINER="excalidraw"
IMAGE="excalidraw/excalidraw:latest"
URL="http://localhost:5000"

command -v docker >/dev/null 2>&1 || {
  echo "Ошибка: Docker не найден." >&2
  exit 1
}

command -v xdg-open >/dev/null 2>&1 || {
  echo "Ошибка: xdg-open не найден. Установите пакет xdg-utils." >&2
  exit 1
}

if docker container inspect "$CONTAINER" >/dev/null 2>&1; then
  STATUS=$(docker inspect --format '{{.State.Status}}' "$CONTAINER")
  if [[ "$STATUS" != "running" ]]; then
    echo "Запускаю контейнер '$CONTAINER'..."
    docker start "$CONTAINER" >/dev/null
  fi
else

  echo "Скачиваю образ $IMAGE..."
  docker pull "$IMAGE"

  echo "Создаю и запускаю контейнер..."
  docker run -d \
    --name "$CONTAINER" \
    --restart unless-stopped \
    -p 127.0.0.1:5000:80 \
    "$IMAGE" >/dev/null
fi

echo "Жду запуска Excalidraw..."

for _ in {1..30}; do
  if curl -fsS "$URL" >/dev/null 2>&1; then
    xdg-open "$URL"
    exit 0
  fi
  sleep 1
done

echo "Контейнер запущен, но страница пока не отвечает: $URL" >&2
exit 1
