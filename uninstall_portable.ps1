$ErrorActionPreference = "Stop"

$InstallDir = Join-Path $env:LOCALAPPDATA "clipboard-paste-jpg"
$StartupDir = [Environment]::GetFolderPath("Startup")
$ShortcutPath = Join-Path $StartupDir "ClipboardPasteJpg.lnk"
$OldVbs = Join-Path $StartupDir "ClipboardPasteJpg.vbs"

Get-CimInstance Win32_Process | Where-Object {
    $_.Name -in @("clipboard-paste-jpg.exe", "pythonw.exe", "python.exe")
} | ForEach-Object {
    $cmd = $_.CommandLine
    if ($cmd -like "*clipboard-paste-jpg*") {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

if (Test-Path $ShortcutPath) {
    Remove-Item $ShortcutPath -Force
    Write-Host "Removed startup shortcut."
}

if (Test-Path $OldVbs) {
    Remove-Item $OldVbs -Force
    Write-Host "Removed legacy startup launcher."
}

if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
    Write-Host "Removed $InstallDir"
}

Write-Host ""
Write-Host "Uninstall complete."
