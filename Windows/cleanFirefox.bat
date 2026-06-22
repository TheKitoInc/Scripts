@echo off
cls

:: =========================================
:: FIREFOX CACHE
:: =========================================

call "%~dp0Helpers\showTitle.bat" "Firefox Cache Cleaner"

echo Cleaning Firefox cache...

taskkill /f /im firefox.exe >nul 2>&1

rd /s /q "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.default-release\cache2" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.default-release\startupCache" >nul 2>&1

call "%~dp0Helpers\showSuccess.bat"
