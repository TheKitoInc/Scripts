@echo off
cls
echo Moviendo Documentos Locales A Servidor
call %~dp0move.bat "%USERPROFILE%\Documents" "u:\Documentos"
call %~dp0move.bat "%USERPROFILE%\Documentos" "u:\Documentos"
call %~dp0move.bat "%USERPROFILE%\Desktop" "u:\Escritorio"
call %~dp0move.bat "%USERPROFILE%\Escritorio" "u:\Escritorio"
call %~dp0move.bat "%USERPROFILE%\Downloads" "u:\Descargas"
call %~dp0move.bat "%USERPROFILE%\Descargas" "u:\Descargas"
