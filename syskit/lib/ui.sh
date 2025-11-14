#!/usr/bin/env bash
# UI helper functions with ANSI colors.

UI_COLOR_RESET='\033[0m'
UI_COLOR_PRIMARY='\033[1;36m'
UI_COLOR_SECONDARY='\033[1;34m'
UI_COLOR_WARNING='\033[1;33m'
UI_COLOR_ERROR='\033[1;31m'
UI_COLOR_SUCCESS='\033[1;32m'

ui_clear() {
    if command -v clear >/dev/null 2>&1; then
        clear
    else
        printf '\033c'
    fi
}

ui_banner() {
    local title="$1"
    printf '%b==== %s ====%b\n' "$UI_COLOR_PRIMARY" "$title" "$UI_COLOR_RESET"
}

ui_menu_item() {
    local index="$1"
    local label="$2"
    local status="$3"
    if [ -n "$status" ]; then
        printf '%b[%s]%b %s %b%s%b\n' \
            "$UI_COLOR_SECONDARY" "$index" "$UI_COLOR_RESET" \
            "$label" "$UI_COLOR_WARNING" "$status" "$UI_COLOR_RESET"
    else
        printf '%b[%s]%b %s\n' "$UI_COLOR_SECONDARY" "$index" "$UI_COLOR_RESET" "$label"
    fi
}

ui_prompt() {
    local text="$1"
    printf '%b%s%b ' "$UI_COLOR_PRIMARY" "$text" "$UI_COLOR_RESET"
}

ui_notice() {
    local text="$1"
    printf '%b%s%b\n' "$UI_COLOR_SECONDARY" "$text" "$UI_COLOR_RESET"
}

ui_warn() {
    local text="$1"
    printf '%b%s%b\n' "$UI_COLOR_WARNING" "$text" "$UI_COLOR_RESET"
}

ui_error() {
    local text="$1"
    printf '%b%s%b\n' "$UI_COLOR_ERROR" "$text" "$UI_COLOR_RESET"
}

ui_success() {
    local text="$1"
    printf '%b%s%b\n' "$UI_COLOR_SUCCESS" "$text" "$UI_COLOR_RESET"
}

ui_press_any_key() {
    printf '%bPress any key to continue...%b' "$UI_COLOR_SECONDARY" "$UI_COLOR_RESET"
    IFS= read -r -n 1 _
    printf '\n'
}
