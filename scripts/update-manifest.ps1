#Requires -Version 7
<#
.SYNOPSIS
    发版后同步生成 Update/update.json。
.EXAMPLE
    pwsh ./scripts/update-manifest.ps1 -Tag v1.1.2 -VersionCode 2026082601
#>
[CmdletBinding()]
param(
    # 发布 tag，如 v1.1.2
    [Parameter(Mandatory)]
    [ValidatePattern('^v')]
    [string]$Tag,

    [Parameter(Mandatory)]
    [long]$VersionCode,

    [string]$Repo = "StevenWin818/Magisk-Fix-MiPay",

    # 输出文件路径，默认仓库内 Update/update.json；测试时可指向临时文件
    [string]$OutFile
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$template = Get-Content (Join-Path $repoRoot "module/module.prop") -Raw
$id = ([regex]::Match($template, '(?m)^id=(.+?)\s*$')).Groups[1].Value
$rawVersion = ([regex]::Match($template, '(?m)^version=(.+?)\s*$')).Groups[1].Value
if (-not $id -or -not $rawVersion) { throw "module.prop 缺少 id 或 version 字段" }

# 规范化版本号并校验与 Tag 的一致性
$version = $rawVersion.TrimStart('v')
$expectedTag = "v$version"
if ($Tag -ne $expectedTag) {
    throw "Tag ($Tag) 与 module.prop 中的 version ($rawVersion) 不匹配，预期为 '$expectedTag'"
}

$manifest = [ordered]@{
    version     = "v$version"
    versionCode = $VersionCode
    zipUrl      = "https://github.com/$Repo/releases/download/$Tag/${id}_v${version}_${VersionCode}.zip"
    changelog   = "https://raw.githubusercontent.com/$Repo/main/Update/changelog.md"
}

$json = ConvertTo-Json -InputObject $manifest

if (-not $OutFile) { $OutFile = Join-Path $repoRoot "Update/update.json" }
Set-Content $OutFile $json -NoNewline
Write-Host "== 已写入 $OutFile =="
Get-Content $OutFile
