@echo off
cls

:: =========================================
:: DISM COMPONENT CLEANUP
:: =========================================

call "%~dp0Helpers\showTitle.bat" "DISM Component Cleanup"

call "%~dp0Helpers\checkElevated.bat"

echo Running DISM component cleanup...

DISM /Online /Cleanup-Image /StartComponentCleanup

call "%~dp0Helpers\showDone.bat"
