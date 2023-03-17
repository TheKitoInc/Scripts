@echo off
cls
echo Actualizando Escritorio
del /Q C:\Users\Public\Desktop\*.lnk
del /Q C:\Users\Public\Desktop\*.url
del /Q C:\Users\Public\Desktop\*.rdp
del /Q %userprofile%\desktop\*.lnk
del /Q %userprofile%\desktop\*.url
del /Q %userprofile%\desktop\*.rdp
copy %~dp0users\public\desktop %userprofile%\desktop
copy %~dp0users\%USERNAME%\desktop %userprofile%\desktop
