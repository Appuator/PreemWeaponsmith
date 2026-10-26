<#
.SYNOPSIS
  Installs (or removes) the dev-only scripts: PreemDev (debug exec functions, tests) and RedTest.

.DESCRIPTION
  Copies the .reds files of dev/redscript/PreemDev and dev/redscript/RedTest into
  <game>\r6\scripts\PreemDev and <game>\r6\scripts\RedTest, replacing what is there.
  -Uninstall removes both folders. Never touches the mod itself (its scripts and TweakXL files:
  tools/install.ps1 does that) and never runs while the game is open. Dev code is never part of
  a release.

.EXAMPLE
  pwsh tools/dev-install.ps1
  pwsh tools/dev-install.ps1 -Uninstall
#>
[CmdletBinding()]
param(
  # Game folder; defaults to the REDCLI_GAME environment variable (same one red-cli uses).
  [string]$GamePath = $env:REDCLI_GAME,
  [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Fail([string]$msg) { Write-Host "dev-install: $msg" -ForegroundColor Red; exit 1 }

if (-not $GamePath) { Fail 'no game folder: set REDCLI_GAME or pass -GamePath' }
$scripts = Join-Path $GamePath 'r6\scripts'
if (-not (Test-Path -LiteralPath $scripts)) { Fail "not a game folder (no r6\scripts): $GamePath" }
if (Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue) { Fail 'Cyberpunk 2077 is running; close it first' }

foreach ($name in 'PreemDev', 'RedTest') {
  $dest = Join-Path $scripts $name
  if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
  if ($Uninstall) { Write-Host "dev-install: removed r6\scripts\$name"; continue }

  $src = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\dev\redscript\$name")).Path
  $files = @(Get-ChildItem -LiteralPath $src -Recurse -File -Filter *.reds)
  if ($files.Count -eq 0) { Fail "no .reds files in $src (RedTest is a submodule: git submodule update --init)" }
  foreach ($f in $files) {
    $target = Join-Path $dest $f.FullName.Substring($src.Length + 1)
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
    Copy-Item -LiteralPath $f.FullName -Destination $target
  }
  Write-Host "dev-install: r6\scripts\$name ($($files.Count) files)"
}
exit 0
