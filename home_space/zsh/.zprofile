# ~/.config/zsh/.zprofile

if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec niri
fi
