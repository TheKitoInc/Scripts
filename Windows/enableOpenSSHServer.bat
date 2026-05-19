@echo off
cls

call "%~dp0showTitle.bat" "Enable OpenSSH Server"

powershell -ExecutionPolicy Bypass "%~dp0%~n0.ps1"Server