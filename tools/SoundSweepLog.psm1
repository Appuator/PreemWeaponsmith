# Reads a sound sweep (dev/cet/sound-sweep.lua) out of CET's logs: which rows played their
# expected event on the player's weapon. Used by tools/sound-sweep-report.ps1.
# Tests: tools/tests/SoundSweepLog.Tests.ps1.

$linePattern = '^\[(?<time>\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)[^\]]*\]'
$rowPattern = $linePattern + '.*\[PreemSweep\] (?<n>\d+) (?<set>\S+) (?<weapon>\S+) expect (?<expect>\S+)'
$soundPattern = $linePattern + ".*\[PreemDev\] sound: (?<event>\S+) on player's weapon (?<weapon>\S+)\s*$"

function ConvertTo-LogTime([string]$text) {
  [datetime]::ParseExact($text, 'yyyy-MM-dd HH:mm:ss', [cultureinfo]::InvariantCulture)
}

<#
  $ScriptLines: scripting.log (the sweep's "[PreemSweep] <n> <set> <weapon> expect <event>" row
  lines, printed when a row starts). $GameLines: gamelog.log (the listener's "[PreemDev] sound:
  <event> on player's weapon <record>" lines). A run starts at each row 1, so a log that holds
  several runs (the cumulative copies from before 2026-10-26 22:11) is split; -Run picks one
  (1-based, default the last). A row's window runs from its start to the next row's start, or
  $RowSeconds after it for the last row. A row passes when its expected event played on the
  player's weapon with the row's record in that window; a row in $KnownMisses (Weapon, Expect,
  Why) that played nothing is a "known miss", not a failure.
  Returns Runs (Start, Rows), Run (the one reported) and Rows (N, Set, Weapon, Expect, Count,
  Status pass / fail / known miss, Note).
#>
function Get-SoundSweepReport {
  param([string[]]$ScriptLines, [string[]]$GameLines, [object[]]$KnownMisses, [int]$Run, [int]$RowSeconds = 9)
  $runs = @()
  foreach ($line in $ScriptLines) {
    if ($line -notmatch $rowPattern) { continue }
    $row = [pscustomobject]@{
      N = [int]$Matches.n; Set = $Matches.set; Weapon = $Matches.weapon; Expect = $Matches.expect
      Start = ConvertTo-LogTime $Matches.time
    }
    if ($row.N -eq 1 -or $runs.Count -eq 0) { $runs += , [System.Collections.ArrayList]@() }
    $runs[-1].Add($row) | Out-Null
  }
  $summary = @($runs | ForEach-Object { [pscustomobject]@{ Start = $_[0].Start; Rows = $_.Count } })
  if ($runs.Count -eq 0) { return [pscustomobject]@{ Runs = @(); Run = 0; Rows = @() } }
  if ($Run -lt 1 -or $Run -gt $runs.Count) { $Run = $runs.Count }
  $rows = $runs[$Run - 1]

  $sounds = @(foreach ($line in $GameLines) {
    if ($line -match $soundPattern) {
      [pscustomobject]@{ Time = ConvertTo-LogTime $Matches.time; Event = $Matches.event; Weapon = $Matches.weapon }
    }
  })

  $report = for ($i = 0; $i -lt $rows.Count; $i++) {
    $row = $rows[$i]
    $end = if ($i + 1 -lt $rows.Count) { $rows[$i + 1].Start } else { $row.Start.AddSeconds($RowSeconds) }
    $count = @($sounds | Where-Object {
      $_.Time -ge $row.Start -and $_.Time -lt $end -and $_.Event -eq $row.Expect -and $_.Weapon -eq $row.Weapon
    }).Count
    $known = @($KnownMisses | Where-Object { $_.Weapon -eq $row.Weapon -and $_.Expect -eq $row.Expect }) | Select-Object -First 1
    $status = if ($count -gt 0) { 'pass' } elseif ($known) { 'known miss' } else { 'fail' }
    [pscustomobject]@{
      N = $row.N; Set = $row.Set; Weapon = $row.Weapon; Expect = $row.Expect; Count = $count
      Status = $status; Note = $(if ($known -and $count -eq 0) { $known.Why } else { '' })
    }
  }
  [pscustomobject]@{ Runs = $summary; Run = $Run; Rows = @($report) }
}

Export-ModuleMember -Function Get-SoundSweepReport
