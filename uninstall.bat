@echo off
chcp 65001 >nul
cd /d "%~dp0"
title clipboard-paste-jpg 제거
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall_portable.ps1"
echo.
pause
