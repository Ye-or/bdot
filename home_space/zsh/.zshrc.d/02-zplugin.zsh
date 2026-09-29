# ~/.config/zsh/zshrc.d/zplugin

typeset zplugin_spec_dir="${ZPLUGIN_SPEC_DIR:-$HOME/.zshrc.d/zplugin.d}"
typeset zplugin_install_dir="${ZPLUGIN_INSTALL_DIR:-${ZSHRC_DIR:-$HOME/.local/share/zsh}/plugins}"


zplugin_add() {
    emulate -L zsh

    local plugin_name="$1"
    local plugin_repo="$2"
    local plugin_tag="$3"
    local plugin_entry="$4"

    if [[ -z "$plugin_name" ||
          -z "$plugin_repo" ||
          -z "$plugin_entry" ]]; then
        print -u2 "zplugin: некорректное описание плагина"
        return 1
    fi

    local plugin_dir="$zplugin_install_dir/$plugin_name"
    local plugin_file="$plugin_dir/$plugin_entry"
    local version_file="$plugin_dir/.zplugin-version"

    # Для плагина без TAG используем специальное значение
    local requested_version="${plugin_tag:-__default_branch__}"
    local installed_version=""

    if [[ -f "$version_file" ]]; then
        installed_version="$(< "$version_file")"
    fi

    # Если нужная версия уже установлена — просто подключаем её
    if [[ -f "$plugin_file" &&
          "$installed_version" == "$requested_version" ]]; then
        source "$plugin_file"
        return 0
    fi

    if (( ! $+commands[git] )); then
        print -u2 "zplugin: git не установлен, невозможно скачать $plugin_name"
        return 1
    fi

    mkdir -p -- "$zplugin_install_dir" || {
        print -u2 "zplugin: невозможно создать $zplugin_install_dir"
        return 1
    }

    local tmp_dir="${plugin_dir}.tmp.$$.$RANDOM"
    local display_version="${plugin_tag:-default branch}"

    # Аргументы git clone
    local -a clone_args
    clone_args=(
        --depth=1
        --single-branch
        --quiet
    )

    # Если TAG указан — клонируем конкретный tag.
    # Если TAG пустой — клонируем ветку по умолчанию.
    if [[ -n "$plugin_tag" ]]; then
        clone_args+=(--branch "$plugin_tag")
    fi

    print "zplugin: установка $plugin_name ($display_version)"

    if ! git clone \
        "${clone_args[@]}" \
        "$plugin_repo" \
        "$tmp_dir"
    then
        print -u2 "zplugin: не удалось установить $plugin_name"
        rm -rf -- "$tmp_dir"
        return 1
    fi

    if [[ ! -f "$tmp_dir/$plugin_entry" ]]; then
        print -u2 "zplugin: файл $plugin_entry не найден в $plugin_name"
        rm -rf -- "$tmp_dir"
        return 1
    fi

    # Запоминаем tag либо факт установки default branch
    print -r -- "$requested_version" > "$tmp_dir/.zplugin-version"

    # Заменяем старую версию новой
    rm -rf -- "$plugin_dir"
    mv -- "$tmp_dir" "$plugin_dir"

    source "$plugin_file"
}


# Загружает один файл-описание плагина
zplugin_load_spec() {
    emulate -L zsh

    local NAME
    local URL
    local TAG
    local ENTRY

    # Переменные из файла не загрязняют глобальное окружение
    source "$1"

    zplugin_add \
        "$NAME" \
        "$URL" \
        "$TAG" \
        "$ENTRY"
}


# Загружаем описания плагинов в лексикографическом порядке
if [[ -d "$zplugin_spec_dir" ]]; then
    for plugin_spec in "$zplugin_spec_dir"/*.zsh; do
        [[ -f "$plugin_spec" ]] || continue
        zplugin_load_spec "$plugin_spec"
    done
fi

