@echo off
cls

call "%~dp0showTitle.bat" "Disable Web Search in Start Menu"

powershell -ExecutionPolicy Bypass "%~dp0%~n0.ps1"