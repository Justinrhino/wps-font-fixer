# =========================================================
# WPS 跨电脑字体自动安装与环境修复脚本
# =========================================================

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$FontDir = Join-Path $ScriptDir "fonts"

# 1. 自动安装/覆盖 fonts 目录下的所有字体到 Windows 系统
if (Test-Path $FontDir) {
    Write-Host "[1/3] 正在同步字体至系统 Font 库..." -ForegroundColor Green
    $ShellApp = New-Object -ComObject Shell.Application
    $FontsFolder = $ShellApp.Namespace(0x14) # C:\Windows\Fonts
    
    Get-ChildItem -Path $FontDir -Include *.ttf, *.otf, *.ttc -Recurse | ForEach-Object {
        $FontFile = $_.FullName
        $FontName = $_.Name
        Write-Host " -> 安装字体: $FontName"
        try {
            # 通过 Shell 自动化安装字体并注册注册表
            $FontsFolder.CopyHere($FontFile, 0x10)
        } catch {
            Write-Warning "字体 $FontName 安装跳过或已存在。"
        }
    }
} else {
    Write-Warning "未找到 fonts 目录，跳过字体安装。"
}

# 2. 清理 WPS 渲染缓存
Write-Host "[2/3] 正在清理 WPS 临时缓存..." -ForegroundColor Green
$WpsCachePath = "$env:LOCALAPPDATA\Kingsoft\WPS Office\office6\data"
if (Test-Path $WpsCachePath) {
    Remove-Item -Path "$WpsCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. 关闭系统 UTF-8 实验性选项（防止字符拉伸）
Write-Host "[3/3] 正在优化系统区域编码设置..." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -Value "936"

Write-Host "`n修复完成！请彻底关闭并重启 WPS 打开文档。" -ForegroundColor Cyann
