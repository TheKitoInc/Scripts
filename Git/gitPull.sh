#!/bin/bash
        cd "$1" && \
        git status && \
        git config pull.rebase false  && \
        git pull
