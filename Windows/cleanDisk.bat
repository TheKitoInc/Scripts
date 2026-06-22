@echo off
cls

:: =========================================
:: DISK CLEANUP
:: =========================================

call "%~dp0showTitle.bat" "Disk Cleanup"

call "%~dp0checkElevated.bat"

echo Running Disk Cleanup...

cleanmgr /sagerun:1

call "%~dp0showDone.bat"
