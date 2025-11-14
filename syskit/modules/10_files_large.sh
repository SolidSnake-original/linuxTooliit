#!/usr/bin/env bash

MODULE_ID=10
MODULE_NAME="Large Files"
MODULE_DESC="Find files larger than a specified size"

module_requirements() {
    echo "find"
}

module_run() {
    local default_path="${SYSKIT_DEFAULT_LARGEFILE_PATH:-/}"
    local default_size="${SYSKIT_DEFAULT_LARGEFILE_SIZE_MB:-100}"

    ui_prompt "Start path [${default_path}]:"
    local path
    IFS= read -r path
    path=$(trim "$path")
    if [ -z "$path" ]; then
        path="$default_path"
    fi

    if [ ! -d "$path" ]; then
        ui_error "Path '$path' does not exist or is not a directory."
        return
    fi

    ui_prompt "Minimum file size in MB [${default_size}]:"
    local size
    IFS= read -r size
    size=$(trim "$size")
    if [ -z "$size" ]; then
        size="$default_size"
    fi

    case "$size" in
        ''|*[!0-9]*)
            ui_error "Invalid size value."
            return
            ;;
    esac

    ui_notice "Listing files in '$path' larger than ${size}MB"
    find "$path" -type f -size +"${size}"M -print 2>/dev/null
}

register_module
