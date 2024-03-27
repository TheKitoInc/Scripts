#!/bin/bash
WORKDIR=/home/git/repos

export HOME=/home/$(id  -nu)

for d in $(gh repo list -L 1000 | cut -f1)
do
        DST="$WORKDIR/GitHub/$d"
        [ ! -d "$DST" ] && \
        git clone git@github.com:$d "$DST"

        /home/git/scripts/gitTasksRepo.sh "$DST"
done

wait
