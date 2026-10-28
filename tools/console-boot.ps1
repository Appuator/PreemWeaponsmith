<#
.SYNOPSIS
  Console-mode boot: runs the game the way a console player has it, with one mod.io-style script mod.

.DESCRIPTION
  1. Compiles -Mod (a folder with r6\scripts\...\*.script) with REDmod's validate-mod-scripts
     -compile, in a temp copy, against the game's vanilla r6\cache\final.redscripts.
  2. Moves the PC-only parts aside for the run (tools/ConsoleMode.psm1): RED4ext, redscript's
     engine\tools\scc.exe, scc_lib.dll and engine\config\base\scripts.ini, and every entry of
     r6\scripts. CET stays: it marks the main menu and keeps the game log.
  3. Copies the whole compiled mod folder (r6\scripts, r6\cache, about.json) to
     <game>\r6\c77\<mod folder name>, the layout in redscript PR #207's conversion guide (the folder
     name must not contain a period), and runs tools/boot-check.ps1 -ConsoleMode -ExtraArgs
     -LoadScriptMods -logScripts -TimeoutSec <TimeoutSec> (with -Run, -HoldSec, -Screenshot passed
     on). While a c77 script mod is loaded CET sees no game types, so its main-menu marker never
     fires: boot-check always reports "no main menu" and its verdict is ignored here. Results come
     from ScriptLog lines: -logScripts writes <game>\ScriptLogger.log, which is moved to logs/ and
     its binding and [Preem lines printed.
  4. Always puts everything back, removes r6\c77, and checks that r6\cache\final.redscripts still
     has the hash it had before the run.
  Refuses to start when the vanilla bundle isn't the one in -Snapshot, when r6\c77 exists, or when
  a stash from an interrupted run is left (-RestoreOnly puts that back).
  Exit code 0 = the mod bound ("Success binding script mod"), every -Expect regex matched a
  ScriptLogger.log line, folder restored, bundle unchanged; 1 otherwise.

.EXAMPLE
  pwsh tools/console-boot.ps1 -Mod dev/modio/wrap-probe -Expect 'loop 1: status=7777 authorize=1009'
  pwsh tools/console-boot.ps1 -RestoreOnly
#>
[CmdletBinding()]
param(
  [string]$Mod,
  # A Lua file to run as a one-off CET mod (boot-check -Run), e.g. dev/cet/logo-check.lua.
  [string]$Run,
  [int]$HoldSec = 0,
  [switch]$Screenshot,
  # How long the game runs; the main menu's OnInitialize comes about 12 s after launch.
  [int]$TimeoutSec = 60,
  # Regexes that must each match a ScriptLogger.log line for exit code 0.
  [string[]]$Expect = @(),
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
$modName = Split-Path -Leaf (Resolve-Path -LiteralPath $Mod).Path
if ($modName -match '\.') { Fail "the mod folder name '$modName' contains a period; the game skips such folders" }

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
  Copy-Item -LiteralPath $work -Destination (Join-Path $c77 $modName) -Recurse
  Write-Host "console-boot: installed as r6\c77\$modName ($(@(Get-ChildItem -LiteralPath (Join-Path $c77 $modName) -Recurse -File).Count) files)"
  $bootArgs = @{ ConsoleMode = $true; ExtraArgs = @('-LoadScriptMods', '-logScripts'); TimeoutSec = $TimeoutSec; HoldSec = $HoldSec; Screenshot = $Screenshot; GamePath = $GamePath }
  if ($Run) { $bootArgs.Run = (Resolve-Path -LiteralPath $Run).Path }
  & (Join-Path $PSScriptRoot 'boot-check.ps1') @bootArgs
  Write-Host "console-boot: boot-check exit $LASTEXITCODE (ignored: CET can't mark the main menu in this mode)"
} finally {
  # -logScripts writes ScriptLogger.log (ScriptLog lines, script errors) into the game folder root.
  $scriptLog = Join-Path $GamePath 'ScriptLogger.log'
  $logLines = @()
  if (Test-Path -LiteralPath $scriptLog) {
    $kept = Join-Path $PSScriptRoot "..\logs\console-boot-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')-ScriptLogger.log"
    Move-Item -LiteralPath $scriptLog -Destination $kept -Force
    Write-Host "console-boot: ScriptLogger.log saved to $kept"
    $logLines = @(Get-Content -LiteralPath $kept)
    $logLines | Where-Object { $_ -match 'script mod|\[Preem' } | ForEach-Object { Write-Host "  $_" }
  }
  $problems = @(Get-ConsoleBootProblems -Lines $logLines -Expect $Expect)
  foreach ($p in $problems) { Write-Host "console-boot: $p" -ForegroundColor Red }
  $code = if ($problems.Count) { 1 } else { 0 }
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
