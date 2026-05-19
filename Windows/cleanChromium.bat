@echo off
cls

:: =========================================
:: CHROMIUM CACHE
:: =========================================
echo Cleaning Chromium cache...

taskkill /f /im chromium.exe >nul 2>&1

rd /s /q "%LOCALAPPDATA%\Chromium\User Data\Default\Cache" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Chromium\User Data\Default\Code Cache" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Chromium\User Data\Default\GPUCache" >nul 2>&1

echo Done.
echo.
