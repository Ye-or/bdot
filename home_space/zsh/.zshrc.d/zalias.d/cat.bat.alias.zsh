#.zshrc.d/.zalias.d/fd.zsh

if (( ! $+commands[bat] )); then
  return 1
fi

alias cat='bat'
