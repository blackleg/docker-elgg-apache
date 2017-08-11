FROM php:7.0-apache
MAINTAINER  Blackleg

# Install dependencies
RUN apt-get update && apt-get -y install git zlib1g-dev libpng-dev sendmail \ 
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable zip extension
RUN docker-php-ext-install zip pdo pdo_mysql gd
COPY php.ini /usr/local/etc/php/

# Install composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
     && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \ 
     && composer self-update \ 
     && composer global require "fxp/composer-asset-plugin:~1.1.4" \
     && rm -rf composer-setup.php

# Change listen port to 8000
EXPOSE 8000
RUN echo "Listen 8000" >> /etc/apache2/ports.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
COPY default.conf /etc/apache2/sites-available/000-default-8000.conf
RUN a2ensite 000-default-8000.conf

# Enable mod rewrite
RUN a2enmod rewrite

# Data volume
RUN mkdir -p /var/www/data && chown www-data:www-data /var/www/data && chmod g+w /var/www/data
VOLUME ["/var/www/data"]
