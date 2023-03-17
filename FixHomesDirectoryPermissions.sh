#!/bin/bash
HME=/home
for i in $(ls "$HME");
do
        if [ -d "$HME/$i" ]; then
                echo "$i";
                chown -R $i "$HME/$i"
                chgrp -R $i "$HME/$i"
                find "$HME/$i" -type d -exec chmod 0770 "{}" \;
                find "$HME/$i" -type f -exec chmod 0660 "{}" \;
        fi
done;
