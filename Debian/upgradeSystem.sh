#/bin/bash

echo "=============================== UPGRADE SYSTEM ==============================="

echo "
deb http://deb.debian.org/debian/ stable main
deb-src http://deb.debian.org/debian/ stable main

deb http://security.debian.org/debian-security stable-security/updates main
deb-src http://security.debian.org/debian-security stable-security/updates main
" > /etc/apt/sources.list

export DEBIAN_FRONTEND=noninteractive;

apt-get update
apt-get upgrade -dy
apt-get dist-upgrade -dy
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y

test -f /var/run/reboot-required && reboot
