FROM php:7.0-fpm-jessie
MAINTAINER Dave Lane <dave@oerfoundation.org> (@lightweight)

RUN apt-get update && apt-get install -y software-properties-common apt-utils
ENV DEBIAN_FRONTEND="noninteractive"
#RUN add-apt-repository ppa:ondrej/php

# Install PHP extensions
RUN apt-get update && apt-get install -y apt-utils git less libbz2-dev libc-client-dev \
    libcurl4-gnutls-dev libicu-dev libkrb5-dev libmcrypt-dev libpng-dev \
    libpspell-dev libssl-dev libxml2-dev telnet unzip zip
RUN apt-get install -y net-tools vim dnsutils
# install cron and msmtp for outgoing email
RUN apt-get install -y cron msmtp
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-install bz2 curl imap intl mbstring mcrypt \
    pspell opcache soap xmlrpc zip

# install PHPRedis
ENV PHPREDIS_VERSION 3.1.4
RUN docker-php-source extract \
    && curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis \
    && docker-php-source delete

# install GD
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# install APCU and YAML
RUN apt-get install -y \
    libyaml-dev unzip
RUN pecl install yaml-2.0.0
RUN docker-php-ext-enable yaml
RUN pecl install apcu
RUN docker-php-ext-enable apcu

# clean up all Apt stuff
RUN rm -rf /var/lib/apt/lists/*

# address app-specific config requirements
RUN echo "log_errors = on" > /usr/local/etc/php/conf.d/php.ini
RUN echo "display_errors = off" >> /usr/local/etc/php/conf.d/php.ini
RUN echo "always_populate_raw_post_data = -1" >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'date.timezone = "Pacific/Auckland"' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'cgi.fix_pathinfo = 0' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'sendmail_path = /usr/bin/msmtp -t' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'upload_max_filesize = 100M' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'post_max_size = 150M' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'memory_limit = 250M' >> /usr/local/etc/php/conf.d/php.ini
# OpCache work
RUN echo '[opcache]' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'opcache.enable = 1' >> /usr/local/etc/php/conf.d/php.ini
#RUN echo 'opcache.enable_cli = 1' >> /usr/local/etc/php/conf.d/php.ini
#RUN echo 'opcache.interned_strings_buffer = 8' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'opcache.memory_consumption = 128' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'opcache.max_accelerated_files = 8000' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'opcache.revalidate_freq = 60' >> /usr/local/etc/php/conf.d/php.ini
#RUN echo 'opcache.fast_shutdown = 1' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'opcache.use_cwd = 1' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'opcache.validate_timestamps = 1' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'opcache.save_comments = 1' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'opcache.enable_file_override = 0' >> /usr/local/etc/php/conf.d/php.ini

# the PHP-fpm configuration
RUN echo 'security.limit_extensions = .php' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'catch_workers_output = yes' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'php_flag[display_errors] = off' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'php_admin_value[error_log] = /usr/local/var/log/fpm-php.www.log' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'php_admin_flag[log_errors] = on' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'php_admin_value[memory_limit] = 250M' >> /usr/local/etc/php-fpm.d/www.conf

VOLUME /var/www/html

# Copy init scripts and custom .htaccess
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
