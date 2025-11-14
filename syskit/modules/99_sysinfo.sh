#!/usr/bin/env bash

MODULE_ID=99
MODULE_NAME="System Information"
MODULE_DESC="Display detailed system information"

module_requirements() {
    echo "uname lscpu"
}

module_run() {
    if [ -f /etc/os-release ]; then
        ui_notice "/etc/os-release:"
        cat /etc/os-release
        printf '\n'
    else
        ui_warn "/etc/os-release not found."
    fi

    ui_notice "Kernel information (uname -a):"
    uname -a
    printf '\n'

    if command_exists lscpu; then
        ui_notice "CPU information (lscpu):"
        lscpu
    else
        ui_warn "lscpu command not available."
    fi
}

register_module
