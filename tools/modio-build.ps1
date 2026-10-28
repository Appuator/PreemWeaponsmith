<#
.SYNOPSIS
  Builds the mod.io build from the PC source into stage\modio (ADR 0003).

.DESCRIPTION
  Checks that modio/manifest.json lists every .reds file under the source folder, then writes each
  file it marks "convert" to stage\modio\r6\scripts\PreemWeaponsmith as a .script file (the official
  compiler reads only .script), rewritten by the converter (tools/ModioConvert.psm1). Files marked
  "pc-only" are left out. stage\modio is emptied first; it is generated and never edited by hand.
  tools/modio-compile-check.ps1 runs this before compiling.
  Exit code 0 = built, 1 = manifest out of step with the source.

.EXAMPLE
  pwsh tools/modio-build.ps1
#>
[CmdletBinding()]
param(
  [string]$Src = (Join-Path $PSScriptRoot '..\src\redscript\PreemWeaponsmith'),
  [string]$Manifest = (Join-Path $PSScriptRoot '..\modio\manifest.json'),
  [string]$Stage = (Join-Path $PSScriptRoot '..\stage\modio')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Fail([string]$msg) { Write-Host "modio-build: $msg" -ForegroundColor Red; exit 1 }

Import-Module (Join-Path $PSScriptRoot 'ModioCompile.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'ModioConvert.psm1') -Force

# Manifest against the source folder.
$srcRoot = (Resolve-Path -LiteralPath $Src).Path
$sourceFiles = @(Get-ChildItem -LiteralPath $srcRoot -Recurse -Filter *.reds -File |
  ForEach-Object { $_.FullName.Substring($srcRoot.Length + 1).Replace('\', '/') })
if (-not (Test-Path -LiteralPath $Manifest)) { Fail "manifest not found: $Manifest" }
$entries = @{}
(Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json).files.PSObject.Properties |
  ForEach-Object { $entries[$_.Name] = [string]$_.Value }
$cmp = Compare-ModioManifest -SourceFiles $sourceFiles -Entries $entries
foreach ($f in $cmp.Missing) { Write-Host "manifest: no entry for $f" -ForegroundColor Red }
foreach ($f in $cmp.Unknown) { Write-Host "manifest: entry for a file that doesn't exist: $f" -ForegroundColor Red }
foreach ($f in $cmp.BadAction) { Write-Host "manifest: ${f}: action '$($entries[$f])' is not convert or pc-only" -ForegroundColor Red }
if ($cmp.Missing.Count + $cmp.Unknown.Count + $cmp.BadAction.Count) { Fail "fix $Manifest" }

# Convert the "convert" files into .script files.
$scripts = Join-Path $Stage 'r6\scripts\PreemWeaponsmith'
if (Test-Path -LiteralPath $Stage) { Remove-Item -LiteralPath $Stage -Recurse -Force }
$converted = @($sourceFiles | Where-Object { $entries[$_] -eq 'convert' })
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($f in $converted) {
  $dest = Join-Path $scripts ([IO.Path]::ChangeExtension($f, '.script'))
  New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
  $text = [IO.File]::ReadAllText((Join-Path $srcRoot $f))
  [IO.File]::WriteAllText($dest, (Convert-ModioSource -Text $text), $utf8)
}
Write-Host ("modio-build: {0} files converted into {1} ({2} pc-only left out)" -f
  $converted.Count, (Resolve-Path -LiteralPath $Stage).Path, ($sourceFiles.Count - $converted.Count))
exit 0
