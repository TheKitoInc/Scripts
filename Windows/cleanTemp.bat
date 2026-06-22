@echo off
cls

:: =========================================
:: TEMP FILES
:: =========================================

call "%~dp0Helpers\showTitle.bat" "TEMP Folders Cleaner"

echo Cleaning TEMP folders...

del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rd /s /q "%%x" >nul 2>&1

del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do rd /s /q "%%x" >nul 2>&1

call "%~dp0Helpers\showSuccess.bat"
