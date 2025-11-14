#!/usr/bin/env bash
# syskit - minimal portable Linux toolkit

set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_FILE="$SCRIPT_DIR/config.sh"
LIB_DIR="$SCRIPT_DIR/lib"
MODULE_DIR="$SCRIPT_DIR/modules"

if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    . "$CONFIG_FILE"
fi

# Load libraries in a deterministic order
if [ -d "$LIB_DIR" ]; then
    for lib in "$LIB_DIR"/common.sh "$LIB_DIR"/ui.sh "$LIB_DIR"/pkgmgr.sh; do
        if [ -f "$lib" ]; then
            # shellcheck source=/dev/null
            . "$lib"
        fi
    done
fi

declare -a MODULE_IDS=()
declare -a MODULE_IDS_SANITIZED=()
declare -a MODULE_NAMES=()
declare -a MODULE_DESCS=()
declare -a MENU_INDEX_MAP=()

copy_function() {
    local source_name="$1"
    local target_name="$2"
    if ! declare -f "$source_name" >/dev/null; then
        return 1
    fi
    local definition
    definition=$(declare -f "$source_name") || return 1
    definition=$(printf '%s\n' "$definition" | sed "1s/^$source_name ()/$target_name ()/")
    eval "$definition"
    return 0
}

register_module() {
    local id="${MODULE_ID:-}"
    local name="${MODULE_NAME:-}"
    local desc="${MODULE_DESC:-}"
    if [ -z "$id" ] || [ -z "$name" ]; then
        echo "Invalid module metadata in $BASH_SOURCE" >&2
        return 1
    fi
    local sanitized
    sanitized=$(printf '%s' "$id" | tr -c '[:alnum:]_' '_')
    if [ -z "$sanitized" ]; then
        sanitized="$id"
    fi
    if ! copy_function module_run "module_run_${sanitized}"; then
        echo "module_run not defined for module $id" >&2
        return 1
    fi
    if ! copy_function module_requirements "module_requirements_${sanitized}"; then
        eval "module_requirements_${sanitized}() { :; }"
    fi
    MODULE_IDS+=("$id")
    MODULE_IDS_SANITIZED+=("$sanitized")
    MODULE_NAMES+=("$name")
    MODULE_DESCS+=("$desc")
    unset MODULE_ID MODULE_NAME MODULE_DESC
    unset -f module_run module_requirements
    return 0
}

check_module_requirements() {
    local sanitized="$1"
    local func="module_requirements_${sanitized}"
    local requirements=""
    local missing=""
    if declare -f "$func" >/dev/null; then
        requirements=$($func)
    fi
    if [ -n "$requirements" ]; then
        local cmd
        for cmd in $requirements; do
            if ! command_exists "$cmd"; then
                if [ -z "$missing" ]; then
                    missing="$cmd"
                else
                    missing="$missing, $cmd"
                fi
            fi
        done
    fi
    printf '%s' "$missing"
}

run_module_by_index() {
    local module_index="$1"
    local sanitized="${MODULE_IDS_SANITIZED[$module_index]}"
    local run_func="module_run_${sanitized}"
    ui_clear
    ui_banner "${MODULE_IDS[$module_index]} - ${MODULE_NAMES[$module_index]}"
    ui_notice "${MODULE_DESCS[$module_index]}"
    local missing
    missing=$(check_module_requirements "$sanitized")
    if [ -n "$missing" ]; then
        ui_warn "Missing commands: $missing. Output may be limited."
    fi
    if declare -f "$run_func" >/dev/null; then
        "$run_func"
    else
        ui_error "Run function not found for module ${MODULE_IDS[$module_index]}."
    fi
    ui_press_any_key
}

load_modules() {
    if [ ! -d "$MODULE_DIR" ]; then
        return
    fi
    local module_file
    for module_file in "$MODULE_DIR"/*.sh; do
        [ -f "$module_file" ] || continue
        # shellcheck source=/dev/null
        . "$module_file"
    done
}

show_menu() {
    ui_clear
    ui_banner "syskit - minimal Linux toolkit"
    MENU_INDEX_MAP=()
    local total=${#MODULE_IDS[@]}
    if [ "$total" -eq 0 ]; then
        ui_warn "No modules available."
        ui_menu_item "0" "Exit" ""
        return
    fi
    local sorted
    sorted=$(for i in "${!MODULE_IDS[@]}"; do printf '%s:%s\n' "${MODULE_IDS[$i]}" "$i"; done | sort -t: -k1,1n)
    local display_index=1
    while IFS=: read -r module_id module_idx; do
        [ -n "$module_id" ] || continue
        local label
        label="${MODULE_IDS[$module_idx]} - ${MODULE_NAMES[$module_idx]}: ${MODULE_DESCS[$module_idx]}"
        local sanitized="${MODULE_IDS_SANITIZED[$module_idx]}"
        local missing
        missing=$(check_module_requirements "$sanitized")
        if [ -n "$missing" ]; then
            ui_menu_item "$display_index" "$label" "(missing: $missing)"
        else
            ui_menu_item "$display_index" "$label" ""
        fi
        MENU_INDEX_MAP+=("$module_idx")
        display_index=$((display_index + 1))
    done <<MODULES_SORTED
$sorted
MODULES_SORTED
    ui_menu_item "0" "Exit" ""
}

main_loop() {
    while :; do
        show_menu
        ui_prompt "Select module (number):"
        local choice
        IFS= read -r choice
        choice=$(trim "$choice")
        if [ -z "$choice" ]; then
            continue
        fi
        if [ "$choice" = "0" ]; then
            ui_notice "Goodbye!"
            break
        fi
        if [ "$choice" -eq "$choice" ] 2>/dev/null; then
            local index=$((choice - 1))
            if [ $index -ge 0 ] && [ $index -lt ${#MENU_INDEX_MAP[@]} ]; then
                run_module_by_index "${MENU_INDEX_MAP[$index]}"
            else
                ui_warn "Invalid selection."
                ui_press_any_key
            fi
        else
            ui_warn "Please enter a numeric selection."
            ui_press_any_key
        fi
    done
}

load_modules
main_loop
