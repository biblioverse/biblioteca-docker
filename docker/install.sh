#!/usr/bin/bash

install_php_extension() {
    local extension=$1
    local output

    echo "[$(date +"%H:%M:%S")][$extension] Installing PHP extension"

    output=$(install-php-extensions "$extension" 2>&1)
    if [ $? -ne 0 ]; then
        echo "[$(date +"%H:%M:%S")][$extension] Failed to install PHP extension"
        echo "$output"
        echo "[$(date +"%H:%M:%S")][$extension] Failed to install extension"
        exit 1
    fi

    echo "[$(date +"%H:%M:%S")][$extension] PHP extension $extension installed"
}

for extension in "$@"; do
    install_php_extension "$extension"
done
