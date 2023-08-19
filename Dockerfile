FROM php:8.2.9-fpm

ARG uid=1000
ARG gid=1000

RUN usermod -u $uid www-data && groupmod -g $gid www-data

RUN apt-get update && apt-get install -y python \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y

RUN apt-get upgrade -y

RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN apt-get update && apt-get install -y \
        libsqlite3-dev \
        libwebp-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libxpm-dev \
        libpng-dev \
        zlib1g-dev \
        libzip-dev \
        git \
        unzip \
        default-mysql-client \
        supervisor \
        nginx

RUN docker-php-ext-configure gd \
    --with-jpeg \
    --with-freetype

RUN docker-php-ext-install -j$(nproc) gd


RUN docker-php-ext-install zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    ln -s $(composer config --global home) /root/composer
ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1

RUN mkdir -p /var/www/.composer && chown www-data:www-data /var/www/.composer

# ADD php.ini /etc/php/conf.d/
# ADD php.ini /usr/local/etc/php/conf.d
# ADD php.ini /etc/php/cli/conf.d/
# ADD php-fpm.conf /etc/php/php-fpm.d/

# COPY nginx.conf /etc/nginx/nginx.conf
# # Configure supervisord
# COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# WORKDIR /var/www/drupal

RUN apt-get update && apt-get install -y libc-dev

EXPOSE 8080 9000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
