@echo off
cls

setlocal

:: =========================================
:: Cleanup Framework Launcher
:: =========================================

set BASEDIR=%~dp0

title Cleanup Launcher

:: =========================================
:: Detect Administrator
:: =========================================

set IS_ADMIN=0

net session >nul 2>&1
if %errorlevel% == 0 (
    set IS_ADMIN=1
)

:: =========================================
:: USER CLEANUP TASKS
:: =========================================

echo Running user cleanup tasks...
echo.

if exist "%BASEDIR%cleanTemp.bat" (
    call "%BASEDIR%cleanTemp.bat"
)

if exist "%BASEDIR%cleanChrome.bat" (
    call "%BASEDIR%cleanChrome.bat"
)

if exist "%BASEDIR%cleanChromium.bat" (
    call "%BASEDIR%cleanChromium.bat"
)

if exist "%BASEDIR%cleanEdge.bat" (
    call "%BASEDIR%cleanEdge.bat"
)

if exist "%BASEDIR%cleanFirefox.bat" (
    call "%BASEDIR%cleanFirefox.bat"
)

if exist "%BASEDIR%cleanBrave.bat" (
    call "%BASEDIR%cleanBrave.bat"
)

if exist "%BASEDIR%cleanRecycleBin.bat" (
    call "%BASEDIR%cleanRecycleBin.bat"
)

echo.
echo User cleanup tasks completed.
echo.

:: =========================================
:: ADMIN CLEANUP TASKS
:: =========================================

if "%IS_ADMIN%"=="1" (

    echo Running administrator cleanup tasks...
    echo.

    if exist "%BASEDIR%cleanWindowsUpdate.bat" (
        call "%BASEDIR%cleanWindowsUpdate.bat"
    )

    if exist "%BASEDIR%cleanPrefetch.bat" (
        call "%BASEDIR%cleanPrefetch.bat"
    )

    if exist "%BASEDIR%cleanUVNC.bat" (
        call "%BASEDIR%cleanUVNC.bat"
    )

    if exist "%BASEDIR%cleanDISM.bat" (
        call "%BASEDIR%cleanDISM.bat"
    )

    if exist "%BASEDIR%cleanDisk.bat" (
        call "%BASEDIR%cleanDisk.bat"
    )

    echo.
    echo Administrator cleanup tasks completed.

) else (

    echo Standard user detected.
    echo Skipping administrator-only tasks.

)

:: =========================================
:: FINISH
:: =========================================

echo.
echo Cleanup completed.

