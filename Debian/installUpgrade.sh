#/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "
deb http://deb.debian.org/debian/ stable main
deb-src http://deb.debian.org/debian/ stable main

deb http://security.debian.org/debian-security stable-security/updates main
deb-src http://security.debian.org/debian-security stable-security/updates main
" > /etc/apt/sources.list

mkdir -p /opt/kito/scripts/

echo "#/bin/bash

export DEBIAN_FRONTEND=noninteractive;

apt-get update
apt-get upgrade -dy
apt-get dist-upgrade -dy
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y

test -f /var/run/reboot-required && reboot

exit 0

" > /opt/kito/scripts/upgradeSystem.sh

chmod +x /opt/kito/scripts/upgradeSystem.sh

apt-get update
apt-get install cron -y
apt-get install supervisor -y
apt-get install rsync -y
apt-get install net-tools -y
apt-get install htop -y
apt-get install tree -y
apt-get install curl -y
apt-get install mutt -y
apt-get install net-tools -y
apt-get install iptables -y
apt-get install ipset -y

cat /etc/crontab | grep "/opt/kito/scripts/upgradeSystem.sh"          || (echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1)      * * $(shuf -i 0-6 -n 1) root    /opt/kito/scripts/upgradeSystem.sh" >> /etc/crontab) && (/etc/init.d/cron reload)

/opt/kito/scripts/upgradeSystem.sh
