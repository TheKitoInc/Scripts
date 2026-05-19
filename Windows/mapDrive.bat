@echo off
cls

:: =========================================
:: Network Drive Mapper
:: =========================================

if "%~1"=="" goto :usage
if "%~2"=="" goto :usage

set DRIVE=%~1
set SHARE=%~2

echo Connecting network drive %DRIVE%...
echo Share: %SHARE%
echo.

:: Remove existing mapping
net use %DRIVE%: /delete /y >nul 2>&1

:: Create new mapping
net use %DRIVE%: "%SHARE%"

if %errorlevel%==0 (
    echo.
    echo Drive mapped successfully.
) else (
    echo.
    echo Failed to map drive.
)

exit /b 0

:: =========================================
:: Usage
:: =========================================

:usage
echo.
echo Usage:
echo %~nx0 Z \\SERVER\Share
echo.
echo Example:
echo %~nx0 X \\NAS\Public
echo.

exit /b 1
