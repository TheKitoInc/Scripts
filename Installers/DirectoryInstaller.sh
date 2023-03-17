#!/bin/sh

mkdir -p /opt/kito/scripts/run/minutely
mkdir -p /opt/kito/scripts/run/hourly
mkdir -p /opt/kito/scripts/run/daily
mkdir -p /opt/kito/scripts/run/weekly
mkdir -p /opt/kito/scripts/run/monthly
mkdir -p /opt/kito/scripts/run/yearly

mkdir -p /opt/kito/scripts/start/up
mkdir -p /opt/kito/scripts/start/year
mkdir -p /opt/kito/scripts/start/month
mkdir -p /opt/kito/scripts/start/week
mkdir -p /opt/kito/scripts/start/day
mkdir -p /opt/kito/scripts/start/hour

cat /etc/crontab | grep "/opt/kito/scripts/run/minutely"        || echo "* *       * * *   root    /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/run/minutely" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/run/hourly"          || echo "$(shuf -i 0-59 -n 1) * * * *   root    /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/run/hourly" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/run/daily"           || echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1)      * * *   root    /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/run/daily" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/run/weekly"          || echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1)      * * $(shuf -i 0-6 -n 1) root    /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/run/weekly" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/run/monthly"         || echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1)      $(shuf -i 1-28 -n 1) * *        root    /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/run/monthly" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/run/yearly"          || echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1)      $(shuf -i 1-28 -n 1) $(shuf -i 1-12 -n 1) *     root   /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/run/yearly" >> /etc/crontab

cat /etc/crontab | grep "/opt/kito/scripts/start/year"          || echo "0 0       1 1 *     root   /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/start/year" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/start/month"         || echo "0 0       1 * *     root   /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/start/month" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/start/week"          || echo "0 0       * * 1     root   /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/start/week" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/start/day"           || echo "0 0       * * *     root   /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/start/day" >> /etc/crontab
cat /etc/crontab | grep "/opt/kito/scripts/start/hour"          || echo "0 *       * * *     root   /opt/kito/scripts/runDirectory.sh /opt/kito/scripts/start/hour" >> /etc/crontab

wget https://raw.githubusercontent.com/TheKito/Scripts/master/runDirectory.sh -O /opt/kito/scripts/runDirectory.sh
chmod +x /opt/kito/scripts/runDirectory.sh
