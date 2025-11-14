#!/usr/bin/env bash
# Common helper functions for syskit.

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "[!] This action requires root privileges." >&2
        return 1
    fi
    return 0
}

pause() {
    local msg=${1:-"Press Enter to continue..."}
    read -r -p "$msg" _
}

join_by() {
    local sep="$1"
    shift
    local first=1
    local element
    for element in "$@"; do
        if [ $first -eq 1 ]; then
            printf '%s' "$element"
            first=0
        else
            printf '%s%s' "$sep" "$element"
        fi
    done
}

trim() {
    local var="$*"
    # shellcheck disable=SC2001
    printf '%s' "$(printf '%s' "$var" | sed -e 's/^\s\+//' -e 's/\s\+$//')"
}

read_choice() {
    local prompt="$1"
    local default="$2"
    local input
    if [ -n "$prompt" ]; then
        printf '%s' "$prompt"
    fi
    IFS= read -r input
    if [ -z "$(trim "$input")" ] && [ -n "$default" ]; then
        printf '%s' "$default"
    else
        printf '%s' "$input"
    fi
}
