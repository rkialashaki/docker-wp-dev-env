#!/bin/bash
# Script to build your wp environment once your wp-dev-env image is built
# and the compose stack is running.

# Define your own environment variables
##
EMAIL="your.email@yourdomain.com" # your email address for the wp installation
URL="127.0.0.1:8000" # the wp sitename defaults to '127.0.0.1:8000'
TITLE="wp-dev-env" # the title of your wp site defaults to 'wp-dev-env'
ADMIN_USER="wp_cli_test" # the wp admin user defaults to 'wp_cli_test'
ADMIN_PASSWORD="password1" # the wp admin password defaults to 'password1'

# Script body
sudo apt-get -y install nginx php-fpm
sudo sh -c "cat /home/wp/resources/nginx/wordpress-nginx.conf > /etc/nginx/sites-available/wordpress"
sudo sh -c "cat /home/wp/resources/nginx/wordpress-nginx2.conf > /etc/nginx/sites-available/wordpress2"
sudo sh -c "cat /home/wp/resources/nginx/nginx.conf > /etc/nginx/nginx.conf"

sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress
sudo rm -rf /etc/nginx/sites-enabled/default
sudo sed -i 's/listen\ \=\ \/run\/php\/php7.2-fpm.sock/listen\ \=\ 127.0.0.1\:9000/g' \
        /etc/php/7.2/fpm/pool.d/www.conf
sudo sed -i 's/post_max_size\ \=\ 8M/post_max_size\ \=\ 256M/g' \
        /etc/php/7.2/fpm/php.ini
sudo sed -i 's/upload_max_filesize\ \=\ 2M/upload_max_filesize\ \=\ 256M/g' \
        /etc/php/7.2/fpm/php.ini
sudo sed -i 's/\#\ maxmemory\ <bytes>/maxmemory\ 256mb/g' \
		/etc/redis/redis.conf
sudo sed -i 's/\#\ maxmemory-policy\ noeviction/maxmemory-policy\ allkeys-lru/g' \
		/etc/redis/redis.conf
sudo sed -i 's/bind\ 127.0.0.1\ ::1/bind\ 127.0.0.1/g' \
		/etc/redis/redis.conf

if [ -d ~/wordpress/wp-cli ]; then
    cd ~/wordpress/wp-cli &&
    git pull &&
    composer install --prefer-source
else
    cd ~/wordpress &&
    git clone https://github.com/wp-cli/wp-cli.git &&
    cd ~/wordpress/wp-cli &&
    composer install --prefer-source
fi

mkdir -p ~/wordpress/{public,logs}
cd ~/wordpress/public && ~/wordpress/wp-cli/bin/wp core download
cp ~/resources/config/wp-config.php ~/wordpress/public/wp-config.php
cd $HOME && ~/wordpress/wp-cli/bin/wp core install \
    --path=$HOME/wordpress/public/ \
    --url=$URL \
    --title=$TITLE \
    --admin_user=$ADMIN_USER \
    --admin_password=$ADMIN_PASSWORD \
    --admin_email=$EMAIL
~/wordpress/wp-cli/bin/wp theme install ~/resources/wordpress/themes/oceanwp.zip --path=$HOME/wordpress/public
~/wordpress/wp-cli/bin/wp plugin install ~/resources/wordpress/plugins/ocean-extra.zip --path=$HOME/wordpress/public
~/wordpress/wp-cli/bin/wp plugin install ~/resources/wordpress/plugins/elementor.zip --path=$HOME/wordpress/public
#~/wordpress/wp-cli/bin/wp theme install ~/resources/wordpress/themes/mesmerize.latest.zip --path=$HOME/wordpress/public
#~/wordpress/wp-cli/bin/wp plugin install ~/resources/wordpress/plugins/mesmerize-companion.zip --path=$HOME/wordpress/public
#~/wordpress/wp-cli/bin/wp plugin install ~/resources/wordpress/plugins/contact-form-latest.zip --path=$HOME/wordpress/public

sudo service nginx stop
sudo service php7.2-fpm stop
sudo service redis-server stop
sudo service redis-server start
sudo service php7.2-fpm start
sudo service nginx start

sudo chgrp www-data -R ~/wordpress
sudo chmod g+w -R ~/wordpress

alias wp=~/wordpress/wp-cli/bin/wp
echo "alias wp=~/wordpress/wp-cli/bin/wp" >> ~/.bashrc
