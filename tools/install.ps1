<#
.SYNOPSIS
  Installs the mod into the game: its scripts (red-cli install) and its TweakXL files (tweaks/*.yaml).

.DESCRIPTION
  Runs red-cli install, which copies src\redscript\PreemWeaponsmith into
  <game>\r6\scripts\PreemWeaponsmith, then replaces <game>\r6\tweaks\PreemWeaponsmith with the repo's
  tweaks/*.yaml (red-cli 0.5.1 installs only scripts). -ScriptsOnly skips the YAML step and leaves
  r6\tweaks as it is: the red run of a tweak move, where the scripts lose the moved code but the
  game doesn't get the new YAML yet. Never runs while the game is open. Dev code is installed
  separately by tools/dev-install.ps1.

.EXAMPLE
  pwsh tools/install.ps1
  pwsh tools/install.ps1 -ScriptsOnly
#>
[CmdletBinding()]
param(
  # Game folder; defaults to the REDCLI_GAME environment variable (same one red-cli uses).
  [string]$GamePath = $env:REDCLI_GAME,
  [switch]$ScriptsOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Fail([string]$msg) { Write-Host "install: $msg" -ForegroundColor Red; exit 1 }

if (-not $GamePath) { Fail 'no game folder: set REDCLI_GAME or pass -GamePath' }
$scripts = Join-Path $GamePath 'r6\scripts'
if (-not (Test-Path -LiteralPath $scripts)) { Fail "not a game folder (no r6\scripts): $GamePath" }
if (Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue) { Fail 'Cyberpunk 2077 is running; close it first' }

# red-cli reads the game folder from REDCLI_GAME and red.config.json from the working directory.
$env:REDCLI_GAME = $GamePath
Push-Location (Join-Path $PSScriptRoot '..')
try { & red-cli install; $code = $LASTEXITCODE } finally { Pop-Location }
$modScripts = Join-Path $scripts 'PreemWeaponsmith'
if ($code -ne 0 -or -not (Test-Path -LiteralPath $modScripts)) { Fail "red-cli install failed (exit $code)" }
$count = @(Get-ChildItem -LiteralPath $modScripts -Recurse -File -Filter *.reds).Count
Write-Host "install: r6\scripts\PreemWeaponsmith ($count files)"

if ($ScriptsOnly) {
  Write-Host 'install: -ScriptsOnly, r6\tweaks left as it is'
  exit 0
}
# TweakXL reads every .yaml under r6\tweaks at startup.
$tweakSrc = Join-Path $PSScriptRoot '..\tweaks'
$tweakDest = Join-Path $GamePath 'r6\tweaks\PreemWeaponsmith'
if (Test-Path -LiteralPath $tweakDest) { Remove-Item -LiteralPath $tweakDest -Recurse -Force }
$yaml = @(Get-ChildItem -LiteralPath $tweakSrc -File -Filter *.yaml)
New-Item -ItemType Directory -Force $tweakDest | Out-Null
foreach ($f in $yaml) { Copy-Item -LiteralPath $f.FullName -Destination $tweakDest }
Write-Host "install: r6\tweaks\PreemWeaponsmith ($($yaml.Count) files)"
exit 0
