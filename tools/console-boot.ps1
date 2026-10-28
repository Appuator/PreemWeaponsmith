<#
.SYNOPSIS
  Console-mode boot: runs the game the way a console player has it, with one mod.io-style script mod.

.DESCRIPTION
  1. Compiles -Mod (a folder with r6\scripts\...\*.script) with REDmod's validate-mod-scripts
     -compile, in a temp copy, against the game's vanilla r6\cache\final.redscripts.
  2. Moves the PC-only parts aside for the run (tools/ConsoleMode.psm1): RED4ext, redscript's
     engine\tools\scc.exe, scc_lib.dll and engine\config\base\scripts.ini, and every entry of
     r6\scripts. CET stays: it marks the main menu and keeps the game log.
  3. Puts the compiled patch in <game>\r6\c77 and runs tools/boot-check.ps1 -ConsoleMode
     -ExtraArgs -LoadScriptMods (with -Run, -HoldSec, -Screenshot passed on). CET doesn't show
     FTLog lines in this mode (no game log was written); read results with a -Run script instead.
     About 30 s after the main menu the game loads the newest save by itself in this mode.
  4. Always puts everything back, removes r6\c77, and checks that r6\cache\final.redscripts still
     has the hash it had before the run.
  Refuses to start when the vanilla bundle isn't the one in -Snapshot, when r6\c77 exists, or when
  a stash from an interrupted run is left (-RestoreOnly puts that back).
  Exit code 0 = main menu reached, clean logs, folder restored; 1 otherwise.

.EXAMPLE
  pwsh tools/console-boot.ps1 -Mod dev/modio/wrap-probe -Run dev/cet/logo-check.lua -HoldSec 40
  pwsh tools/console-boot.ps1 -RestoreOnly
#>
[CmdletBinding()]
param(
  [string]$Mod,
  # A Lua file to run as a one-off CET mod (boot-check -Run), e.g. dev/cet/logo-check.lua.
  [string]$Run,
  [int]$HoldSec = 0,
  [switch]$Screenshot,
  [switch]$RestoreOnly,
  [string]$GamePath,
  # The vanilla bundle of the current patch; the game's must match it before and after.
  [string]$Snapshot = (Join-Path $PSScriptRoot '..\..\game-snapshots\2.5_build26161058\final.redscripts'),
  [string]$StashRoot = (Join-Path $PSScriptRoot '..\..\game-folder-backup\console-mode')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Fail([string]$msg) { Write-Host "console-boot: $msg" -ForegroundColor Red; exit 1 }

Import-Module (Join-Path $PSScriptRoot 'GamePath.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'ConsoleMode.psm1') -Force
$game = Resolve-GamePath -GamePath $GamePath -EnvValue $env:REDCLI_GAME
$GamePath = $game.Path
if (Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue) { Fail 'Cyberpunk 2077 is running; close it first' }

function Restore-All {
  $left = @(Restore-ConsoleMode -StashRoot $StashRoot -GamePath $GamePath)
  if ($left.Count) { Write-Host "console-boot: left in $StashRoot because the game folder has them again: $($left -join ', ')" -ForegroundColor Red; return $false }
  Write-Host 'console-boot: game folder restored'
  return $true
}

if ($RestoreOnly) { if (Restore-All) { exit 0 } else { exit 1 } }
if (Test-Path -LiteralPath $StashRoot) { Fail "a stash from an interrupted run is in $StashRoot; run with -RestoreOnly first" }
if (-not $Mod) { Fail '-Mod is required' }
$modScripts = Join-Path $Mod 'r6\scripts'
if (-not (Test-Path -LiteralPath $modScripts)) { Fail "no r6\scripts in $Mod" }

$bundle = Join-Path $GamePath 'r6\cache\final.redscripts'
$vanilla = (Get-FileHash -LiteralPath $Snapshot).Hash
$before = (Get-FileHash -LiteralPath $bundle).Hash
if ($before -ne $vanilla) { Fail "r6\cache\final.redscripts is not the vanilla bundle ($Snapshot); fix that first (HANDOFF section 4, 2026-10-28)" }
if (Test-Path -LiteralPath (Join-Path $bundle '..\final.redscripts.bk')) { Fail 'r6\cache\final.redscripts.bk exists; see HANDOFF section 4, 2026-10-28' }
$c77 = Join-Path $GamePath 'r6\c77'
if (Test-Path -LiteralPath $c77) { Fail "$c77 exists; remove it first" }

# 1. Compile the mod the mod.io way, in a temp copy (REDmod writes about.json and r6\cache into it).
$work = Join-Path ([IO.Path]::GetTempPath()) "preem-console-boot-$PID"
Copy-Item -LiteralPath (Resolve-Path -LiteralPath $Mod).Path -Destination $work -Recurse
$redmod = Join-Path $GamePath 'tools\redmod\bin\redMod.exe'
Push-Location $work
try { $out = @(& $redmod validate-mod-scripts -root $GamePath -compile -directory $work 2>&1 | ForEach-Object { "$_" }) }
finally { Pop-Location }
$patch = Join-Path $work 'r6\cache\final.redscripts'
if (-not (Test-Path -LiteralPath $patch)) {
  $out | Where-Object { $_ -match '\.script\(|Failed|failed' } | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
  Remove-Item -LiteralPath $work -Recurse -Force
  Fail "REDmod did not compile $Mod"
}
Write-Host "console-boot: compiled $Mod ($((Get-Item -LiteralPath $patch).Length) bytes)"

# 2.-4.
$code = 1
$restored = $false
try {
  $moves = @(Get-ConsoleModeMoves -GamePath $GamePath -StashRoot $StashRoot)
  Move-ConsoleModeAside -Moves $moves
  Write-Host "console-boot: moved aside: $(@($moves | ForEach-Object Relative) -join ', ')"
  New-Item -ItemType Directory -Force $c77 | Out-Null
  Copy-Item -LiteralPath $patch, "$patch.h64" -Destination $c77
  $bootArgs = @{ ConsoleMode = $true; ExtraArgs = @('-LoadScriptMods'); HoldSec = $HoldSec; Screenshot = $Screenshot; GamePath = $GamePath }
  if ($Run) { $bootArgs.Run = (Resolve-Path -LiteralPath $Run).Path }
  & (Join-Path $PSScriptRoot 'boot-check.ps1') @bootArgs
  $code = $LASTEXITCODE
} finally {
  Remove-Item -LiteralPath $c77 -Recurse -Force -ErrorAction SilentlyContinue
  $restored = Restore-All
  Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
$after = (Get-FileHash -LiteralPath $bundle).Hash
if ($after -ne $before) { Write-Host 'console-boot: r6\cache\final.redscripts changed during the run; it is not vanilla any more (HANDOFF section 4, 2026-10-28)' -ForegroundColor Red; $code = 1 }
else { Write-Host 'console-boot: vanilla bundle unchanged' }
if (-not $restored) { $code = 1 }
Write-Host "console-boot: $(if ($code -eq 0) { 'OK' } else { 'FAILED' })" -ForegroundColor $(if ($code -eq 0) { 'Green' } else { 'Red' })
exit $code
