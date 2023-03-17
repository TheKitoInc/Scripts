SET MoveDirSource=%~1
SET MoveDirDestination=%~2
MKDIR "%MoveDirDestination%"
FOR    %%i IN ("%MoveDirSource%\*") DO           MOVE /Y "%%i" "%MoveDirDestination%\%%~nxi"
FOR /D %%i IN ("%MoveDirSource%\*") DO ROBOCOPY /MOVE /E "%%i" "%MoveDirDestination%\%%~nxi"
