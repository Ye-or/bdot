# ~/.config/zsh/zshrc.d/zalias

ALIAS_DIR="${ZSHRC_DIR}/zalias.d"
files=("$ALIAS_DIR"/*(N-.))

if (( ${#files} > 0 )); then
    for file in "${files[@]}"; do
        source "$file"
    done
fi
