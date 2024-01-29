@echo off
cls
echo Printers...
rundll32 printui.dll,PrintUIEntry /q /dl /n "Fax"
rundll32 printui.dll,PrintUIEntry /q /dl /n "AnyDesk Printer"
rundll32 printui.dll,PrintUIEntry /q /dl /n "OneNote for Windows 10"
rundll32 printui.dll,PrintUIEntry /q /dl /n "Microsoft XPS Document Writer"
