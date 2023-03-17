#!/bin/bash
D=$(dirname "$1")
F=$(basename "$1")
F2=${F//[![:print:]]}
cd "$D" && mv -v "$F" "$F2"
