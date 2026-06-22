@echo off
cls

:: =========================================
:: GOOGLE CHROME CACHE
:: =========================================

call "%~dp0showTitle.bat" "Google Chrome Cache Cleaner"

echo Cleaning Google Chrome cache...

taskkill /f /im chrome.exe >nul 2>&1

rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\GPUCache" >nul 2>&1

call "%~dp0showDone.bat"
