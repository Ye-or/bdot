#.zshrc.d/.zalias.d/fd.zsh

if (( ! $+commands[fd] )); then
  return 1
fi

alias find='fd'
