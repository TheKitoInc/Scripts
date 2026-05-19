@echo off
cls

call "%~dp0showTitle.bat" "Disable News and Interests"

taskkill /F /IM explorer.exe
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarPreviousViewMode" /t REG_DWORD /d "2" /f
start explorer.exe
