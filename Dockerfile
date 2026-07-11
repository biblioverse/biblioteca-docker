FROM php:8.5.8-apache-trixie

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/home/.composer

RUN printf "deb http://http.us.debian.org/debian trixie main contrib non-free non-free-firmware\n" \
      > /etc/apt/sources.list.d/nonfree.list

# auto install dependencies and remove libs after installing ext: https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
COPY docker/install.sh /usr/bin/install.sh

# npm is included in nodejs, see https://askubuntu.com/a/1432138
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        dma \
        ghostscript \
        mariadb-client \
        nodejs \
        openssl \
        p7zip-full \
        p7zip-rar \
        unrar \
        unzip \
        zip \
    && chmod +x /usr/bin/install.sh \
    && /usr/bin/install.sh \
        intl \
        gd \
        pdo_mysql \
        zip \
        bcmath \
        exif \
        imagick \
        @composer \
    && rm -rf /var/lib/apt/lists/*

# Install kepubify (from https://github.com/linuxserver/docker-calibre-web/blob/master/Dockerfile)
COPY docker/get_kepubify_url.sh /usr/bin/get_kepubify_url.sh
RUN chmod +x /usr/bin/get_kepubify_url.sh \
    && URL=$(/usr/bin/get_kepubify_url.sh) \
    && curl -fsSL -o /usr/bin/kepubify "$URL" \
    && chmod +x /usr/bin/kepubify

COPY docker/001-biblioteca.conf /etc/apache2/sites-enabled/001-biblioteca.conf
COPY ./docker/dma.conf /etc/dma/dma.conf
COPY ./docker/biblioteca.ini /usr/local/etc/php/conf.d/biblioteca.ini
COPY ./docker/policy.xml /etc/ImageMagick-7/policy.xml

ARG UNAME=www-data
ARG UGROUP=www-data
ARG UID=1000
ARG GID=1000

RUN a2enmod rewrite \
    && sed -e 's/Listen 80/Listen 8080/g' -i /etc/apache2/ports.conf \
    && usermod  --uid "$UID" "$UNAME" \
    && groupmod --gid "$GID" "$UGROUP" \
    && touch /var/www/.bash_history \
    && chmod 777 /var/www/.bash_history \
    && mkdir -p /home/.composer /var/www/.npm \
    && chown -R "$UID:$GID" /var/www/.npm /home/.composer

USER www-data

WORKDIR /var/www/html
CMD ["docker-php-entrypoint", "apache2-foreground"]
