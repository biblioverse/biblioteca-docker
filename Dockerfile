FROM php:8.3-apache-bookworm

RUN curl -sL https://deb.nodesource.com/setup_22.x | bash -

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/home/.composer
RUN mkdir -p /home/.composer
RUN printf "deb http://http.us.debian.org/debian stable main contrib non-free" > /etc/apt/sources.list.d/nonfree.list

# auto install dependencies and remove libs after installing ext: https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

ENV PACKAGES="apt-transport-https ca-certificates cron dma ghostscript mariadb-client nodejs openssl supervisor"
ENV PACKAGES_DEV="curl git sudo vim wget"
ENV PACKAGES_COMPRESS="p7zip-full p7zip-rar unrar unzip zip"
ENV PACKAGES_PHP="libicu72"
ENV PACKAGES_PHP_VOLATILE="libicu-dev"

ENV PHP_PACKAGES="opcache pdo_mysql zip bcmath exif gd imagick @composer"

# npm is included in nodejs, see https://askubuntu.com/a/1432138
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y ${PACKAGES} ${PACKAGES_DEV} ${PACKAGES_COMPRESS} ${PACKAGES_PHP} ${PACKAGES_PHP_VOLATILE} \
    && install-php-extensions ${PHP_PACKAGES} \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl \
    && apt-get purge ${PACKAGES_PHP_VOLATILE} -y \
    && rm -rf /var/lib/apt/lists/*

# Install kepubify (from https://github.com/linuxserver/docker-calibre-web/blob/master/Dockerfile)
COPY docker/get_kepubify_url.sh /usr/bin/get_kepubify_url.sh
RUN chmod +x /usr/bin/get_kepubify_url.sh ; \
    URL=$(/usr/bin/get_kepubify_url.sh) && curl -f -vvv -o /usr/bin/kepubify -L "$URL" && chmod +x /usr/bin/kepubify

RUN a2enmod rewrite

COPY docker/001-biblioteca.conf /etc/apache2/sites-enabled/001-biblioteca.conf
RUN touch /var/www/.bash_history && chmod 777 /var/www/.bash_history
# Run from unprivileged port 8080 only
RUN sed -e 's/Listen 80/Listen 8080/g' -i /etc/apache2/ports.conf

COPY ./docker/dma.conf /etc/dma/dma.conf
COPY ./docker/biblioteca.ini /usr/local/etc/php/conf.d/biblioteca.ini
COPY ./docker/policy.xml /etc/ImageMagick-6/policy.xml

ARG UNAME=www-data
ARG UGROUP=www-data
ARG UID=1000
ARG GID=1000
RUN usermod  --uid $UID $UNAME
RUN groupmod --gid $GID $UGROUP

RUN mkdir -p /var/www/.npm && chown -R $UID:$GID /var/www/.npm

USER www-data

WORKDIR /var/www/html
CMD ["docker-php-entrypoint", "apache2-foreground"]
