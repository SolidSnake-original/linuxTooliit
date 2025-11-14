#!/usr/bin/env bash

MODULE_ID=90
MODULE_NAME="Logs"
MODULE_DESC="Show recent system logs"

module_requirements() {
    echo "journalctl tail"
}

module_run() {
    if command_exists journalctl; then
        ui_notice "Latest journal entries (journalctl -n 50):"
        journalctl -n 50
        return
    fi

    local log_file=""
    if [ -f /var/log/syslog ]; then
        log_file="/var/log/syslog"
    elif [ -f /var/log/messages ]; then
        log_file="/var/log/messages"
    fi

    if [ -n "$log_file" ]; then
        ui_notice "Showing last 50 lines of $log_file:"
        tail -n 50 "$log_file"
    else
        ui_warn "No common log files found."
    fi
}

register_module
