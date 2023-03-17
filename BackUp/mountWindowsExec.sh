#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters: hostName domain user password callback"
    exit 1
fi

HOST=$(echo "$1" | cut -d "." -f1)
DOMA=$2
USER=$3
PASS=$4
CMD=$5
IP=$(getent hosts "$1" | cut -d' ' -f1 | head -n1)


FOLDER_MOUNT=/mount/$HOST/Drive_c

mkdir -p "$FOLDER_MOUNT"

(mount | grep "$FOLDER_MOUNT" > /dev/null) || (mount.cifs "//$IP/c\$" "$FOLDER_MOUNT" -o user=$USER,password=$PASS,domain=$DOMA,sec=ntlmssp,ro,vers=2.0)
(mount | grep "$FOLDER_MOUNT" > /dev/null) && $CMD "$FOLDER_MOUNT"
(mount | grep "$FOLDER_MOUNT" > /dev/null) && (umount "$FOLDER_MOUNT")
