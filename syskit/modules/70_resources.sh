#!/usr/bin/env bash

MODULE_ID=70
MODULE_NAME="Resources"
MODULE_DESC="Show system resource usage"

module_requirements() {
    echo "free ps uptime head"
}

module_run() {
    local limit=$(( ${SYSKIT_DEFAULT_LIST_LIMIT:-10} ))
    if [ "$limit" -lt 1 ]; then
        limit=10
    fi

    ui_notice "Memory usage (free -h):"
    free -h

    printf '\n'

    if command_exists uptime; then
        ui_notice "System load (uptime):"
        uptime
        printf '\n'
    else
        ui_warn "uptime command not available."
    fi

    ui_notice "Top processes by CPU usage:"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n $((limit + 1))

    printf '\n'

    ui_notice "Top processes by memory usage:"
    ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n $((limit + 1))
}

register_module
