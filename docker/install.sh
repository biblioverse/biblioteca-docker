#!/usr/bin/bash

# npm is included in nodejs, see https://askubuntu.com/a/1432138
PACKAGES="apt-transport-https ca-certificates cron dma ghostscript mariadb-client nodejs openssl supervisor"
PACKAGES_DEV="curl git sudo vim wget"
PACKAGES_COMPRESS="p7zip-full p7zip-rar unrar unzip zip"

install_php_extension() {
    local extension=$1
    local output

    echo "Installing PHP extension $extension"

    output=$(docker-php-ext-install "$extension" 2>&1)
    if [ $? -ne 0 ]; then
        echo "Failed to install PHP extension $extension:"
        echo "$output"
        echo "Failed to install $extension"
        exit
    fi

    echo "[ OK ] PHP extension $extension installed"
}

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y ${PACKAGES} ${PACKAGES_DEV} ${PACKAGES_COMPRESS} ${PACKAGES_PHP} ${PACKAGES_PHP_VOLATILE}

install_php_extension opcache
install_php_extension pdo_mysql
install_php_extension zip
install_php_extension bcmath
install_php_extension exif
install_php_extension gd
install_php_extension intl
install_php_extension @composer

rm -rf /var/lib/apt/lists/*
