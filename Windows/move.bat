@echo off
cls

:: =========================================
:: MOVE FILES AND FOLDERS
:: =========================================

call "%~dp0Helpers\showTitle.bat" "Moving %~1 > %~2"

echo Moving files and folders from "%~1" to "%~2"...

SET MoveDirSource=%~1
SET MoveDirDestination=%~2
MKDIR "%MoveDirDestination%"
FOR    %%i IN ("%MoveDirSource%\*") DO           MOVE /Y "%%i" "%MoveDirDestination%\%%~nxi"
FOR /D %%i IN ("%MoveDirSource%\*") DO ROBOCOPY /MOVE /E "%%i" "%MoveDirDestination%\%%~nxi"

call "%~dp0Helpers\showSuccess.bat"