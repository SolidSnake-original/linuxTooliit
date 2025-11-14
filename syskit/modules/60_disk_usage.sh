#!/usr/bin/env bash

MODULE_ID=60
MODULE_NAME="Disk Usage"
MODULE_DESC="Display disk usage and largest directories"

module_requirements() {
    echo "df lsblk du sort head"
}

module_run() {
    ui_notice "Filesystem usage (df -h):"
    df -h

    printf '\n'

    if command_exists lsblk; then
        ui_notice "Block devices (lsblk):"
        lsblk
        printf '\n'
    else
        ui_warn "lsblk not available. Skipping block device listing."
    fi

    local target="${SYSKIT_DEFAULT_LARGEFILE_PATH:-/}"
    ui_prompt "Path to analyze for largest directories [${target}]:"
    local path_input
    IFS= read -r path_input
    path_input=$(trim "$path_input")
    if [ -n "$path_input" ]; then
        target="$path_input"
    fi

    if [ ! -d "$target" ]; then
        ui_error "Path '$target' is not a directory."
        return
    fi

    local limit=$(( ${SYSKIT_DEFAULT_LIST_LIMIT:-10} ))
    if [ "$limit" -lt 1 ]; then
        limit=10
    fi

    ui_notice "Top $limit directories by size under '$target' (MB):"
    du -x -m "$target" 2>/dev/null | sort -nr | head -n "$limit"
}

register_module
