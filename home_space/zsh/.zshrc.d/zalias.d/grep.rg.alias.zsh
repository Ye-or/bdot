#.zshrc.d/.zalias.d/fd.zsh

if (( ! $+commands[rg] )); then
  return 1
fi

alias grep='rg'
