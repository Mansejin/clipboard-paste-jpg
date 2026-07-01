# clipboard-paste-jpg

Windows에서 클립보드 이미지를 탐색기 폴더에 JPG로 바로 저장하는 백그라운드 유틸리티입니다.

## 기능

- 화면 캡처(Win+Shift+S 등) 후 탐색기에서 **Ctrl+Shift+V**로 현재 폴더에 JPG 저장
- **Ctrl+V**는 건드리지 않음 — 일반 붙여넣기·파일 이름 변경에 영향 없음
- Windows 로그인 시 자동 실행 (설치 스크립트 사용 시)
- 백그라운드 상주, 메모리 약 50MB 수준

## 요구 사항

- Windows 10 / 11
- Python 3.10 이상

## 설치

```powershell
git clone https://github.com/Mansejin/clipboard-paste-jpg.git
cd clipboard-paste-jpg
powershell -ExecutionPolicy Bypass -File .\install_startup.ps1
```

`install_startup.ps1`은 의존성 설치, 시작 프로그램 등록, 백그라운드 실행을 한 번에 처리합니다.

## 사용법

1. Win+Shift+S 등으로 화면을 캡처합니다.
2. 탐색기에서 저장할 폴더를 엽니다.
3. **Ctrl+Shift+V**를 누릅니다.
4. `Screenshot 2026-07-01 123456.jpg` 형식으로 저장됩니다.

## 제거

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall_startup.ps1
```

## 로그

```
%APPDATA%\clipboard-paste-jpg\app.log
```

## 제한 사항

- "내 PC" 같은 특수 폴더에서는 저장되지 않습니다.
- 탐색기 또는 바탕화면이 활성일 때만 동작합니다.

## 라이선스

MIT
