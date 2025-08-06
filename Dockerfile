FROM dunglas/frankenphp:1-php8.3

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/home/.composer
RUN mkdir -p /home/.composer
RUN printf "deb http://http.us.debian.org/debian stable main contrib non-free" > /etc/apt/sources.list.d/nonfree.list

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    apt-transport-https \
    dma  \
    ghostscript \
    mariadb-client \
    openssl \
    p7zip-full \
    p7zip-rar \
    unrar \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions \
	pdo_mysql \
	gd \
	intl \
	zip \
	opcache \
	imagick \
	exif \
	bcmath \
    apcu \
    @composer

# Install kepubify (from https://github.com/linuxserver/docker-calibre-web/blob/master/Dockerfile)
COPY docker/get_kepubify_url.sh /usr/bin/get_kepubify_url.sh
RUN chmod +x /usr/bin/get_kepubify_url.sh ; \
    URL=$(/usr/bin/get_kepubify_url.sh) && curl -f -vvv -o /usr/bin/kepubify -L "$URL" && chmod +x /usr/bin/kepubify

RUN touch /var/www/.bash_history && chmod 777 /var/www/.bash_history

COPY ./docker/dma.conf /etc/dma/dma.conf
COPY ./docker/biblioteca.ini /usr/local/etc/php/conf.d/biblioteca.ini
COPY ./docker/policy.xml /etc/ImageMagick-6/policy.xml

RUN curl -sL https://deb.nodesource.com/setup_22.x | bash -

RUN mkdir -p /var/www/.npm && chown -R $UID:$GID /var/www/.npm


WORKDIR /var/www/html
COPY docker/Caddyfile /etc/caddy/Caddyfile

EXPOSE 8080
EXPOSE 8443
EXPOSE 8443/udp

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
