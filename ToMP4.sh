#!/bin/sh
SRC="$1"
EXT=${SRC##*.}
DST=${SRC%.$EXT}.mp4
rm "$DST" 2> /dev/null
["$SRC" == "$DST"] && exit
echo "===========================Re-Encodeando==========================="
echo "Origien: $SRC"
echo "Destino: $DST"
echo "===================================================================" >> $LOG
/usr/local/bin/ffmpeg -i "$SRC" "$DST" && rm "$SRC"
