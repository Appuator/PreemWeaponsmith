<#
.SYNOPSIS
  Pass or fail per row of a sound sweep run (dev/cet/sound-sweep.lua), from a boot check's logs.

.DESCRIPTION
  After `pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/sound-sweep.lua -HoldSec 965`, reads
  that run's CET logs from its log folder (scripting.log for the sweep's row lines, gamelog.log
  for the listener's "[PreemDev] sound: <event> on player's weapon <record>" lines) and prints
  one line per row: PASS with the number of expected events heard, FAIL, or MISS for a known
  expected miss (listed below). Rules: tools/SoundSweepLog.psm1.

  -LogDir is a logs\boot-<timestamp> folder; by default the newest one that holds sweep rows.
  Log copies from before 2026-10-26 22:11 hold every earlier run too: the script lists the runs
  it found and reports the last; -Run <n> picks another (1-based).

  Exit 1 on any failed row or when no sweep rows are found.
#>
param(
  [string]$LogDir,
  [int]$Run
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SoundSweepLog.psm1') -Force

# Rows that may play nothing, and why (runbook docs/PATCH-UPGRADE.md, "Expected numbers").
$knownMisses = @(
  @{ Weapon = 'Items.Preset_Ashura_Default'; Expect = 'w_gun_smg_smart_sidewinder_fire_auto'; Why = "the Ashura's 1-round magazine can't keep firing to start the Full-Auto loop (user, 2026-10-26)" }
)

$cetDir = 'bin\x64\plugins\cyber_engine_tweaks'
if (-not $LogDir) {
  $LogDir = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot '..\logs') -Directory -Filter 'boot-*' |
    Sort-Object Name -Descending |
    Where-Object { $s = Join-Path $_.FullName "$cetDir\scripting.log"; (Test-Path -LiteralPath $s) -and (Select-String -LiteralPath $s -Pattern '[PreemSweep]' -SimpleMatch -Quiet) } |
    Select-Object -First 1 -ExpandProperty FullName
  if (-not $LogDir) { Write-Host 'sound-sweep-report: no logs\boot-* folder has sweep rows' -ForegroundColor Red; exit 1 }
}
$scriptLog = Join-Path $LogDir "$cetDir\scripting.log"
$gameLog = Join-Path $LogDir "$cetDir\gamelog.log"
foreach ($f in $scriptLog, $gameLog) {
  if (-not (Test-Path -LiteralPath $f)) { Write-Host "sound-sweep-report: missing $f" -ForegroundColor Red; exit 1 }
}
Write-Host "sound-sweep-report: $LogDir"

$report = Get-SoundSweepReport -ScriptLines @(Get-Content -LiteralPath $scriptLog) -GameLines @(Get-Content -LiteralPath $gameLog) -KnownMisses $knownMisses -Run $Run
if (@($report.Runs).Count -eq 0) { Write-Host 'sound-sweep-report: no sweep rows in this log' -ForegroundColor Red; exit 1 }
if (@($report.Runs).Count -gt 1) {
  $i = 0
  foreach ($r in $report.Runs) { $i++; Write-Host ("sound-sweep-report: run {0} started {1:yyyy-MM-dd HH:mm:ss}, {2} rows" -f $i, $r.Start, $r.Rows) }
  Write-Host "sound-sweep-report: reporting run $($report.Run) (-Run <n> for another)"
}

foreach ($row in $report.Rows) {
  $label = "{0,3} {1} {2} expect {3}" -f $row.N, $row.Set, $row.Weapon, $row.Expect
  switch ($row.Status) {
    'pass' { Write-Host "PASS $label ($($row.Count) heard)" }
    'known miss' { Write-Host "MISS $label (known: $($row.Note))" -ForegroundColor Yellow }
    default { Write-Host "FAIL $label (not heard on the player's weapon)" -ForegroundColor Red }
  }
}
$pass = @($report.Rows | Where-Object Status -eq 'pass').Count
$miss = @($report.Rows | Where-Object Status -eq 'known miss').Count
$fail = @($report.Rows | Where-Object Status -eq 'fail').Count
Write-Host "sound-sweep-report: $pass passed, $fail failed, $miss known misses ($(@($report.Rows).Count) rows)"
if ($fail -gt 0) { Write-Host 'sound-sweep-report: FAILED' -ForegroundColor Red; exit 1 }
Write-Host 'sound-sweep-report: OK'
