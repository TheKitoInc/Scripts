@echo off
cls

:: =========================================
:: DISABLE WEB SEARCH IN START MENU
:: =========================================

call "%~dp0showTitle.bat" "Disable Web Search in Start Menu"

powershell -ExecutionPolicy Bypass "%~dp0%~n0.ps1"

call "%~dp0showDone.bat"