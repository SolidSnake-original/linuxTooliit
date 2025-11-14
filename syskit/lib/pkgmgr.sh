#!/usr/bin/env bash
# Package manager abstraction for syskit.

PKGMGR_COMMAND=""

pkgmgr_detect() {
    if command_exists apt-get; then
        PKGMGR_COMMAND="apt"
    elif command_exists dnf; then
        PKGMGR_COMMAND="dnf"
    elif command_exists pacman; then
        PKGMGR_COMMAND="pacman"
    elif command_exists zypper; then
        PKGMGR_COMMAND="zypper"
    elif command_exists apk; then
        PKGMGR_COMMAND="apk"
    else
        PKGMGR_COMMAND=""
    fi
    printf '%s' "$PKGMGR_COMMAND"
}

pkgmgr_update() {
    case "$PKGMGR_COMMAND" in
        apt)
            sudo apt-get update
            ;;
        dnf)
            sudo dnf check-update
            ;;
        pacman)
            sudo pacman -Sy
            ;;
        zypper)
            sudo zypper refresh
            ;;
        apk)
            sudo apk update
            ;;
        *)
            return 1
            ;;
    esac
}

pkgmgr_upgrade() {
    case "$PKGMGR_COMMAND" in
        apt)
            sudo apt-get upgrade -y
            ;;
        dnf)
            sudo dnf upgrade -y
            ;;
        pacman)
            sudo pacman -Su --noconfirm
            ;;
        zypper)
            sudo zypper update -y
            ;;
        apk)
            sudo apk upgrade
            ;;
        *)
            return 1
            ;;
    esac
}

pkgmgr_cleanup() {
    case "$PKGMGR_COMMAND" in
        apt)
            sudo apt-get autoremove -y
            sudo apt-get autoclean
            ;;
        dnf)
            sudo dnf autoremove -y
            ;;
        pacman)
            sudo pacman -Sc --noconfirm
            ;;
        zypper)
            sudo zypper clean --all
            ;;
        apk)
            sudo apk cache clean
            ;;
        *)
            return 1
            ;;
    esac
}
