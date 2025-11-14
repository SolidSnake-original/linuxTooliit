#!/usr/bin/env bash

MODULE_ID=50
MODULE_NAME="Firewall"
MODULE_DESC="Show firewall status from UFW and iptables"

module_requirements() {
    echo "ufw iptables"
}

module_run() {
    if command_exists ufw; then
        ui_notice "UFW status:"
        ufw status
    else
        ui_warn "UFW not installed."
    fi

    printf '\n'

    if command_exists iptables; then
        ui_notice "iptables rules:"
        iptables -L -n -v
    else
        ui_warn "iptables command not available."
    fi
}

register_module
