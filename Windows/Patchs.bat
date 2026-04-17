@echo off

:: --- Admin check ---
net session >nul 2>&1 && set IS_ADMIN=1 || set IS_ADMIN=0

:: --- OS version check ---
for /f %%i in ('wmic os get BuildNumber ^| findstr [0-9]') do set BUILD=%%i
if %BUILD% GEQ 22000 set OS_VER=11
if %BUILD% LSS 22000 set OS_VER=10
echo Build detected: %BUILD%

:: --- Disable RDP UDP ---
if "%IS_ADMIN%"=="1" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" /v fClientDisableUDP /t REG_DWORD /d 0 /f && echo UDP enabled

:: --- Disable News And Interests (system policy) ---
if "%IS_ADMIN%"=="1" reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f

:: --- Disable taskbar weather ---
if "%OS_VER%"=="11" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f
if "%OS_VER%"=="11" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f
if "%OS_VER%"=="10" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f

:: --- Disable Hybrid Sleep / Hibernation ---
if "%IS_ADMIN%"=="1" powercfg -h off

:: --- Disable Hardened UNC Paths (netlogon) ---
if "%IS_ADMIN%"=="1" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" /v "\\\\*\\netlogon" /t REG_SZ /d "RequireMutualAuthentication=0,RequireIntegrity=0,RequirePrivacy=0" /f

:: --- SMB compatibility tweaks (Windows 11 only) ---
if "%IS_ADMIN%"=="1" if "%OS_VER%"=="11" reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnablePlainTextPassword /t REG_DWORD /d 0 /f
if "%IS_ADMIN%"=="1" if "%OS_VER%"=="11" reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnableSecuritySignature /t REG_DWORD /d 1 /f
if "%IS_ADMIN%"=="1" if "%OS_VER%"=="11" reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 0 /f
rem if "%IS_ADMIN%"=="1" if "%OS_VER%"=="11" reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v ServiceDllUnloadOnStop /t REG_DWORD /d 1 /f
rem if "%IS_ADMIN%"=="1" if "%OS_VER%"=="11" reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f

:: --- Power settings (High Performance, no sleep) ---
if "%IS_ADMIN%"=="1" powercfg -setactive SCHEME_MIN
if "%IS_ADMIN%"=="1" powercfg -change -disk-timeout-ac 0
if "%IS_ADMIN%"=="1" powercfg -change -disk-timeout-dc 0
if "%IS_ADMIN%"=="1" powercfg -change -standby-timeout-ac 0
if "%IS_ADMIN%"=="1" powercfg -change -standby-timeout-dc 0
if "%IS_ADMIN%"=="1" powercfg -change -hibernate-timeout-ac 0
if "%IS_ADMIN%"=="1" powercfg -change -hibernate-timeout-dc 0

:: --- NTP configuration ---
if "%IS_ADMIN%"=="1" w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /reliable:no /update
if "%IS_ADMIN%"=="1" sc config w32time start= auto >nul
w32tm /resync /nowait >nul

:: --- Disable Web Search (Start Menu Bing) ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
if "%IS_ADMIN%"=="1" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f
