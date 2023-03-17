@echo off
cls
echo Configurando Energia
powercfg -s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -change -disk-timeout-ac 0
powercfg -change -disk-timeout-dc 0
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 0
powercfg -change -hibernate-timeout-ac 0
powercfg -change -hibernate-timeout-dc 0
