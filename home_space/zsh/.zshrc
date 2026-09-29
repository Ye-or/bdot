# ~/.config/zsh/zshrc

[[ $- != *i* ]] && return

autoload -Uz compinit
compinit -C

# --- history config ---

export HISTFILE=$HOME/.zsh_history

# How many commands zsh will load to memory.
export HISTSIZE=10000

# How many commands history will save on file.
export SAVEHIST=10000

setopt EXTENDED_HISTORY          # Записывать время и длительность команд
setopt INC_APPEND_HISTORY        # Записывать команды сразу, а не после выхода
setopt SHARE_HISTORY             # Делить историю между сессиями
setopt HIST_EXPIRE_DUPS_FIRST    # Удалять дубликаты при переполнении
setopt HIST_IGNORE_DUPS          # Не записывать дубликаты подряд
setopt HIST_IGNORE_ALL_DUPS      # Удалять старые дубликаты при записи нового
setopt HIST_SAVE_NO_DUPS         # Не сохранять дубликаты в файл
setopt HIST_FIND_NO_DUPS         # Искать уникальные записи при поиске

# --- optional ---
 
# Correcting typos in commands
setopt CORRECT

setopt COMBINING_CHARS # Корректная работа с UTF-8 и символами
# --- binding keys --- 

bindkey -e #-v
#bindkey '^U' backward-kill-line

if [ -d "${ZSHRC_DIR}" ]; then
    for i in "${ZSHRC_DIR}/"*.zsh; do
        if [ -r "$i" ]; then
            source "$i"
        fi
    done
    unset i
fi
