@echo off
cls

:: =========================================
:: ONEDRIVE REMOVAL
:: =========================================

call "%~dp0Helpers\showTitle.bat" "OneDrive Removal"

call "%~dp0Helpers\checkElevated.bat"

taskkill /F /IM OneDrive.exe

if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall
)

if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall
)

:: Remove startup entries
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1

reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f >nul 2>&1

:: Uninstall with winget if available
winget uninstall --id Microsoft.OneDrive -e --silent >nul 2>&1

:: Block reinstallation
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSCOnDomainJoinedDevices" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSCOnMobileConnectedDevices" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSCOnRoamingDevices" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSCOnUnmanagedDevices" /t REG_DWORD /d 1 /f >nul 2>&1

:: Remove from explorer context menu
reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\OneDrive" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\OneDrive" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Drive\shellex\ContextMenuHandlers\OneDrive" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\LibraryFolder\shellex\ContextMenuHandlers\OneDrive" /f >nul 2>&1

:: Remove OneDrive folders
rd /s /q "%USERPROFILE%\OneDrive" >nul 2>&1

call "%~dp0Helpers\restartExplorer.bat"

call "%~dp0Helpers\showSuccess.bat"