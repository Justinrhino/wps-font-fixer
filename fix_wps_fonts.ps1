# =========================================================
# WPS 跨电脑云端自动修复脚本（免本地文件依赖）
# =========================================================

$ErrorActionPreference = "Continue"

# 1. 设置云端仓库地址与临时下载目录
$BaseUrl = "https://raw.githubusercontent.com/Justinrhino/wps-font-fixer/main"
$TempDir = Join-Path $env:TEMP "WpsFontFixer"

if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
New-Item -ItemType Directory -Path $TempDir | Out-Null

# 2. 定义需要补充的核心字体列表（根据需要自行在 GitHub 的 fonts/ 文件夹补充）
$FontFiles = @("Arial.ttf", "Calibri.ttf", "SegoeUI.ttf") 

Write-Host "[1/3] 正在从 GitHub 下载字体文件..." -ForegroundColor Green

$ShellApp = New-Object -ComObject Shell.Application
$FontsFolder = $ShellApp.Namespace(0x14) # C:\Windows\Fonts

foreach ($Font in $FontFiles) {
    $FontUrl = "$BaseUrl/fonts/$Font"
    $LocalPath = Join-Path $TempDir $Font
    
    try {
        # 实时下载字体文件到临时目录
        Invoke-WebRequest -Uri $FontUrl -OutFile $LocalPath -UseBasicParsing
        Write-Host " -> 成功下载: $Font" -ForegroundColor Yellow
        
        # 自动安装字体至系统
        $FontsFolder.CopyHere($LocalPath, 0x10)
        Write-Host " -> 成功安装: $Font" -ForegroundColor Cyan
    } catch {
        Write-Warning "字体 $Font 下载或安装失败，跳过。"
    }
}

# 3. 清理 WPS 渲染缓存
Write-Host "[2/3] 正在清理 WPS 临时渲染缓存..." -ForegroundColor Green
$WpsCachePath = "$env:LOCALAPPDATA\Kingsoft\WPS Office\office6\data"
if (Test-Path $WpsCachePath) {
    Remove-Item -Path "$WpsCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. 清理临时下载目录
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n修复完成！请彻底关闭并重新打开 WPS。" -ForegroundColor Green
