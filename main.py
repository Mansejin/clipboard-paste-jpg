"""Save clipboard images as JPG in File Explorer (Ctrl+Shift+V)."""

from __future__ import annotations

import ctypes
import logging
import os
import threading
from ctypes import wintypes
from datetime import datetime
from pathlib import Path

import pythoncom
import win32con
import win32event
import win32gui
import win32com.client
import winerror
from PIL import Image, ImageGrab

LOG_DIR = Path(os.environ.get("APPDATA", "")) / "clipboard-paste-jpg"
LOG_FILE = LOG_DIR / "app.log"
MUTEX_NAME = "clipboard-paste-jpg-mutex"

HOTKEY_ID = 1
MOD_CONTROL = 0x0002
MOD_SHIFT = 0x0004
MOD_NOREPEAT = 0x4000

CF_BITMAP = 2
CF_DIB = 8
CF_DIBV5 = 17

EXPLORER_CLASSES = frozenset({"CabinetWClass", "ExploreWClass", "Progman", "WorkerW"})
JPEG_QUALITY = 92
WINDOW_CLASS = "ClipboardPasteJpgHidden"

user32 = ctypes.windll.user32


def setup_logging() -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        filename=LOG_FILE,
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        encoding="utf-8",
    )


def acquire_single_instance() -> bool:
    try:
        handle = win32event.CreateMutex(None, False, MUTEX_NAME)
        if win32event.WaitForSingleObject(handle, 0) == winerror.WAIT_TIMEOUT:
            logging.info("Another instance is already running.")
            return False
    except Exception as exc:
        logging.error("Failed to create mutex: %s", exc)
        return False
    return True


def get_foreground_class() -> str:
    hwnd = user32.GetForegroundWindow()
    buffer = ctypes.create_unicode_buffer(256)
    user32.GetClassNameW(hwnd, buffer, 256)
    return buffer.value


def is_explorer_foreground() -> bool:
    return get_foreground_class() in EXPLORER_CLASSES


def get_foreground_hwnd() -> int:
    return int(user32.GetForegroundWindow())


def clipboard_has_image() -> bool:
    if not user32.OpenClipboard(0):
        return False
    try:
        return any(
            user32.IsClipboardFormatAvailable(fmt)
            for fmt in (CF_DIB, CF_DIBV5, CF_BITMAP)
        )
    finally:
        user32.CloseClipboard()


def get_explorer_folder_path() -> str | None:
    hwnd = get_foreground_hwnd()
    class_name = get_foreground_class()

    if class_name in EXPLORER_CLASSES - {"Progman", "WorkerW"}:
        return _path_from_shell_window(hwnd)

    if class_name in {"Progman", "WorkerW"}:
        return _desktop_path()

    return None


def _desktop_path() -> str:
    shell = win32com.client.Dispatch("WScript.Shell")
    return str(shell.SpecialFolders("Desktop"))


def _path_from_shell_window(hwnd: int) -> str | None:
    shell = win32com.client.Dispatch("Shell.Application")
    for window in shell.Windows():
        try:
            if int(window.hwnd) == hwnd:
                return str(window.Document.Folder.Self.Path)
        except Exception:
            continue
    return None


def grab_clipboard_image() -> Image.Image | None:
    image = ImageGrab.grabclipboard()
    if image is None:
        return None
    if image.mode in ("RGBA", "LA", "P"):
        background = Image.new("RGB", image.size, (255, 255, 255))
        if image.mode == "P":
            image = image.convert("RGBA")
        background.paste(image, mask=image.split()[-1] if image.mode in ("RGBA", "LA") else None)
        image.close()
        return background
    if image.mode != "RGB":
        converted = image.convert("RGB")
        image.close()
        return converted
    return image


def make_filename() -> str:
    stamp = datetime.now().strftime("%Y-%m-%d %H%M%S")
    return f"Screenshot {stamp}.jpg"


def unique_path(folder: str, filename: str) -> Path:
    target = Path(folder) / filename
    if not target.exists():
        return target

    stem = Path(filename).stem
    suffix = Path(filename).suffix
    index = 1
    while True:
        candidate = Path(folder) / f"{stem} ({index}){suffix}"
        if not candidate.exists():
            return candidate
        index += 1


def save_clipboard_as_jpg(folder: str) -> Path | None:
    image = grab_clipboard_image()
    if image is None:
        logging.warning("Clipboard reported an image but could not read it.")
        return None

    try:
        output = unique_path(folder, make_filename())
        image.save(output, "JPEG", quality=JPEG_QUALITY, optimize=True)
        logging.info("Saved %s", output)
        return output
    except OSError as exc:
        logging.error("Failed to save image in %s: %s", folder, exc)
        return None
    finally:
        image.close()


def is_writable_folder(path: str | None) -> bool:
    if not path or path.startswith("::"):
        return False
    return os.path.isdir(path)


def handle_hotkey() -> None:
    if not is_explorer_foreground():
        return
    if not clipboard_has_image():
        return

    folder = get_explorer_folder_path()
    if is_writable_folder(folder):
        save_clipboard_as_jpg(folder)
        return

    logging.info("Skipped paste: no writable explorer folder.")


def window_proc(hwnd, msg, wparam, lparam):
    if msg == win32con.WM_HOTKEY and wparam == HOTKEY_ID:
        handle_hotkey()
        return 0
    if msg == win32con.WM_DESTROY:
        user32.UnregisterHotKey(hwnd, HOTKEY_ID)
        win32gui.PostQuitMessage(0)
        return 0
    return win32gui.DefWindowProc(hwnd, msg, wparam, lparam)


def run() -> None:
    wc = win32gui.WNDCLASS()
    wc.lpszClassName = WINDOW_CLASS
    wc.lpfnWndProc = window_proc
    class_atom = win32gui.RegisterClass(wc)

    hwnd = win32gui.CreateWindow(
        class_atom,
        "ClipboardPasteJpg",
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        None,
    )

    ok = user32.RegisterHotKey(
        hwnd,
        HOTKEY_ID,
        MOD_CONTROL | MOD_SHIFT | MOD_NOREPEAT,
        ord("V"),
    )
    if not ok:
        raise OSError("Failed to register Ctrl+Shift+V hotkey.")

    logging.info("clipboard-paste-jpg is running (Ctrl+Shift+V).")

    try:
        win32gui.PumpMessages()
    finally:
        user32.UnregisterHotKey(hwnd, HOTKEY_ID)
        win32gui.DestroyWindow(hwnd)
        win32gui.UnregisterClass(WINDOW_CLASS, None)


def main() -> None:
    setup_logging()
    if not acquire_single_instance():
        return

    pythoncom.CoInitialize()
    try:
        run()
    except KeyboardInterrupt:
        logging.info("Stopped by user.")
    finally:
        pythoncom.CoUninitialize()


if __name__ == "__main__":
    if threading.current_thread() is threading.main_thread():
        main()
    else:
        raise RuntimeError("main() must run on the main thread.")
