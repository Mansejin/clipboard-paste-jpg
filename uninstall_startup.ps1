$ErrorActionPreference = "Stop"

$StartupDir = [Environment]::GetFolderPath("Startup")
$LauncherPath = Join-Path $StartupDir "ClipboardPasteJpg.vbs"

Get-Process pythonw -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)").CommandLine
        if ($cmd -like "*clipboard-paste-jpg*main.py*") {
            Stop-Process -Id $_.Id -Force
        }
    } catch {
        # Ignore processes we cannot inspect.
    }
}

if (Test-Path $LauncherPath) {
    Remove-Item $LauncherPath -Force
    Write-Host "Removed startup launcher."
} else {
    Write-Host "Startup launcher was not installed."
}

Write-Host "Uninstall complete."
