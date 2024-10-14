#/bin/bash

export DEBIAN_FRONTEND=noninteractive;

FQDN=$(grep -m 1 . /etc/hostname)
FQDN=${FQDN,,}
DOMAIN=$(echo $FQDN | cut -d. -f2-255)

apt-get update || exit 101
apt-get install curl -y || exit 102

curl "https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb" > "/tmp/deb$$.deb" && dpkg -i "/tmp/deb$$.deb" ; rm -f "/tmp/deb$$.deb"

/etc/init.d/zabbix-agent stop

apt-get update || exit 103
apt-get install zabbix-agent -y || exit 104

cat /dev/null > /etc/zabbix/zabbix_agentd.conf
echo 'PidFile=/run/zabbix/zabbix_agentd.pid' >> /etc/zabbix/zabbix_agentd.conf
echo 'LogFile=/var/log/zabbix-agent/zabbix_agentd.log' >> /etc/zabbix/zabbix_agentd.conf
echo 'Server=127.0.0.1' >> /etc/zabbix/zabbix_agentd.conf
echo 'ListenPort=10050' >> /etc/zabbix/zabbix_agentd.conf
echo 'HostMetadataItem=system.uname' >> /etc/zabbix/zabbix_agentd.conf

echo "ServerActive=127.0.0.1:10051,zabbix.private.$DOMAIN:10051,zabbix.$DOMAIN:10051" >> /etc/zabbix/zabbix_agentd.conf

mkdir -p /etc/zabbix/zabbix_agentd.conf.d/
echo 'Include=/etc/zabbix/zabbix_agentd.conf.d/*.conf' >> /etc/zabbix/zabbix_agentd.conf

/etc/init.d/zabbix-agent restart
