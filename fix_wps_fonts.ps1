# =========================================================
# WPS 跨电脑云端自动修复脚本 (UTF-8 防乱码 + CDN 加速版)
# =========================================================

# 1. 强制控制台与脚本以 UTF-8 编码输出，防止中文提示乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Continue"

# 2. 使用 jsDelivr CDN 加速节点
$BaseUrl = "https://cdn.jsdelivr.net/gh/Justinrhino/wps-font-fixer@main"
$TempDir = Join-Path $env:TEMP "WpsFontFixer"

if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
New-Item -ItemType Directory -Path $TempDir | Out-Null

# 3. 定义需补充的字体列表（确保这些文件已上传至仓库的 fonts/ 目录）
$FontFiles = @("Arial.ttf", "Calibri.ttf", "SegoeUI.ttf") 

Write-Host "[1/3] 正在通过 jsDelivr CDN 下载字体文件..." -ForegroundColor Green

$ShellApp = New-Object -ComObject Shell.Application
$FontsFolder = $ShellApp.Namespace(0x14) # C:\Windows\Fonts

foreach ($Font in $FontFiles) {
    $FontUrl = "$BaseUrl/fonts/$Font"
    $LocalPath = Join-Path $TempDir $Font
    
    try {
        # 实时下载字体文件
        Invoke-WebRequest -Uri $FontUrl -OutFile $LocalPath -UseBasicParsing
        Write-Host " -> 成功下载: $Font" -ForegroundColor Yellow
        
        # 自动安装字体至系统
        $FontsFolder.CopyHere($LocalPath, 0x10)
        Write-Host " -> 成功安装: $Font" -ForegroundColor Cyan
    } catch {
        Write-Warning "字体 $Font 下载或安装失败（请检查 GitHub 的 fonts/ 目录下是否有该文件）。"
    }
}

# 4. 清理 WPS 渲染缓存
Write-Host "[2/3] 正在清理 WPS 临时渲染缓存..." -ForegroundColor Green
$WpsCachePath = "$env:LOCALAPPDATA\Kingsoft\WPS Office\office6\data"
if (Test-Path $WpsCachePath) {
    Remove-Item -Path "$WpsCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# 5. 清理临时下载目录
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n修复完成！请彻底关闭并重新打开 WPS。" -ForegroundColor Green
