# Use Alpine v3.7.
FROM alpine:3.7

# Image maintainer.
LABEL maintainer="robin@webstronauts.co"

# Expose a sensible default port.
EXPOSE 8000

RUN addgroup -g 1000 www-data \
    && adduser -u 1000 -G www-data -s /bin/sh -D www-data

# Trust the codecasts' public key to trust the packages.
ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# Make sure you can use HTTPS.
RUN apk add --no-cache ca-certificates \
    # And add the APK repository.
    && echo "@php https://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories

# Install PHP and some extensions. Notice the @php is required to
# avoid getting default php packages from alpine instead.
RUN apk add --no-cache \
      curl \
      nginx \
      supervisor \
      tini \
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
    && ln -s /usr/bin/php7 /usr/bin/php \
    && ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm \
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

# Copy over Composer and NPM files first and install any dependencies.
# Because we do not copy "all" application files, we can make better
# use of Docker's layered caching mechanism.
ONBUILD COPY composer* /app/

ONBUILD RUN composer install \
      --no-autoloader \
      --no-dev \
      --no-interaction \
      --no-scripts \
      --no-suggest \
      --prefer-dist \
    && composer clear-cache

ONBUILD COPY . .

ONBUILD RUN chown -R www-data:www-data \
      /app/bootstrap/cache \
      /app/storage

# We can generate the autoloader only when all project's files are added.
ONBUILD RUN composer dump-autoload \
      --optimize \
      --apcu

ENTRYPOINT ["/sbin/tini", "--"]

CMD [ "supervisord", "--nodaemon" ]
