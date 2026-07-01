$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StartupDir = [Environment]::GetFolderPath("Startup")
$LauncherPath = Join-Path $StartupDir "ClipboardPasteJpg.vbs"

Write-Host "Installing Python dependencies..."
& py -3 -m pip install -r (Join-Path $ProjectDir "requirements.txt")

$pythonExe = & py -3 -c "import sys; print(sys.executable)"
$pythonw = Join-Path (Split-Path $pythonExe) "pythonw.exe"
if (-not (Test-Path $pythonw)) {
    throw "pythonw.exe not found next to $pythonExe"
}

$mainScript = Join-Path $ProjectDir "main.py"
$vbsContent = @"
Set shell = CreateObject("WScript.Shell")
shell.Run """$pythonw"" ""$mainScript""", 0, False
"@

Set-Content -Path $LauncherPath -Value $vbsContent -Encoding ASCII
Write-Host ""
Write-Host "Installed startup launcher:"
Write-Host "  $LauncherPath"
Write-Host ""
Write-Host "The app will run in the background after you sign in."
Write-Host "Use Ctrl+Shift+V in File Explorer to save clipboard images as JPG."
Write-Host ""
Write-Host "Starting now..."
Start-Process -FilePath $pythonw -ArgumentList "`"$mainScript`"" -WindowStyle Hidden
Write-Host "Done."
