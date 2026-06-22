@echo off

:: =========================================
:: ERROR MESSAGE
:: =========================================

:: Set color to red
color 0C
echo An error occurred during the execution of the script:
echo "%~f0"
echo %~1
timeout /t 5

cls