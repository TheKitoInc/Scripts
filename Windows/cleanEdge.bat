@echo off
cls

:: =========================================
:: MICROSOFT EDGE CACHE
:: =========================================

call "%~dp0showTitle.bat" "Microsoft Edge Cache Cleaner"

echo Cleaning Microsoft Edge cache...

taskkill /f /im msedge.exe >nul 2>&1

rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\GPUCache" >nul 2>&1

echo Done.
echo.
