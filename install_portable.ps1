$ErrorActionPreference = "Stop"

$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExeName = "clipboard-paste-jpg.exe"
$SourceExe = Join-Path $SourceDir $ExeName

if (-not (Test-Path $SourceExe)) {
    throw "clipboard-paste-jpg.exe not found. Extract the full zip before running install.bat."
}

$InstallDir = Join-Path $env:LOCALAPPDATA "clipboard-paste-jpg"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item $SourceExe (Join-Path $InstallDir $ExeName) -Force

$StartupDir = [Environment]::GetFolderPath("Startup")
$ShortcutPath = Join-Path $StartupDir "ClipboardPasteJpg.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = Join-Path $InstallDir $ExeName
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.WindowStyle = 7
$Shortcut.Description = "Save clipboard images as JPG in File Explorer"
$Shortcut.Save()

$OldVbs = Join-Path $StartupDir "ClipboardPasteJpg.vbs"
if (Test-Path $OldVbs) {
    Remove-Item $OldVbs -Force
}

Get-CimInstance Win32_Process | Where-Object {
    $_.Name -in @("clipboard-paste-jpg.exe", "pythonw.exe", "python.exe")
} | ForEach-Object {
    $cmd = $_.CommandLine
    if ($cmd -like "*clipboard-paste-jpg*") {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

Start-Process -FilePath (Join-Path $InstallDir $ExeName) -WindowStyle Hidden

Write-Host ""
Write-Host "Installed to: $InstallDir"
Write-Host "Startup shortcut: $ShortcutPath"
Write-Host ""
Write-Host "Use Ctrl+Shift+V in File Explorer to save clipboard images as JPG."
