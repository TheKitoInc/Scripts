#!/bin/bash
SRC_HOST=$1
ssh-copy-id $SRC_HOST

for SRC_NAME in $(ssh $SRC_HOST "ls /Storage/Master/")
do
        SRC=$SRC_HOST:/Storage/Master/$SRC_NAME/
        DST=/Storage/Master/$SRC_NAME/
        HST=/Storage/History/$SRC_NAME/$(date "+%Y/%m/%d/%H")/

        echo SRC: $SRC
        echo DST: $DST
        echo HST: $HST

        mkdir -p "$DST" && \
        mkdir -p "$HST" && \
        rsync -arv --delete-after --delete -b --backup-dir="$HST" "$SRC" "$DST"

        find "$HST" -type f -exec touch "{}" \;
done
