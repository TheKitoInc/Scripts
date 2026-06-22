@echo off
cls

:: =========================================
:: ENABLE OPENSSH SERVER
:: =========================================

call "%~dp0showTitle.bat" "Enable OpenSSH Server"

powershell -ExecutionPolicy Bypass "%~dp0%~n0.ps1"Server

call "%~dp0showDone.bat"