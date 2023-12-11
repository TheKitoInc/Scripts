#/bin/bash

URLFiles=https://raw.githubusercontent.com/TheKito/Scripts/main/Install/PHP

apt-get update || exit 1
apt-get install curl -y || exit 2
apt-get install php-gd -y || exit 3
apt-get install php-cli -y || exit 4
apt-get install php-curl -y || exit 5
apt-get install php-mysqli -y || exit 6
apt-get install php-imagick -y || exit 7
apt-get install php-mbstring -y || exit 8
apt-get install php-memcache -y || exit 9
apt-get install php-memcached -y || exit 10

