@echo off
cls

:: =========================================
:: DISK CLEANUP
:: =========================================

call "%~dp0showTitle.bat" "Disk Cleanup"

echo Running Disk Cleanup...

cleanmgr /sagerun:1

call "%~dp0showDone.bat"
