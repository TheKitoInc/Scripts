#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

echo "=== Updating package lists ==="

apt-get update

echo "=== Installing system packages ==="

apt-get install -y cron
apt-get install -y supervisor
apt-get install -y rsync
apt-get install -y net-tools
apt-get install -y htop
apt-get install -y tree
apt-get install -y curl
apt-get install -y mutt
apt-get install -y iptables
apt-get install -y ipset