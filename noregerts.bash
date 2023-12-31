#!/bin/bash

command_not_found() {
    echo 'Updating files database...'
    sudo pacman -Fy --noconfirm >/dev/null 2>&1

    echo "Checking if $1 is available in the Arch Linux repositories..."

    # Get a list of unique package names that contain the command name anywhere in the file path
    packages=$(LC_ALL=C pacman -F "$1" 2>/dev/null | awk '{print $1}' | sort -u)
    if [ -z "$packages" ]; then
        echo "Command '$1' not found, and no package found for installation."
        exit 1
    fi

    # Iterate over each package and check if it contains /usr/bin/$1
    found_package=""
    while IFS= read -r package; do
        if pacman -F -l "$package" 2>/dev/null | grep -q "bin/$1"; then
            found_package=$package
            break
        fi
    done <<< "$packages"

    if [ -z "$found_package" ]; then
        echo "Command '$1' not found, and no package found containing bin/$1."
        exit 1
    fi

    echo "Package found containing bin/$1: $found_package"

    echo "Installing $found_package..."
    if ! sudo pacman -S --noconfirm "$found_package" >/dev/null 2>&1; then
        echo "Failed to install $found_package."
        exit 1
    fi

    echo "Running $1..."
    exec "$@"
}

command_not_found_handler() {
    command_not_found "$@"
}
