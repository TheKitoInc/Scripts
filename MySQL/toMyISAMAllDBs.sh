#!/bin/bash

HOST=localhost
USER=root
PASS=

for DB in $(echo "SHOW DATABASES;" | mysql -h "$HOST" -u "$USER" -p"$PASS" | grep -v Database)
do
        for table in $(echo "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE ENGINE = 'InnoDB' AND TABLE_SCHEMA='\\$DB'" | mysql -h "$HOST" -u "$USER" -p"$PASS">
        do

                CMD1="SET foreign_key_checks = 0;"
                CMD2="ALTER TABLE $DB.$table ENGINE=MyISAM;"
                CMD3="SET foreign_key_checks = 1;"

                CMD=$CMD1$CMD2$CMD3

                echo "=============================================================="
                echo DataBase: $DB
                echo Table: $table
                echo Command:  $CMD
                echo "$CMD" | mysql -h "$HOST" -u "$USER" -p"$PASS" "$DB"
        done
done
