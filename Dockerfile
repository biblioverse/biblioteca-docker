FROM php:8.2-apache-bullseye

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /home/.composer
RUN mkdir -p /home/.composer

RUN  apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    # Tools
    vim git curl cron wget zip unzip \
    # other
    apt-transport-https \
    dma  \
    build-essential \
    ca-certificates \
    mariadb-client \
    openssl \
    supervisor \
    nodejs \
    sudo && rm -rf /var/lib/apt/lists/*

# auto install dependencies and remove libs after installing ext: https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/


RUN install-php-extensions \
    iconv \
    opcache \
    xml \
    intl \
    pdo_mysql \
    curl \
    json \
    zip \
    bcmath \
    mbstring \
    exif \
    fileinfo \
    dom \
    gd \
    imagick \
    calendar



RUN apt-get purge -y --auto-remove
RUN a2enmod rewrite

# Install composer
RUN install-php-extensions @composer

COPY docker/001-biblioteca.conf /etc/apache2/sites-enabled/001-biblioteca.conf

# Run from unprivileged port 8080 only
RUN sed -e 's/Listen 80/Listen 8080/g' -i /etc/apache2/ports.conf

COPY ./docker/dma.conf /etc/dma/dma.conf
COPY ./docker/biblioteca.ini /usr/local/etc/php/conf.d/biblioteca.ini

WORKDIR /var/www/html
CMD ["docker-php-entrypoint", "apache2-foreground"]
