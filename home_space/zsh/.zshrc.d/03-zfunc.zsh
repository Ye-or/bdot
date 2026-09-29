# ~/zsh/.config/zsh/zshrc.d/zfunc

ZSH_FUNC="${ZSHRC_DIR}/zfunc.d"

typeset -U fpath
fpath=( "${ZSH_FUNC}" "${fpath[@]}"  )
autoload -Uz "${ZSH_FUNC}"/*(:t)
