@echo off
cls

:: =========================================
:: ULTRAVNC LOG CLEANUP
:: =========================================
echo Cleaning UltraVNC logs...

net stop uvnc_service >nul 2>&1

if exist "C:\Program Files (x86)\uvnc bvba\UltraVNC\WinVNC.log" (
    type nul > "C:\Program Files (x86)\uvnc bvba\UltraVNC\WinVNC.log"
)

net start uvnc_service >nul 2>&1

echo Done.
echo.
