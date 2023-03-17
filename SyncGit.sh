#!/bin/bash
WORKDIR=/Data/Git

for d in $(find "$WORKDIR" -maxdepth 1 -mindepth 1 -type d)
do
        cd "$d" && \
        git config pull.rebase false  && \
        git pull
done
