<#
.SYNOPSIS
  Vanilla play: runs the game with every mod and framework but CET turned off, for as long as you play.

.DESCRIPTION
  1. Moves aside, into game-folder-backup\vanilla-mode (tools/ConsoleMode.psm1 -Vanilla): RED4ext
     (winmm.dll and red4ext\), redscript (engine\tools\scc.exe, scc_lib.dll,
     engine\config\base\scripts.ini), and each entry of r6\scripts, r6\tweaks, archive\pc\mod and
     mods. CET stays for its console; its Lua mods in bin\x64\plugins\cyber_engine_tweaks\mods stay
     too, and any that call redscript code fail in this mode.
  2. Starts Cyberpunk2077.exe (no -modded, so REDmod mods stay off) and waits until the game has
     been closed for 15 s (Steam may restart the process once).
  3. Puts everything back and checks that r6\cache\final.redscripts still has the hash it had.
  Refuses to start when the game is running, the bundle isn't the vanilla one in -Snapshot, or a
  stash from an interrupted run is left (vanilla-mode or console-mode). If this window is closed
  while the game runs, nothing is put back: run with -RestoreOnly.
  Saves: loading a modded save here drops the mod's items when it next saves. Use a separate save
  slot, or a vanilla save.

.EXAMPLE
  pwsh tools/vanilla-play.ps1
  pwsh tools/vanilla-play.ps1 -RestoreOnly
#>
[CmdletBinding()]
param(
  [switch]$RestoreOnly,
  [string]$GamePath,
  [string]$Snapshot = (Join-Path $PSScriptRoot '..\..\game-snapshots\2.5_build26161058\final.redscripts'),
  [string]$StashRoot = (Join-Path $PSScriptRoot '..\..\game-folder-backup\vanilla-mode')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Fail([string]$msg) { Write-Host "vanilla-play: $msg" -ForegroundColor Red; exit 1 }
function Get-Game { Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue }

Import-Module (Join-Path $PSScriptRoot 'GamePath.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'ConsoleMode.psm1') -Force
$game = Resolve-GamePath -GamePath $GamePath -EnvValue $env:REDCLI_GAME
$GamePath = $game.Path
if ($game.Note) { Write-Host "vanilla-play: $($game.Note)" }
$exe = Join-Path $GamePath 'bin\x64\Cyberpunk2077.exe'
if (-not (Test-Path -LiteralPath $exe)) { Fail "game not found: $exe" }
if (Get-Game) { Fail 'Cyberpunk 2077 is running; close it first' }

function Restore-All {
  $left = @(Restore-ConsoleMode -StashRoot $StashRoot -GamePath $GamePath)
  if ($left.Count) { Write-Host "vanilla-play: left in $StashRoot because the game folder has them again: $($left -join ', ')" -ForegroundColor Red; return $false }
  Write-Host 'vanilla-play: mods restored'
  return $true
}

if ($RestoreOnly) { if (Restore-All) { exit 0 } else { exit 1 } }
if (Test-Path -LiteralPath $StashRoot) { Fail "a stash from an interrupted run is in $StashRoot; run with -RestoreOnly first" }
$consoleStash = Join-Path $PSScriptRoot '..\..\game-folder-backup\console-mode'
if (Test-Path -LiteralPath $consoleStash) { Fail "a console-boot stash is in $consoleStash; run tools/console-boot.ps1 -RestoreOnly first" }

$bundle = Join-Path $GamePath 'r6\cache\final.redscripts'
$before = (Get-FileHash -LiteralPath $bundle).Hash
if ($before -ne (Get-FileHash -LiteralPath $Snapshot).Hash) { Fail "r6\cache\final.redscripts is not the vanilla bundle ($Snapshot); fix that first (HANDOFF section 4, 2026-10-28)" }

$code = 0
$restored = $false
try {
  $moves = @(Get-ConsoleModeMoves -GamePath $GamePath -StashRoot $StashRoot -Vanilla)
  Move-ConsoleModeAside -Moves $moves
  Write-Host "vanilla-play: moved aside: $(@($moves | ForEach-Object Relative) -join ', ')"
  Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe)
  Write-Host 'vanilla-play: game started; mods come back once you quit the game. Keep this window open.' -ForegroundColor Yellow
  $seen = $false
  $goneSince = $null
  $start = Get-Date
  while ($true) {
    Start-Sleep -Seconds 2
    if (Get-Game) { $seen = $true; $goneSince = $null; continue }
    if (-not $seen -and ((Get-Date) - $start).TotalSeconds -gt 120) { Write-Host 'vanilla-play: the game never started' -ForegroundColor Red; $code = 1; break }
    if ($seen) {
      if (-not $goneSince) { $goneSince = Get-Date }
      elseif (((Get-Date) - $goneSince).TotalSeconds -gt 15) { break }
    }
  }
} finally {
  $restored = Restore-All
}
$after = (Get-FileHash -LiteralPath $bundle).Hash
if ($after -ne $before) { Write-Host 'vanilla-play: r6\cache\final.redscripts changed during the run; it is not vanilla any more (HANDOFF section 4, 2026-10-28)' -ForegroundColor Red; $code = 1 }
if (-not $restored) { $code = 1 }
Write-Host "vanilla-play: $(if ($code -eq 0) { 'OK' } else { 'FAILED' })" -ForegroundColor $(if ($code -eq 0) { 'Green' } else { 'Red' })
exit $code
