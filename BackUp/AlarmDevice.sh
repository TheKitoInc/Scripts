#!/bin/bash
#No Changes Alarm Device
DEV=$1

MAS=/Storage/Master/$DEV
HST=/Storage/History/$DEV

LOG=/tmp/$DEV.log

find "$MAS" -type f -mtime -7 -ls > $LOG
find "$HST" -type f -mtime -7 -ls >> $LOG

[ -s $LOG ] && STA=OK
[ -s $LOG ] || STA=ERROR

cat $LOG | mutt -s "BackUp $STA Server $(hostname) Device $DEV" $(hostname)@$(cat /etc/mailname)

