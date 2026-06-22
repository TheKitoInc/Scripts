@echo off
cls

call "%~dp0Helpers\showTitle.bat" "Configure NTP Service"

:: Set your preferred NTP servers here (you can change pool.ntp.org to another)
set NTP_SERVERS=pool.ntp.org

:: Stop Windows Time service (in case it’s running)
net stop w32time >nul 2>&1

:: Configure NTP server and client mode
w32tm /config /manualpeerlist:"%NTP_SERVERS%" /syncfromflags:manual /reliable:no /update

:: Enable service startup type = automatic
sc config w32time start= auto

:: Start the Windows Time service
net start w32time

:: Force resync
w32tm /resync /nowait

echo.
echo ==========================================
echo NTP Configuration Summary
echo ==========================================
w32tm /query /configuration | findstr /C:"NtpServer"
w32tm /query /status
echo ==========================================

call "%~dp0Helpers\showDone.bat"