# =========================================================
# WPS Cloud Font Fixer (Universal - Zero Encoding Error)
# =========================================================

$ErrorActionPreference = "Continue"

$BaseUrl = "https://cdn.jsdelivr.net/gh/Justinrhino/wps-font-fixer@main"
$TempDir = Join-Path $env:TEMP "WpsFontFixer"

if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
New-Item -ItemType Directory -Path $TempDir | Out-Null

$FontFiles = @("Arial.ttf", "Calibri.ttf", "SegoeUI.ttf") 

Write-Host "[1/3] Downloading fonts via jsDelivr CDN..." -ForegroundColor Green

$ShellApp = New-Object -ComObject Shell.Application
$FontsFolder = $ShellApp.Namespace(0x14)

foreach ($Font in $FontFiles) {
    $FontUrl = "$BaseUrl/fonts/$Font"
    $LocalPath = Join-Path $TempDir $Font
    
    try {
        Invoke-WebRequest -Uri $FontUrl -OutFile $LocalPath -UseBasicParsing
        Write-Host " -> Downloaded: $Font" -ForegroundColor Yellow
        
        $FontsFolder.CopyHere($LocalPath, 0x10)
        Write-Host " -> Installed: $Font" -ForegroundColor Cyan
    } catch {
        Write-Warning "Failed to download/install $Font. Please check if fonts/$Font exists in repository."
    }
}

Write-Host "[2/3] Cleaning WPS render cache..." -ForegroundColor Green
$WpsCachePath = "$env:LOCALAPPDATA\Kingsoft\WPS Office\office6\data"
if (Test-Path $WpsCachePath) {
    Remove-Item -Path "$WpsCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`nFix completed! Restart WPS Office to apply changes." -ForegroundColor Green
