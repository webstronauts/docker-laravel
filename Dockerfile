# Use Alpine v3.7.
FROM alpine:3.7

# Image maintainer.
LABEL maintainer="robin@webstronauts.co"

# Expose a sensible default port.
EXPOSE 8000

RUN addgroup -g 82 www-data \
    && adduser -u 82 -G www-data -s /bin/sh -D www-data

# Trust the codecasts' public key to trust the packages.
ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# Make sure you can use HTTPS.
RUN apk add --no-cache ca-certificates \
    # And add the APK repository.
    && echo "@php https://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories

# Install Nginx, PHP, Node.js and some additional extensions. Notice the @php is
# required to avoid getting default php packages from alpine instead.
RUN apk add --no-cache \
      bash \
      curl \
      nginx \
      nodejs \
      php@php \
      php-apcu@php \
      php-ctype@php \
      php-curl@php \
      php-dom@php \
      php-fpm@php \
      php-json@php \
      php-mbstring@php \
      php-opcache@php \
      php-openssl@php \
      php-pcntl@php \
      php-pdo@php \
      php-pdo_pgsql@php \
      php-phar@php \
      php-posix@php \
      php-session@php \
      php-xml@php \
      php-zlib@php \
      supervisor \
      tini \
      yarn \
    && ln -sf /usr/bin/php7 /usr/bin/php \
    && ln -sf /usr/sbin/php-fpm7 /usr/sbin/php-fpm \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /run/nginx \
    && mkdir -p /run/php

# Expose installed executables to the $PATH env var.
ENV PATH "~/.composer/vendor/bin:./vendor/bin:${PATH}"

# Download and install Composer.
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/ \
    && ln -s /usr/bin/composer.phar /usr/bin/composer

ADD rootfs /

RUN mkdir /app \
    && chmod -R 775 /app \
    && chown -R www-data:www-data /app

WORKDIR /app

ENTRYPOINT ["/sbin/tini", "--"]

CMD [ "supervisord", "--nodaemon" ]
