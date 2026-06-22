@echo off

:: Auto-elevate
fltmc >nul 2>&1
if not %errorlevel%==0 (
    echo Elevating privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Windows 10/11 Aggressive Debloat

echo Administrator privileges confirmed.
echo.