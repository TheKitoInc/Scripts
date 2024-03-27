#!/bin/bash
WORKDIR=/home/git/repos

export HOME=/home/$(id  -nu)

for d in $(gh repo list -L 1000 | cut -f1)
do
        DST="$WORKDIR/GitHub/$d"
        [ ! -d "$DST" ] && git clone git@github.com:$d "$DST"

        /opt/kito/scripts/gitPull.sh "$DST"

        /home/git/scripts/gitTasksRepo.sh "$DST"

        /opt/kito/scripts/gitPush.sh "$DST"
done

wait
