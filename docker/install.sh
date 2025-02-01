#!/usr/bin/bash

install_php_extension() {
    local extension=$1
    local output

    echo "[$(date +"%H:%M:%S")][$extension] Installing PHP extension"

    output=$(docker-php-ext-install "$extension" 2>&1)
    if [ $? -ne 0 ]; then
        echo "[$(date +"%H:%M:%S")][$extension] Failed to install PHP extension"
        echo "$output"
        echo "[$(date +"%H:%M:%S")][$extension] Failed to install extension"
        exit
    fi

    echo "[$(date +"%H:%M:%S")][$extension] PHP extension $extension installed"
}

install_php_extension opcache
install_php_extension pdo_mysql
install_php_extension zip
install_php_extension bcmath
install_php_extension exif
install_php_extension gd
install_php_extension intl
install_php_extension @composer
