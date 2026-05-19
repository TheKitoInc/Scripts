@echo off
cls

call "%~dp0showTitle.bat" "Disable Fast Startup"

:: Disable Fast Startup in Windows 11
echo Disabling Fast Startup...

:: Disable Fast Startup
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f
powercfg -H off

echo Fast Startup has been disabled.
echo.