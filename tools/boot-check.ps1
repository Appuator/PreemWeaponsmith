<#
.SYNOPSIS
  Boot check: launches the game, waits for the main menu, closes it, collects and checks the logs.

.DESCRIPTION
  Installs the dev CET mod dev/cet/PreemBoot (main-menu marker), starts Cyberpunk2077.exe with
  -skipStartScreen and waits until the marker file says the main menu controller initialized.
  Then it closes the game the way the window's close button does (logs are flushed only on a
  clean exit; killed only if it hangs), copies every log written during the run into
  logs\boot-<timestamp>\ and checks them:
    - redscript compiled (a "Compilation complete" line, no [ERROR] lines)
    - no error/critical lines in the RED4ext, plugin or CET logs
  Removes the marker mod again at the end, even on failure. Prints which script mods were
  installed in r6\scripts, so a framework-only boot can be told apart from a modded one.

  Never runs while the game is open (the user may be playing). Exit code 0 = reached the main
  menu with clean logs, 1 = timeout, crash, log errors or bad setup.

.EXAMPLE
  pwsh tools/boot-check.ps1
  pwsh tools/boot-check.ps1 -TimeoutSec 400
#>
[CmdletBinding()]
param(
  # Game folder; defaults to the REDCLI_GAME environment variable (same one red-cli uses).
  [string]$GamePath = $env:REDCLI_GAME,
  # How long to wait for the main menu marker.
  [int]$TimeoutSec = 300,
  # Where log captures go (gitignored).
  [string]$LogRoot = (Join-Path $PSScriptRoot '..\logs')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Fail([string]$msg) { Write-Host "boot-check: $msg" -ForegroundColor Red; exit 1 }
function Get-Game { Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue }

if (-not $GamePath) { Fail 'no game folder: set REDCLI_GAME or pass -GamePath' }
$exe = Join-Path $GamePath 'bin\x64\Cyberpunk2077.exe'
if (-not (Test-Path -LiteralPath $exe)) { Fail "game not found: $exe" }
if (Get-Game) { Fail 'Cyberpunk 2077 is running; close it first' }
$cetMods = Join-Path $GamePath 'bin\x64\plugins\cyber_engine_tweaks\mods'
if (-not (Test-Path -LiteralPath $cetMods)) { Fail 'CET not installed (the main-menu marker needs it)' }

$scriptMods = @(Get-ChildItem -LiteralPath (Join-Path $GamePath 'r6\scripts') -ErrorAction SilentlyContinue | ForEach-Object Name)
Write-Host "boot-check: script mods in r6\scripts: $(if ($scriptMods) { $scriptMods -join ', ' } else { 'none (framework-only boot)' })"

$markerMod = Join-Path $cetMods 'PreemBoot'
$marker = Join-Path $markerMod 'boot-marker.txt'
$start = Get-Date
$runDir = Join-Path $LogRoot ('boot-' + $start.ToString('yyyy-MM-dd_HH-mm-ss'))
$result = 'timeout'
$problems = @()

try {
  Remove-Item -LiteralPath $markerMod -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force $markerMod | Out-Null
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot '..\dev\cet\PreemBoot\init.lua') -Destination $markerMod

  Write-Host "boot-check: launching, waiting up to $TimeoutSec s for the main menu..."
  Start-Process -FilePath $exe -ArgumentList '-skipStartScreen' -WorkingDirectory (Split-Path $exe)
  $seen = $false
  $goneSince = $null
  while (((Get-Date) - $start).TotalSeconds -lt $TimeoutSec) {
    Start-Sleep -Seconds 1
    if ((Test-Path -LiteralPath $marker) -and (Select-String -LiteralPath $marker -Pattern 'main-menu' -SimpleMatch -Quiet)) {
      $result = 'main-menu'; break
    }
    # Steam may restart the process once, so only a lasting absence counts as a crash.
    if (Get-Game) { $seen = $true; $goneSince = $null }
    elseif ($seen) {
      if (-not $goneSince) { $goneSince = Get-Date }
      elseif (((Get-Date) - $goneSince).TotalSeconds -gt 15) { $result = 'exited'; break }
    }
  }
  $elapsed = ((Get-Date) - $start).TotalSeconds
  switch ($result) {
    'main-menu' { Write-Host ("boot-check: main menu after {0:N0} s" -f $elapsed) }
    'exited' { $problems += ("game exited after {0:N0} s without reaching the main menu (crash?)" -f $elapsed) }
    default { $problems += "no main menu within $TimeoutSec s" }
  }

  $game = Get-Game
  if ($game) {
    foreach ($p in $game) { $p.CloseMainWindow() | Out-Null }
    foreach ($p in $game) { $p.WaitForExit(60000) | Out-Null }
    if (Get-Game) {
      # Before the window exists (a timeout during loading) closing it does nothing.
      Get-Game | Stop-Process -Force
      Get-Game | Wait-Process -Timeout 60 -ErrorAction SilentlyContinue
      $problems += 'game did not close within 60 s and was killed (CET logs may be incomplete)'
    }
  }
} finally {
  # Keep the marker with the logs, then remove the mod from the game. A game that is still
  # exiting holds the files open for a few seconds.
  New-Item -ItemType Directory -Force $runDir | Out-Null
  if (Test-Path -LiteralPath $marker) { Copy-Item -LiteralPath $marker -Destination $runDir }
  for ($i = 0; $i -lt 10 -and (Test-Path -LiteralPath $markerMod); $i++) {
    Remove-Item -LiteralPath $markerMod -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $markerMod) { Start-Sleep -Seconds 3 }
  }
  if (Test-Path -LiteralPath $markerMod) { Write-Host "boot-check: could not remove $markerMod; delete it by hand" -ForegroundColor Yellow }
}

# Every log written during this run, keeping its path relative to the game folder.
$logs = @(foreach ($root in 'r6\logs', 'red4ext', 'bin\x64\plugins\cyber_engine_tweaks') {
  Get-ChildItem -LiteralPath (Join-Path $GamePath $root) -Recurse -File -Filter *.log -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $start }
})
foreach ($l in $logs) {
  $rel = $l.FullName.Substring($GamePath.TrimEnd('\').Length + 1)
  $dst = Join-Path $runDir $rel
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  Copy-Item -LiteralPath $l.FullName -Destination $dst
}

$redscriptLog = Join-Path $runDir 'r6\logs\redscript_rCURRENT.log'
if (-not (Test-Path -LiteralPath $redscriptLog)) {
  $problems += 'redscript did not run (no redscript_rCURRENT.log written)'
} else {
  $text = Get-Content -LiteralPath $redscriptLog
  if (-not ($text -match 'Compilation complete')) { $problems += 'redscript: no "Compilation complete" line' }
  foreach ($e in ($text -match '^\[ERROR')) { $problems += "redscript: $e" }
}
foreach ($l in (Get-ChildItem -LiteralPath $runDir -Recurse -File -Filter *.log)) {
  if ($l.Name -eq 'redscript_rCURRENT.log') { continue }
  foreach ($m in (Select-String -LiteralPath $l.FullName -Pattern '\[(error|critical)\s*\]')) {
    $problems += "$($l.Name): $($m.Line.Trim())"
  }
}

Write-Host "boot-check: $($logs.Count) logs saved to $((Resolve-Path -LiteralPath $runDir).Path)"
if ($problems) {
  foreach ($p in $problems) { Write-Host "  $p" -ForegroundColor Red }
  Write-Host 'boot-check: FAILED' -ForegroundColor Red
  exit 1
}
Write-Host 'boot-check: OK' -ForegroundColor Green
exit 0
