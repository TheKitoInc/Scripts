@echo off

:: --- Admin check ---
net session >nul 2>&1 && set IS_ADMIN=1 || set IS_ADMIN=0

:: --- OS version check ---
for /f "tokens=4-5 delims=. " %%i in ('ver') do (
    set VERSION=%%i
    set BUILD=%%j
)

if %BUILD% GEQ 22000 set OS_VER=11
if %BUILD% LSS 22000 set OS_VER=10

:: --- Disable RDP UDP ---
if "%IS_ADMIN%"=="1" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" /v fClientDisableUDP /t REG_DWORD /d 0 /f && echo UDP enabled

:: --- Disable News And Interests (system policy) ---
if "%IS_ADMIN%"=="1" reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f

:: --- Disable taskbar weather ---
if "%OS_VER%"=="11" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f
if "%OS_VER%"=="10" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f

:: --- Disable Hybrid Sleep / Hibernation ---
if "%IS_ADMIN%"=="1" powercfg -h off
