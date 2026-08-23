@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Manage-LOTM-English.ps1" -Action Verify
pause
