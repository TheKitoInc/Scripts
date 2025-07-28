#!/bin/bash

# Prevent script to continue if an error occurs
set -e

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root"
  exit 1
fi

# Remove conflicting packages
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  apt-get remove $pkg -y
done

# Update package list
apt-get update

# Install necessary dependencies
apt-get install ca-certificates curl -y

# Create directory for apt keyrings
install -m 0755 -d /etc/apt/keyrings

# Download and add Docker's GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's repository to apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again
apt-get update

# Install Docker and its components
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Disable iptables in Docker configuration
echo '{"iptables": false, "ipv6": true, "fixed-cidr-v6": "fd00:dead:beef::/64"}' > /etc/docker/daemon.json

# Restart Docker service
systemctl restart docker

# Verify Docker installation
docker run hello-world
