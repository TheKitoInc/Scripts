@echo off
cls

:: =========================================
:: DISK CLEANUP
:: =========================================

call "%~dp0Helpers\showTitle.bat" "Disk Cleanup"

call "%~dp0Helpers\checkElevated.bat"

echo Running Disk Cleanup...

cleanmgr /sagerun:1

call "%~dp0Helpers\showSuccess.bat"
