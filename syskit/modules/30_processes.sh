#!/usr/bin/env bash

MODULE_ID=30
MODULE_NAME="Processes"
MODULE_DESC="Show top CPU and memory consuming processes"

module_requirements() {
    echo "ps head"
}

module_run() {
    local limit=$(( ${SYSKIT_DEFAULT_LIST_LIMIT:-10} ))
    if [ "$limit" -lt 1 ]; then
        limit=10
    fi

    ui_notice "Top processes by CPU usage:"
    ps aux --sort=-%cpu | head -n $((limit + 1))
    printf '\n'

    ui_notice "Top processes by memory usage:"
    ps aux --sort=-%mem | head -n $((limit + 1))
}

register_module
