#/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root"
  exit 1
fi

# Configure Debian package repositories
echo "
deb http://deb.debian.org/debian/ stable main
deb-src http://deb.debian.org/debian/ stable main

deb http://security.debian.org/debian-security stable-security/updates main
deb-src http://security.debian.org/debian-security stable-security/updates main
" > /etc/apt/sources.list

# Prevent apt from showing prompts
export DEBIAN_FRONTEND=noninteractive

# Update package list
apt-get update

# Install necessary packages
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

# Create directory for scripts
mkdir -p /opt/kito/scripts/

# Create script to upgrade system
echo "#/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

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

# Make script executable
chmod +x /opt/kito/scripts/upgradeSystem.sh

# Schedule script to run periodically
cat /etc/crontab | grep "/opt/kito/scripts/upgradeSystem.sh"          || (echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1)      * * $(shuf -i 0-6 -n 1) root    /opt/kito/scripts/upgradeSystem.sh" >> /etc/crontab) && (/etc/init.d/cron reload)

# Run script to upgrade system
/opt/kito/scripts/upgradeSystem.sh
