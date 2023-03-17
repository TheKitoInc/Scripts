#!/bin/bash

for i in $(find "$1" -name "*.sh"); do
        status=`ps -efww | grep -w "$i" | grep -v grep | grep -v $$ | awk '{ print $2 }'`
        if [[ -x "$1" ]]; then
                if [ -z "$status" ]; then
                        /bin/bash "$i" &
                fi
        fi
done
