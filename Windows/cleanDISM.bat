@echo off
cls

:: =========================================
:: DISM COMPONENT CLEANUP
:: =========================================
echo Running DISM component cleanup...

DISM /Online /Cleanup-Image /StartComponentCleanup

echo Done.
echo.
