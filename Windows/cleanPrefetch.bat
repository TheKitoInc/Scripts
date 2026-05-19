@echo off
cls

:: =========================================
:: PREFETCH
:: =========================================

call "%~dp0showTitle.bat" "Prefetch Cleaner"

echo Cleaning Prefetch...

del /f /s /q "C:\Windows\Prefetch\*" >nul 2>&1

echo Done.
echo.
