from ubuntu:18.04

RUN apt-get update && apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install curl git php-cli sudo \
        php-mbstring php-cli-prompt vim less sendmail tzdata net-tools unzip \
        php-common php-composer-semver php-composer-spdx-licenses php-mysql \
        php-json-schema php-psr-log php-symfony-console php-xml php-zip \
        php-symfony-finder php-symfony-process php-symfony-filesystem wget \
        mysql-client php-fpm nginx redis-server php-redis php-gd
RUN useradd -r -m -s /bin/bash -u 1000 wp
RUN usermod -a -G www-data wp
RUN touch /etc/sudoers.d/wp && echo "wp ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/wp
RUN cd ~ && curl -sS https://getcomposer.org/installer -o ~/composer-setup.php
RUN php ~/composer-setup.php --install-dir=/usr/local/bin --filename=composer

USER wp
WORKDIR /home/wp
