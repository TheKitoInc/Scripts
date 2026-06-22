@echo off

:: =========================================
:: ERROR: NOT ELEVATED
:: =========================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    call "%~dp0\showError.bat" "This task requires administrative privileges. Please run the script as an administrator."    
    exit 
)