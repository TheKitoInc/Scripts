@echo off
cls

:: =========================================
:: DISABLE NEWS AND INTERESTS
:: =========================================

call "%~dp0Helpers\showTitle.bat" "Disable News and Interests"

reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarPreviousViewMode" /t REG_DWORD /d "2" /f

call "%~dp0Helpers\restartExplorer.bat"

call "%~dp0Helpers\showSuccess.bat"