$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectDir

Write-Host "Installing build dependencies..."
& py -3 -m pip install -r requirements.txt pyinstaller

Write-Host "Building executable..."
& py -3 -m PyInstaller `
    --noconfirm `
    --clean `
    --windowed `
    --onefile `
    --name clipboard-paste-jpg `
    --hidden-import=win32timezone `
    --hidden-import=pythoncom `
    --hidden-import=win32com.client `
    --hidden-import=win32gui `
    --hidden-import=win32con `
    --hidden-import=win32event `
    --hidden-import=winerror `
    --collect-submodules=win32com `
    main.py

$DistExe = Join-Path $ProjectDir "dist\clipboard-paste-jpg.exe"
if (-not (Test-Path $DistExe)) {
    throw "Build failed: dist\clipboard-paste-jpg.exe not found."
}

$ReleaseDir = Join-Path $ProjectDir "release\clipboard-paste-jpg-win64"
if (Test-Path $ReleaseDir) {
    Remove-Item $ReleaseDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ReleaseDir | Out-Null

Copy-Item $DistExe $ReleaseDir
Copy-Item (Join-Path $ProjectDir "install.bat") $ReleaseDir
Copy-Item (Join-Path $ProjectDir "install_portable.ps1") $ReleaseDir
Copy-Item (Join-Path $ProjectDir "uninstall.bat") $ReleaseDir
Copy-Item (Join-Path $ProjectDir "uninstall_portable.ps1") $ReleaseDir
Copy-Item (Join-Path $ProjectDir "release\README.txt") $ReleaseDir

$ZipPath = Join-Path $ProjectDir "release\clipboard-paste-jpg-win64.zip"
if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}
Compress-Archive -Path (Join-Path $ReleaseDir "*") -DestinationPath $ZipPath

Write-Host ""
Write-Host "Build complete:"
Write-Host "  $DistExe"
Write-Host "  $ZipPath"
