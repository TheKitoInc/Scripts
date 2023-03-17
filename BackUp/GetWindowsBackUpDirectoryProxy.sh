#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters: proxyHostName hostName"
    exit 1
fi

PROX=$1
HOST=$2
NAME=$(echo "$HOST" | cut -d "." -f1)

ssh-copy-id $PROX

SRC=$PROX:/mount/$NAME/Drive_c/Respaldo/
DST=/Storage/Master/$NAME/Drive_c/Respaldo/
HST=/Storage/History/$NAME/$(date "+%Y/%m/%d/%H")/Drive_c/Respaldo/

echo SRC: $SRC
echo DST: $DST
echo HST: $HST



mkdir -p "$DST" && \
mkdir -p "$HST" && \
rsync -arv --delete-after --delete -b --backup-dir="$HST" "$SRC" "$DST" && \
find "$HST" -type f -iname "*.bz2" -exec bunzip2 -fv "{}" \; && \
fdupes -drNI "$HST" && \
find "$HST" -type f ! -name "*.gz" ! -name "*.bz2" -exec gzip -fv "{}" \; && \
find "$HST" -type f -exec touch "{}" \;
