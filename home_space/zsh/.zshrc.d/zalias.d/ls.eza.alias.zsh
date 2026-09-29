#.zshrc.d/.zalias.d/eza.zsh

if (( ! $+commands[eza] )); then
  return 1
fi

# general use aliases 
alias ls='eza' # just replace ls by eza and allow all other eza arguments
alias l='ls -lbF' #   list, size, type
alias ll='ls -la' # long, all
alias llm='ll --sort=modified' # list, long, sort by modification date
alias la='ls -lbhHigUmuSa' # all list
alias lx='ls -lbhHigUmuSa@' # all list and extended
alias tree='eza --tree' # tree view
alias lS='eza -1' # one column by just names
