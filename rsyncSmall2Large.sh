#!/bin/bash
for i in {1..1024}
do
        echo Max Size $i\0M
        rsync --max-size=$i\0M "$@"
done
rsync "$@"
