@echo off
cls

call "%~dp0showTitle.bat" "Printers Cleanup"

rundll32 printui.dll,PrintUIEntry /q /dl /n "Fax"
rundll32 printui.dll,PrintUIEntry /q /dl /n "AnyDesk Printer"
rundll32 printui.dll,PrintUIEntry /q /dl /n "OneNote for Windows 10"
rundll32 printui.dll,PrintUIEntry /q /dl /n "OneNote (Desktop)"
rundll32 printui.dll,PrintUIEntry /q /dl /n "Microsoft XPS Document Writer"

call "%~dp0showDone.bat"