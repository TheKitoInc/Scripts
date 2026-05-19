@echo off
cls

:: =========================================
:: RECYCLE BIN
:: =========================================
echo Emptying Recycle Bin...

powershell -Command "Clear-RecycleBin -Force" >nul 2>&1

echo Done.
echo.
