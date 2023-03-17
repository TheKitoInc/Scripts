#!/bin/bash
HOST=$(echo "$1" | cut -d "." -f1)
DOMA=$2
USER=$3
PASS=$4
IP=$(getent hosts "$1" | cut -d' ' -f1 | head -n1)

FOLDER_MOUNT=/mount/$HOST/Drive_c

mkdir -p "$FOLDER_MOUNT"

(mount | grep "$FOLDER_MOUNT" > /dev/null) || (mount.cifs "//$IP/c\$" "$FOLDER_MOUNT" -o user=$USER,password=$PASS,domain=$DOMA,sec=ntlmssp,rw,vers=2.0)


SRC=$FOLDER_MOUNT/Respaldo/
SRC_Shadow=$FOLDER_MOUNT/Respaldo/ShadowCopy
DST=/Storage/Master/$HOST/Drive_c/Respaldo/
HST=/Storage/History/$HOST/$(date "+%Y/%m/%d/%H")/Drive_c/Respaldo/

echo SRC: $SRC
echo DST: $DST
echo HST: $HST

mkdir -p "$DST" && \
mkdir -p "$HST" && \
rsync -arvu --exclude "ShadowCopy" --delete-after --delete -b --backup-dir="$HST" "$SRC" "$DST" && \
find "$SRC" -depth -type f -mtime +30 ! -ipath "*/ShadowCopy/*" -exec rm -v "{}" \; && \
find "$SRC" -depth -type d -empty     ! -ipath "*/ShadowCopy/*" -exec rmdir -v "{}" \; && \
rsync -arvu                        --delete-after --delete -b --backup-dir="$HST" "$SRC_Shadow" "$DST" && \
fdupes -drN "$HST" && \
find "$HST" -type f ! -name "*.gz" ! -name "*.bz2" -exec gzip -fv "{}" \; && \
find "$HST" -type f -exec touch "{}" \; 

(mount | grep "$FOLDER_MOUNT" > /dev/null) && (umount "$FOLDER_MOUNT")
