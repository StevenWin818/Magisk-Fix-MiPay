#Requires -Version 7
<#
.SYNOPSIS
    Fix MiPay 模块一键打包脚本（本地与 GitHub Actions 共用）。
.DESCRIPTION
    必须使用 PowerShell 7+ 运行：5.1 的压缩会使用反斜杠路径分隔符导致 Magisk 无法解析。
.EXAMPLE
    pwsh ./scripts/build.ps1
    pwsh ./scripts/build.ps1 -VersionCode 2026082602
#>
[CmdletBinding()]
param(
    # 版本号。默认按 UTC 日期自动递增生成 yyyyMMddXX（01~99，兼顾历史 10 位日期版本号），亦可显式指定。
    [ValidateRange(1, [long]::MaxValue)]
    [long]$VersionCode,

    # 输出目录（默认仓库根下 out/）
    [string]$OutputDir = "out"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$moduleDir = Join-Path $repoRoot "module"
$outDir = if ([IO.Path]::IsPathRooted($OutputDir)) { $OutputDir } else { Join-Path $repoRoot $OutputDir }

# ---------- 解析 module.prop 模板 ----------
$templatePath = Join-Path $moduleDir "module.prop"
$template = Get-Content $templatePath -Raw
$id = ([regex]::Match($template, '(?m)^id=(.+?)\s*$')).Groups[1].Value
$version = ([regex]::Match($template, '(?m)^version=(.+?)\s*$')).Groups[1].Value
if (-not $id -or -not $version) { throw "module.prop 缺少 id 或 version 字段" }

if (-not $VersionCode) {
    $today = (Get-Date).ToString('yyyyMMdd')
    $existingSeq = [System.Collections.Generic.List[int]]::new()

    # 1. 检查 Update/update.json 中已记录的版本号
    $manifestPath = Join-Path $repoRoot "Update/update.json"
    if (Test-Path $manifestPath) {
        try {
            $manifestJson = Get-Content $manifestPath -Raw | ConvertFrom-Json
            $vcStr = [string]$manifestJson.versionCode
            if ($vcStr -match "^$today(\d{2})$") {
                $existingSeq.Add([int]$Matches[1])
            }
        } catch {}
    }

    # 2. 检查输出目录中已存在的产物
    if (Test-Path $outDir) {
        Get-ChildItem -Path $outDir -Filter "${id}_*_${today}*.zip" -File -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Name -match "_${today}(\d{2})\.zip$") {
                $existingSeq.Add([int]$Matches[1])
            }
        }
    }

    # 3. 计算下一序号（01~99）
    $nextSeq = if ($existingSeq.Count -gt 0) {
        ($existingSeq | Measure-Object -Maximum).Maximum + 1
    } else {
        1
    }

    if ($nextSeq -gt 99) {
        throw "当天打包序号已超出 99 上限（$today）"
    }

    $VersionCode = [long]"${today}$($nextSeq.ToString('00'))"
}

Write-Host "== 打包 ${id} v${version} (versionCode=$VersionCode) =="

# ---------- 暂存并注入占位符 ----------
$staging = Join-Path $outDir "staging"
if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item $staging -ItemType Directory -Force | Out-Null

# -Force 确保收录隐藏/点文件（如 MITSMClientGlobal/.replace）
Copy-Item (Join-Path $moduleDir "*") $staging -Recurse -Force

$stagedPropPath = Join-Path $staging "module.prop"
if (-not (Test-Path $stagedPropPath)) { throw "暂存目录中缺少 module.prop" }
(Get-Content $stagedPropPath -Raw) -replace '\$\{VERSION_CODE\}', $VersionCode |
    Set-Content $stagedPropPath -NoNewline
if ((Get-Content $stagedPropPath -Raw) -match '\$\{') {
    throw "module.prop 存在未解析的占位符"
}

# ---------- 压缩 ----------
# 使用 .NET ZipFile 而非 Compress-Archive：后者在 Linux 上会跳过点文件，
# 导致 MITSMClientGlobal/.replace 丢失；ZipFile 枚举不区分隐藏属性。
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipName = "${id}_v${version}_${VersionCode}.zip"
$zipPath = Join-Path $outDir $zipName
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($staging, $zipPath)

Remove-Item $staging -Recurse -Force

# ---------- 校验关键条目 ----------
$requiredEntries = @(
    "module.prop",
    "customize.sh",
    "service.sh",
    "sepolicy.rule",
    "META-INF/com/google/android/update-binary",
    "system/product/app/MITSMClientGlobal/.replace"
)
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    $entries = $zip.Entries.FullName
    $missing = $requiredEntries | Where-Object { $_ -notin $entries }
    if ($missing) { throw "zip 缺少关键条目：$($missing -join ', ')" }
}
finally {
    $zip.Dispose()
}

$sizeMb = "{0:N1}" -f ((Get-Item $zipPath).Length / 1MB)
Write-Host "== 完成：$zipPath ($sizeMb MB) =="

# ---------- 输出给 GitHub Actions 后续步骤使用 ----------
if ($env:GITHUB_OUTPUT) {
    Add-Content $env:GITHUB_OUTPUT "version=$version"
    Add-Content $env:GITHUB_OUTPUT "versionCode=$VersionCode"
    Add-Content $env:GITHUB_OUTPUT "zipName=$zipName"
}
