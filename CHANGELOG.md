# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-07-01

### Fixed

- **Ctrl+Shift+V no longer blocked in browsers and other apps.** The hotkey is now registered only while File Explorer (or the desktop) is in the foreground *and* the clipboard contains an image. Whale, Chrome, VS Code, and similar apps can use Ctrl+Shift+V normally again (e.g. paste without formatting).

### Changed

- Switched from a always-on global hotkey to dynamic register/unregister on a 150ms timer.
- App log message updated to `explorer-only Ctrl+Shift+V`.

## [1.0.0] - 2026-07-01

### Added

- Save clipboard images as JPG in the current File Explorer folder with **Ctrl+Shift+V**.
- Background tray-less process via `pythonw.exe`.
- `install_startup.ps1` — install dependencies, register Windows startup, launch the app.
- `uninstall_startup.ps1` — remove startup entry and stop the process.
- Single-instance mutex to prevent duplicate hooks.
- Automatic filename: `Screenshot YYYY-MM-DD HHMMSS.jpg` (with `(1)`, `(2)`, … on collision).
- Log file at `%APPDATA%\clipboard-paste-jpg\app.log`.

### Notes

- **Ctrl+V is never intercepted** — normal paste, file rename, and text input are unaffected.
- Works on Windows 10 / 11 with Python 3.10+.

[1.1.0]: https://github.com/Mansejin/clipboard-paste-jpg/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Mansejin/clipboard-paste-jpg/releases/tag/v1.0.0
