#/bin/bash

echo "
deb http://deb.debian.org/debian/ stable main
deb-src http://deb.debian.org/debian/ stable main

deb http://security.debian.org/debian-security stable/updates main
deb-src http://security.debian.org/debian-security stable/updates main
" > /etc/apt/sources.list

export DEBIAN_FRONTEND=noninteractive;

apt-get update
apt-get upgrade -dy
apt-get dist-upgrade -dy
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get install htop -y
apt-get install tree -y
apt-get install rsync -y
apt-get install net-tools -y
apt-get install curl -y
apt-get install mutt -y

mkdir -pv /Data
mkdir -pv /Data/Scripts
