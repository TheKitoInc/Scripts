#!/bin/bash
HOST=$1
NAME=$(echo "$HOST" | cut -d "." -f1)

ssh-copy-id $HOST

SRC=$1:/
DST=/Storage/Master/$NAME/
HST=/Storage/History/$NAME/$(date "+%Y/%m/%d/%H")/

echo SRC: $SRC
echo DST: $DST
echo HST: $HST

mkdir -p "$DST" && \
mkdir -p "$HST" && \
rsync -arv --safe-links --exclude={"/var/lib/mlocate","/var/mail","/var/log","/var/lib/ispell","/var/lib/dpkg","/var/lib/apt","/var/cache","/bin","/boot","/dev","/initrd*","/lib*","/mount","/sbin","/srv","/usr","vmlinuz*","/proc","/sys","/tmp","/run","/mnt","/media","/lost+found","/Storage"} --delete-after --delete -b --backup-dir="$HST" "$SRC" "$DST" && \
find "$HST" -type f -iname "*.bz2" -exec bunzip2 -fv "{}" \; && \
fdupes -drNI "$HST" && \
find "$HST" -type f ! -name "*.gz" ! -name "*.bz2" -exec gzip -fv "{}" \; && \
find "$HST" -type f -exec touch "{}" \;
