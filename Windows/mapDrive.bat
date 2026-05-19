@echo off
title Network Drive Mapper
color 0A
cls

:: =========================================
:: Network Drive Mapper
:: =========================================

if "%~1"=="" goto :usage
if "%~2"=="" goto :usage

set DRIVE=%~1
set SHARE=%~2


echo =========================================
echo         Network Drive Mapper
echo =========================================
echo.
echo Drive Letter : %DRIVE%:
echo Network Path : %SHARE%
echo.

echo Removing existing mapping...
net use %DRIVE%: /delete /y >nul 2>&1

echo Creating new mapping...
net use %DRIVE%: "%SHARE%"

echo.

if %errorlevel%==0 (
    echo =========================================
    echo Successfully mapped %DRIVE%:
    echo =========================================
) else (
    echo =========================================
    echo Failed to map %DRIVE%:
    echo =========================================
)

echo.
goto :end

:: =========================================
:: Usage
:: =========================================

:usage

echo =========================================
echo         Network Drive Mapper
echo =========================================
echo.
echo Usage:
echo.
echo    %~nx0 Z \\SERVER\Share
echo.
echo Example:
echo.
echo    %~nx0 X \\NAS\Public
echo.

:end
