FROM php:8.3-apache-bookworm

RUN curl -sL https://deb.nodesource.com/setup_22.x | bash -

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/home/.composer
RUN mkdir -p /home/.composer
RUN printf "deb http://http.us.debian.org/debian stable main contrib non-free" > /etc/apt/sources.list.d/nonfree.list

# npm is included in nodejs, see https://askubuntu.com/a/1432138
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    apt-transport-https \
    build-essential \
    ca-certificates \
    cron \
    curl \
    dma  \
    ghostscript \
    git \
    mariadb-client \
    nodejs \
    openssl \
    p7zip-full \
    p7zip-rar \ 
    sudo \
    supervisor \
    unrar \
    unzip \
    vim \
    wget  \
    zip \
    && rm -rf /var/lib/apt/lists/*

# auto install dependencies and remove libs after installing ext: https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions opcache intl
