@echo off
chcp 65001 >nul
cd /d "%~dp0"
title clipboard-paste-jpg 설치
echo.
echo  clipboard-paste-jpg 설치 중...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_portable.ps1"
if errorlevel 1 (
    echo.
    echo  설치에 실패했습니다.
    pause
    exit /b 1
)
echo.
echo  설치 완료!
echo  탐색기에서 Ctrl+Shift+V 로 이미지를 JPG로 저장하세요.
echo.
timeout /t 5 >nul
