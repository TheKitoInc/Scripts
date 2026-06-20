#!/bin/bash
  
if [ ! -z "$1" ]; then
  NEW_HOSTNAME="$1"
  echo "[*] Setting hostname to $NEW_HOSTNAME..."
  hostnamectl set-hostname "$NEW_HOSTNAME"
  
  # Update /etc/hosts safely
  sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts || \
  echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
  exit 0  
else
  echo "[!] No hostname provided. Skipping..."
  exit 1
fi
