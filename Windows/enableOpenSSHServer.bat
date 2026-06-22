@echo off
cls

:: =========================================
:: ENABLE OPENSSH SERVER
:: =========================================

call "%~dp0Helpers\showTitle.bat" "Enable OpenSSH Server"

powershell -ExecutionPolicy Bypass "%~dp0%~n0.ps1"Server

call "%~dp0Helpers\showSuccess.bat"