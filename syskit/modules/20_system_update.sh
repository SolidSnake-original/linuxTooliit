#!/usr/bin/env bash

MODULE_ID=20
MODULE_NAME="System Update"
MODULE_DESC="Run package manager update, upgrade and cleanup"

module_requirements() {
    echo "sudo"
}

module_run() {
    local manager
    manager=$(pkgmgr_detect)
    if [ -z "$manager" ]; then
        ui_error "No supported package manager detected."
        return
    fi

    if [ "$(id -u)" -ne 0 ] && ! command_exists sudo; then
        ui_warn "Root privileges or sudo are required to update packages."
        return
    fi

    ui_notice "Detected package manager: $manager"
    ui_prompt "Run update, upgrade and cleanup now? [y/N]:"
    local confirm
    IFS= read -r confirm
    confirm=$(printf '%s' "$confirm" | tr '[:upper:]' '[:lower:]')

    if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ]; then
        ui_warn "Operation cancelled."
        return
    fi

    ui_notice "Running update..."
    if ! pkgmgr_update; then
        ui_error "Update step failed."
        return
    fi

    ui_notice "Running upgrade..."
    if ! pkgmgr_upgrade; then
        ui_error "Upgrade step failed."
        return
    fi

    ui_notice "Running cleanup..."
    if ! pkgmgr_cleanup; then
        ui_warn "Cleanup step encountered an issue."
    else
        ui_success "System cleanup completed."
    fi
}

register_module
