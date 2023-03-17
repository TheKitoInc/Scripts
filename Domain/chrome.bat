@echo off
cls
echo Configurando Google Chrome
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --make-default-browser
"C:\Program Files\Google\Chrome\Application\chrome.exe" --make-default-browser
del /Q /S  "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage"
