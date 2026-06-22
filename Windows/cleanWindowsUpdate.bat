@echo off
cls

:: =========================================
:: WINDOWS UPDATE CACHE
:: =========================================

call "%~dp0Helpers\showTitle.bat" "Windows Update Cache Cleaner"

call "%~dp0Helpers\checkElevated.bat"

echo Cleaning Windows Update cache...

net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%x in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%x" >nul 2>&1

net start wuauserv >nul 2>&1
net start bits >nul 2>&1

call "%~dp0Helpers\showSuccess.bat"
