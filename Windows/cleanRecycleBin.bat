@echo off
cls

:: =========================================
:: RECYCLE BIN
:: =========================================

call "%~dp0showTitle.bat" "Recycle Bin Cleaner"

echo Emptying Recycle Bin...

powershell -Command "Clear-RecycleBin -Force" >nul 2>&1

call "%~dp0showDone.bat"
