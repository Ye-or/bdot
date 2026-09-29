# ~/.config/zsh/zshenv
### adrg/xdg

export LIBVA_DRIVER_NAME=nvidia
export XDG_SESSION_TYPE=wayland

### SPACE: XDG_VARIABLES ###

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_BIN_HOME:=$HOME/.local/bin}"
: "${XDG_LIB_HOME:=$HOME/.local/lib}"
: "${XDG_CONFIG_DIRS:=/etc/xdg}"
: "${XDG_DATA_DIRS:=/usr/local/share:/usr/share}"

export XDG_CONFIG_HOME \
  XDG_DATA_HOME   \
  XDG_CACHE_HOME  \
  XDG_STATE_HOME  \
  XDG_BIN_HOME    \
  XDG_LIB_HOME    \
  XDG_DATA_DIRS   \
  XDG_CONFIG_DIRS

### SPACE: JAVA ###
export JAVA_HOME="/usr/lib/jvm/openjdk17"

### SPACE: ANDROID ###
export ANDROID_HOME="${HOME}/Android/Sdk"        # путь, куда установится SDK
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/latest"
export NDK_HOME="$ANDROID_NDK_HOME"

# if [ -d "$XDG_BIN_HOME" ] && [[ ":$PATH:" != *":$XDG_BIN_HOME:"* ]]; then
#   PATH="$XDG_BIN_HOME:$PATH"
#   export PATH
# fi

typeset -U path
path=( ${(s/:/)PATH} )  # разбить PATH на массив по ':' и убрать дубликаты

[[ -d $XDG_BIN_HOME ]] && path=( $XDG_BIN_HOME $path )


### SPACE: ZSH ###

export ZSH_ETC="${HOME}/.zshrc.d"
export ZSHRC_DIR="${HOME}/.zshrc.d"
export ZSH_SHARE="${HOME}/.local/share/zsh"
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export PAGER="less"

### SPACE: ZSH_PLUGINS ###

export ZPLUGIN_SPEC_DIR="${ZSHRC_DIR}/zplugin.d"
export ZPLUGIN_INSTALL_DIR="${ZSH_SHARE}/plugins"

### SPACE: RUNIT_TURNSTILE ###
export SVDIR=~/.config/service
### SPACE: CARGO ###
[[ -f $HOME/.cargo/env ]] && source "$HOME/.cargo/env"
### SPACE: OPENCODE ###
[[ -d $HOME/.opencode ]] && path=( $HOME/.opencode/bin $path )

### SPACE: EXPORT_PATH ###
export PATH="${(j/:/)path}"
