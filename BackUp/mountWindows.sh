#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters: hostName domain user password"
    exit 1
fi



HOST=$(echo "$1" | cut -d "." -f1)
DOMA=$2
USER=$3
PASS=$4
IP=$(getent hosts "$1" | cut -d' ' -f1 | head -n1)

for x in {a..z}
do
        FOLDER_MOUNT=/mount/$HOST/Drive_$x

        (mount | grep "$FOLDER_MOUNT" > /dev/null) && continue

        mkdir -p "$FOLDER_MOUNT" && \
        (mount.cifs "//$IP/$x\$" "$FOLDER_MOUNT" -o user=$USER,password=$PASS,domain=$DOMA,sec=ntlmssp,rw,vers=2.0 2> /dev/null) || \
        rmdir "$FOLDER_MOUNT"
done
