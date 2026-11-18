#!/usr/bin/env bash

SYMLINK_DIR="${HOME}/.local/share/awww"

[ ! -d "$SYMLINK_DIR" ] && exit 0

if ! pgrep -x "awww-daemon" >/dev/null; then
  awww-daemon >/dev/null 2>&1 &

  for _ in {1..30}; do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
  done
fi

for LINK_PATH in "${SYMLINK_DIR}"/*; do
  if [ -L "$LINK_PATH" ] && [ -e "$LINK_PATH" ]; then
    OUTPUT_NAME=$(basename "$LINK_PATH")
    TARGET_IMG=$(readlink -f "$LINK_PATH")
    awww img -o "$OUTPUT_NAME" "$TARGET_IMG" --transition-type none
  fi
done
