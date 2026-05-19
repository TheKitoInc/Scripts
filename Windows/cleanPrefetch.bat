@echo off
cls

:: =========================================
:: PREFETCH
:: =========================================
echo Cleaning Prefetch...

del /f /s /q "C:\Windows\Prefetch\*" >nul 2>&1

echo Done.
echo.
