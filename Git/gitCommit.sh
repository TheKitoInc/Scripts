#!/bin/bash
        cd "$1" && \
        git add . && \
        git status && \
        git commit -m "$2" && \
        git push
