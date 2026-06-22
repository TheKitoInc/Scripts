@echo off

echo Restarting Explorer...

:: Restart explorer to apply changes
taskkill /f /im explorer.exe
timeout /t 2 /nobreak >nul
start explorer.exe