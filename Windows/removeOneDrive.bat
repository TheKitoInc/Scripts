@echo off
cls

:: =========================================
:: ONEDRIVE REMOVAL
:: =========================================

call "%~dp0showTitle.bat" "OneDrive Removal"

taskkill /F /IM OneDrive.exe

if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall
)

if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall
)

call "%~dp0showDone.bat"