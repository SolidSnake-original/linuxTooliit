#!/usr/bin/env bash

MODULE_ID=80
MODULE_NAME="Network"
MODULE_DESC="Display network configuration and sockets"

module_requirements() {
    echo "ip ss netstat"
}

module_run() {
    if command_exists ip; then
        ui_notice "IP addresses (ip addr):"
        ip addr
        printf '\n'

        ui_notice "Routing table (ip route):"
        ip route
        printf '\n'
    else
        ui_error "ip command not available."
    fi

    if command_exists ss; then
        ui_notice "Listening sockets (ss -tulpn):"
        ss -tulpn
    elif command_exists netstat; then
        ui_notice "Listening sockets (netstat -tulpn):"
        netstat -tulpn
    else
        ui_warn "Neither ss nor netstat is available to list sockets."
    fi
}

register_module
