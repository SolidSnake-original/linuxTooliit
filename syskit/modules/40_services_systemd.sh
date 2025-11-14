#!/usr/bin/env bash

MODULE_ID=40
MODULE_NAME="Services (systemd)"
MODULE_DESC="List systemd services"

module_requirements() {
    echo "systemctl"
}

module_run() {
    if ! command_exists systemctl; then
        ui_warn "systemctl not found. This system may not use systemd."
        return
    fi

    ui_notice "Listing all systemd services:"
    systemctl list-units --type=service --all
}

register_module
