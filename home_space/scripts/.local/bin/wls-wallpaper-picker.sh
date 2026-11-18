#!/usr/bin/env bash

# Папка с вашими обоями
WALLPAPER_DIR="${HOME}/Pictures/Wallpapers"
SYMLINK_DIR="${HOME}/.local/share/awww"

if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Папка $WALLPAPER_DIR не найдена!"
  read -rn 1
  exit 1
fi

mkdir -p "$SYMLINK_DIR"

if ! pgrep -x "awww-daemon" >/dev/null; then
  awww-daemon >/dev/null 2>&1 &
  sleep 0.3
fi

# Получаем список подключённых мониторов через niri
OUTPUTS=$(niri msg -j outputs | jq -r 'keys[]')

if [ -z "$OUTPUTS" ]; then
  echo "Не удалось получить список мониторов от niri!"
  read -rn 1
  exit 1
fi

OUTPUT_COUNT=$(printf '%s\n' "$OUTPUTS" | wc -l)

if [ "$OUTPUT_COUNT" -gt 1 ]; then
  TARGET_OUTPUT=$(printf '%s\n' "$OUTPUTS" | sk --prompt="Monitor > ")
  # Если пользователь нажал Esc при выборе монитора — выходим
  [ -z "$TARGET_OUTPUT" ] && exit 0
else
  TARGET_OUTPUT="$OUTPUTS"
fi

SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort |
  sk --prompt="Wallpaper (${TARGET_OUTPUT}) > " \
    --delimiter='/' \
    --with-nth=-1 \
    --preview '{}' --image \
    --preview-window=right:60%)

if [ -n "$SELECTED" ]; then
  awww img -o "$TARGET_OUTPUT" "$SELECTED" --transition-type wipe --transition-fps 60 --transition-duration 0.8
  ln -sf "$SELECTED" "${SYMLINK_DIR}/${TARGET_OUTPUT}"
fi
