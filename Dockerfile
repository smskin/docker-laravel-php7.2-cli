FROM php:7.2-cli

#####################################
#  Clean up APT:
#####################################
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG TZ=Europe/Moscow
ARG APP_CODE_PATH_CONTAINER=/var/www/html

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        apt-utils \
        unzip \
        curl \
        git \
        wget \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libwebp-dev \
        libjpeg-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libxpm-dev \
        libmcrypt-dev \
        libmagickwand-dev \
        libxml2-dev \
        libzip-dev \
        zip

# Install soap extention
RUN docker-php-ext-install soap

# Install for image manipulation
RUN docker-php-ext-install exif

# Install the PHP mcrypt extention (from PECL, mcrypt has been removed from PHP 7.2)
RUN pecl install mcrypt-1.0.1
RUN docker-php-ext-enable mcrypt

# Install the PHP pcntl extention
RUN docker-php-ext-install pcntl

# Install the PHP zip extention
RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-install zip

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql

# Install the PHP bcmath extension
RUN docker-php-ext-install bcmath

#####################################
# Imagick:
#####################################

RUN pecl install imagick && \
    docker-php-ext-enable imagick

#####################################
# GD:
#####################################

RUN docker-php-ext-configure gd \
       --with-gd \
           --with-webp-dir \
           --with-jpeg-dir \
           --with-png-dir \
           --with-zlib-dir \
           --with-xpm-dir
RUN docker-php-ext-install gd

#####################################
# PHP Memcached:
#####################################

# Install the php memcached extension
RUN pecl install memcached && \
    docker-php-ext-enable memcached

#####################################
# NodeJS 8.X:
#####################################
RUN apt-get install -y \
    gnupg \
    gnupg2

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

#####################################
# Composer:
#####################################

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

#####################################
# VIM:
#####################################
RUN apt-get install -y \
    vim

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#
COPY ./conf/php.ini /usr/local/etc/php/php.ini

#####################################
#  Clean up APT:
#####################################
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${APP_CODE_PATH_CONTAINER}