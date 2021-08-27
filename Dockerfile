FROM alpine:3.13
LABEL maintainer="help@cyber01.ru"

RUN apk --update --no-cache add \
        php7 \
        php7-bcmath \
        php7-dom \
        php7-ctype \
        php7-curl \
        php7-fileinfo \
        php7-fpm \
        php7-gd \
        php7-iconv \
        php7-intl \
        php7-json \
        php7-mbstring \
        php7-mcrypt \
        php7-mysqlnd \
        php7-opcache \
        php7-openssl \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-pdo_sqlite \
        php7-phar \
        php7-posix \
        php7-simplexml \
        php7-session \
        php7-soap \
        php7-tokenizer \
        php7-xml \
        php7-xmlreader \
        php7-xmlwriter \
        php7-pecl-amqp \
        php7-pecl-imagick \
        php7-zip \
    && rm -rf /var/cache/apk/*

RUN set -eux; \
	addgroup -g 82 -S www-data; \
	adduser -u 82 -D -S -G www-data www-data

RUN set -eux; \
	[ ! -d /var/www ]; \
	mkdir -p /var/www; \
	chown www-data:www-data /var/www; \
	chmod 777 /var/www; \
    chown -R www-data:www-data /var/log/php7;

RUN set -eux; \
	{ \
		echo '[www]'; \
		echo 'listen = 9000'; \
		echo 'user = www-data'; \
		echo 'group = www-data'; \
		echo 'listen.owner = www-data'; \
		echo 'listen.group = www-data'; \
		echo 'chdir = /var/www'; \
		echo 'clear_env = no'; \
		echo 'catch_workers_output = yes'; \
	} | tee /etc/php7/php-fpm.d/zz-fpm-docker.conf; \
	{ \
		echo 'date.timezone = Europe/Moscow'; \
		echo 'max_execution_time = 600'; \
		echo 'request_terminate_timeout = 600'; \
		echo 'post_max_size = 1024M'; \
		echo 'upload_max_filesize = 1024M'; \
		echo 'error_log=/dev/stderr'; \
	} | tee /etc/php7/conf.d/50-zz-ini-docker.conf

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
    && chown -R www-data:www-data /usr/local/bin/composer
    
WORKDIR /var/www
EXPOSE 9000

CMD ["php-fpm7", "-F"]
