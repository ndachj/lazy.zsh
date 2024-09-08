#!/usr/bin/env zsh

# lazy.zsh plugin manger
# Ndachj <https://github.com/ndachj/lazy.zsh>

if [[ -z "${LAZYZ}" ]]; then
    export LAZYZ="${XDG_DATA_HOME:-$HOME/.local/share}/lazyz" # where to save plugins
    mkdir -p "${LAZYZ}" &>/dev/null
fi

declare -af __LAZYZ_INSTALLED     # hold installed plugins
declare -af __LAZYZ_NOT_INSTALLED # hold not installed plugins

function _lazyz_update() {
    # update installed plugins

    _lazyz_get_installed_plugins
    local plugin plugin_path plugin_name last_head current_head
    for plugin in "${__LAZYZ_INSTALLED[@]}"; do
        if [[ -z "${plugin}" ]]; then
            print "[lazyz]: No plugin to update!"
            break 1
        fi
        plugin_path="${LAZYZ}"/${plugin}       # path of plugin
        plugin_name=$(basename "$plugin_path") # it's name
        last_head=$(git -C "${plugin_path}" rev-parse HEAD)
        if (git -C "${plugin_path}" pull --quiet --rebase --stat --autostash); then
            current_head=$(git -C "${plugin_path}" rev-parse HEAD)
            # compare the last head and the current head(after a `git pull`)
            if [ "${last_head}" != "${current_head}" ]; then
                print "[lazyz]: ${plugin_name} plugin has been updated."
            else
                print "[lazyz]: ${plugin_name} plugin was already at the latest version."
            fi
        else
            print "[lazyz]: Error updating the ${plugin_name} plugin. Try again later?"
        fi
    done
}

function _lazyz_list() {
    # list plugins(installed and not installed)

    _lazyz_get_installed_plugins
    print "[lazyz]: lazy.zsh plugin manager"
    print "Installed Plugins: \n\t${__LAZYZ_INSTALLED//' '/\n\t}"
    print "Not Installed Plugins: \n\t${__LAZYZ_NOT_INSTALLED//' '/\n\t}"
}

function _lazyz_get_installed_plugins() {
    # get installed and not installed plugins

    unset __LAZYZ_INSTALLED
    unset __LAZYZ_NOT_INSTALLED

    local plugin striped_p
    for plugin in "${LAZYZ_PLUGINS[@]}"; do
        striped_p="${plugin##[A-Za-z0-9]*/}"
        # plugin dir exists and non-empty
        if [[ -s "${LAZYZ}/${striped_p}/.git" ]]; then
            __LAZYZ_INSTALLED+=("$striped_p")
        else # otherwise (dir exists and empty) or (dir doesn't exists)
            __LAZYZ_NOT_INSTALLED+=("$striped_p")
        fi
    done
}

function _lazyz_install() {
    # install not installed plugins

    _lazyz_get_installed_plugins
    local plugin plugin_dir url
    for plugin in "${__LAZYZ_NOT_INSTALLED[@]}"; do
        if [[ -z "${plugin}" ]]; then
            print "[lazyz]: No plugin to install!"
            break 1
        else
            url=$(print "${LAZYZ_PLUGINS//' '/\n}" | grep --word-regexp "${plugin}")
            plugin_dir="${LAZYZ}/${plugin}"
            mkdir -p "${plugin_dir}" &>/dev/null
            # expand short github url(username/reponame)
            if [[ $url != git://* && $url != https://* && $url != http://* && $url != ssh://* && $url != git@*:*/* ]]; then
                url="https://github.com/${url%.git}.git"
            fi
            git clone --depth=1 "${url}" "${plugin_dir}"
        fi
    done
}

function _lazyz_remove() {
    # remove a plugin or all

    _lazyz_get_installed_plugins
    local plugin=${2}
    if [[ -z "${plugin}" ]]; then
        print "[lazyz]: missing operand"
        print "Try 'lazyz help' for more information."
        return 1
    elif [[ "${plugin}" == "all" ]]; then
        # shellcheck disable=SC2115
        rm -rf --interactive=never "${LAZYZ}"/*
        print "\n[lazyz]: Done"
        return 0
    else
        plugin_name=$(print "${__LAZYZ_INSTALLED//' '/\n}" | grep --word-regexp "${plugin}")
        if [[ -n "${plugin_name}" ]]; then
            rm -rf --interactive=once "${LAZYZ:?}/$plugin_name"
        else
            print "[lazyz]: ${plugin} plugin doesn't exists or is not installed!"
            print "Run 'lazyz list' to see installed plugins."
        fi

    fi

}

function _lazyz_help() {
    print "Usage: lazyz [command] [arg]"
    print ""
    print "Commands:"
    print "\tlist - list all plugins"
    print "\tupdate - update installed plugins"
    print "\tinstall - install plugins that aren't installed"
    print "\tremove NAME - remove the plugin (NAME or all)"
    print ""
}

# shameless copy from "autoupdate-oh-my-zsh-plugins"
# <https://github.com/tamcore/autoupdate-oh-my-zsh-plugins/blob/master/autoupdate.plugin.zsh>
zmodload zsh/datetime

function _current_epoch() {
    print $(($EPOCHSECONDS / 60 / 60 / 24))
}

function _update_zsh_custom_update() {
    print "LAST_EPOCH=$(_current_epoch)" >|"${XDG_CACHE_HOME:-${HOME}/.cache}/.lazy-zsh"
}

function _lazyz_remind_user() {
    local epoch_diff choice
    if [ -r "${HOME}/.cache/.lazy-zsh" ]; then
        . "${HOME}/.cache/.lazy-zsh"
    fi

    if [[ -z "$LAST_EPOCH" ]]; then
        LAST_EPOCH=0
    fi

    epoch_diff=$(($(_current_epoch) - $LAST_EPOCH))
    if [ $epoch_diff -gt "$LAZYZ_UPDATE_INTERVAL" ]; then
        print "[lazyz]: It's time to update!"
        print "Would you like to check for plugin updates? [y/N] "
        read choice
        case "${choice}" in
        Y | y)
            _lazyz_update
            ;;
        *) # default [No]
            print "[lazyz]: Remember! You can run 'lazyz update' to check for update."
            ;;
        esac
        _update_zsh_custom_update
    fi
}

# main
if [[ "$LAZYZ_UPDATE_REMAINDER" == "true" ]]; then
    _lazyz_remind_user
fi

unset -f _current_epoch _update_zsh_custom_update _lazyz_remind_user

lazyz() {
    local cmd="${1}"
    if [[ -z "${cmd}" ]]; then
        _lazyz_help
        return 1
    fi
    if functions "_lazyz_${cmd}" >/dev/null; then
        "_lazyz_${cmd}" "${@}"
    else
        print "[lazyz]: command '${cmd}' not found"
        return 1
    fi
}
