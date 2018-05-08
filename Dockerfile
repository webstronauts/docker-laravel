FROM nginx:1.13 AS nginx
FROM php:7.2-fpm

# Expose NGINX's default port
EXPOSE 80

# Expose installed executables to the $PATH env var.
ENV PATH "~/.composer/vendor/bin:./vendor/bin:./node_modules/.bin:${PATH}"

# Expose Node.js binary path as env var.
ENV NODE_PATH "/usr/bin/node"

# Allow Composer to be run as root.
ENV COMPOSER_ALLOW_SUPERUSER 1

# Install base packages.
RUN apt-get update \
      && apt-get install -y gnupg

# Add official Node.js and Yarn repositories.
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
      && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
      && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install required packages.
RUN apt-get update \
      && apt-get install -y autoconf build-essential git libpq-dev nginx nodejs ruby-full yarn zip \
      && rm -rf /var/lib/apt/lists/*

# Install required PHP extensions.
RUN docker-php-ext-install opcache pcntl pdo_pgsql

# Install additional extensions through PECL.
RUN pecl install apcu mongodb xdebug \
      && docker-php-ext-enable apcu mongodb

# Enable XDebug when PHP executable is direcly accessed.
RUN echo "alias php=\"php -dzend_extension=xdebug.so\"" > /root/.bashrc

# Copy "Docker optimized" NGINX configuration file from previous stage.
COPY --from=nginx /etc/nginx/nginx.conf /etc/nginx/nginx.conf

# Download and install Composer.
RUN curl -sS https://getcomposer.org/installer | php \
      && mv composer.phar /usr/local/bin/ \
      && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install Foreman (used by heroku-buildpack-php).
RUN gem install -no-ri --no-rdoc foreman

# Create application-specific directory.
RUN mkdir /app

# Set application directory as default working directory.
WORKDIR /app

# Copy over Composer and NPM files first and install any dependencies.
# Because we do not copy "all" application files, we can make better
# use of Docker's layered caching mechanism.
ONBUILD COPY composer* package.json yarn.lock /app/

# Install all dependencies.
ONBUILD RUN composer install --prefer-dist --no-interaction --no-autoloader --no-scripts \
      && composer clear-cache \
      && yarn install --frozen-lockfile \
      && yarn cache clean

# Copy all other files.
ONBUILD COPY . .

# Dump Composer's autoloader, optimized with APCu.
ONBUILD RUN composer dump-autoload --optimize --apcu

# Compile all front-end assets.
ONBUILD RUN yarn build
