@echo off

:: =========================================
:: ERROR: NOT ELEVATED
:: =========================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo This script requires elevated privileges. Please run as administrator.   
    timeout /t 5 /nobreak >nul 
    exit /b
)