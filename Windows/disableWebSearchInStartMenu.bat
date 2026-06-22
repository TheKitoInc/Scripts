@echo off
cls

:: =========================================
:: DISABLE WEB SEARCH IN START MENU
:: =========================================

call "%~dp0Helpers\showTitle.bat" "Disable Web Search in Start Menu"

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f >nul 2>&1

call "%~dp0Helpers\showSuccess.bat"