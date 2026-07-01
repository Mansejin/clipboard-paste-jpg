# clipboard-paste-jpg

Windows에서 클립보드 이미지를 탐색기 폴더에 JPG로 바로 저장하는 백그라운드 유틸리티입니다.

## 일반 사용자 설치 (추천)

1. [Releases](https://github.com/Mansejin/clipboard-paste-jpg/releases/latest)에서 **clipboard-paste-jpg-win64.zip** 다운로드
2. 압축 풀기
3. **`설치.bat`** 더블클릭

Python 설치 불필요. Windows 10 / 11 (64비트).

## 사용법

1. Win+Shift+S 등으로 화면을 캡처합니다.
2. 탐색기에서 저장할 폴더를 엽니다.
3. **Ctrl+Shift+V**를 누릅니다.
4. `Screenshot 2026-07-01 123456.jpg` 형식으로 저장됩니다.

## 제거

압축 푼 폴더에서 **`제거.bat`** 더블클릭.

## 기능

- 화면 캡처 후 탐색기에서 **Ctrl+Shift+V**로 JPG 저장
- **Ctrl+V**는 건드리지 않음
- **Ctrl+Shift+V**는 탐색기 + 클립보드 이미지일 때만 동작
- 로그인 시 자동 실행
- 메모리 약 50MB 수준

## 개발자용 (소스 설치)

- Python 3.10 이상 필요

```powershell
git clone https://github.com/Mansejin/clipboard-paste-jpg.git
cd clipboard-paste-jpg
powershell -ExecutionPolicy Bypass -File .\install_startup.ps1
```

exe 빌드:

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

## 로그

```
%APPDATA%\clipboard-paste-jpg\app.log
```

## 변경 이력

[CHANGELOG.md](./CHANGELOG.md) 참고.

## 제한 사항

- "내 PC" 같은 특수 폴더에서는 저장되지 않습니다.
- 탐색기 또는 바탕화면이 활성일 때만 동작합니다.

## 라이선스

MIT
