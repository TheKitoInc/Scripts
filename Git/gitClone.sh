#!/bin/bash

mkdir -p "$1" && \
cd "$1" && \
git clone "$2" . && \
git config pull.rebase false  && \
git pull
