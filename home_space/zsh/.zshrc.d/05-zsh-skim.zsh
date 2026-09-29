source <(sk --shell zsh)

# Горячие клавиши (Ctrl+R, Ctrl+T, Alt+C)
[ -f "/usr/share/skim/key-bindings.zsh" ] && source "/usr/share/skim/key-bindings.zsh"

# 1. Глобальные визуальные настройки
export SKIM_DEFAULT_OPTIONS="--height 80% --layout=reverse --border --info=inline"

# 2. Ускорение поиска через fd (если установлен)
if command -v fd &> /dev/null; then
  export SKIM_CTRL_T_COMMAND="fd --type f --type d --hidden --follow --exclude .git 2>/dev/null"
fi

# 3. Настройки Ctrl-T (Поиск файлов)
export SKIM_CTRL_T_OPTS="
  --preview 'if [ -d {} ]; then ls -la --color=always {}; else bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}; fi'
  --preview-window right:60%:wrap
  --bind 'ctrl-e:execute(nvim {} < /dev/tty > /dev/tty)'
"

# 4. Настройки Ctrl-R (История)
export SKIM_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --tiebreak=index
"

# 5. Настройки Alt-C (Переход в папку)
export SKIM_ALT_C_OPTS="
  --preview 'ls -la --color=always {}'
  --preview-window right:50%
"
