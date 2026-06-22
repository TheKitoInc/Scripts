@echo off
cls

:: =========================================
:: DISM COMPONENT CLEANUP
:: =========================================

call "%~dp0showTitle.bat" "DISM Component Cleanup"

echo Running DISM component cleanup...

DISM /Online /Cleanup-Image /StartComponentCleanup

call "%~dp0showDone.bat"
