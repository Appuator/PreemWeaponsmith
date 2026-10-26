<#
.SYNOPSIS
  Record dump: boots to the main menu with dev/cet/tweak-dump.lua and compares its dump of every
  Items.Preem* and AttachmentSlots.Preem* TweakDB flat with the committed baseline.

.DESCRIPTION
  Runs tools/boot-check.ps1 -Run dev/cet/tweak-dump.lua, takes tweak-dump.txt from the run's log
  folder and checks it is complete (last line "-- end: ..."). Then compares it line by line with
  -Baseline (default dev/baseline/tweak-dump.txt) and prints the lines only one side has.
  -SaveBaseline writes the dump as the new baseline instead. Pass -BootArgs for extra boot-check
  options (e.g. @{ Without = 'Mod Settings' }). Exit 0 = dump identical (or baseline saved),
  1 = boot failed, dump missing or incomplete, or differences.

.EXAMPLE
  pwsh tools/tweak-dump.ps1
  pwsh tools/tweak-dump.ps1 -SaveBaseline
#>
[CmdletBinding()]
param(
  [string]$Baseline = (Join-Path $PSScriptRoot '..\dev\baseline\tweak-dump.txt'),
  [switch]$SaveBaseline,
  [int]$HoldSec = 15,
  [hashtable]$BootArgs = @{},
  [string]$LogRoot = (Join-Path $PSScriptRoot '..\logs')
)
$ErrorActionPreference = 'Stop'

function Fail([string]$msg) { Write-Host "tweak-dump: $msg" -ForegroundColor Red; exit 1 }

$before = Get-Date
& (Join-Path $PSScriptRoot 'boot-check.ps1') -Run (Join-Path $PSScriptRoot '..\dev\cet\tweak-dump.lua') -HoldSec $HoldSec -LogRoot $LogRoot @BootArgs
$bootExit = $LASTEXITCODE
$runDir = @(Get-ChildItem -LiteralPath $LogRoot -Directory -Filter 'boot-*' |
  Where-Object LastWriteTime -ge $before.AddSeconds(-5) | Sort-Object Name)
if ($runDir.Count -eq 0) { Fail 'no boot log folder from this run' }
$dump = Join-Path $runDir[-1].FullName 'tweak-dump.txt'
if (-not (Test-Path -LiteralPath $dump)) { Fail "no tweak-dump.txt in $($runDir[-1].FullName)" }
$lines = @(Get-Content -LiteralPath $dump)
if ($lines.Count -eq 0 -or $lines[-1] -notmatch '^-- end: ') { Fail "dump incomplete: $($lines | Select-Object -Last 1)" }
Write-Host "tweak-dump: $dump ($($lines[-1].Substring(3)))"
if ($bootExit -ne 0) { Fail 'boot check failed (see above)' }

if ($SaveBaseline) {
  New-Item -ItemType Directory -Force (Split-Path $Baseline) | Out-Null
  Copy-Item -LiteralPath $dump -Destination $Baseline
  Write-Host "tweak-dump: baseline saved to $((Resolve-Path -LiteralPath $Baseline).Path)"
  exit 0
}
if (-not (Test-Path -LiteralPath $Baseline)) { Fail "no baseline at $Baseline (run with -SaveBaseline)" }
$diff = @(Compare-Object -ReferenceObject @(Get-Content -LiteralPath $Baseline) -DifferenceObject $lines -CaseSensitive)
if ($diff.Count -eq 0) { Write-Host 'tweak-dump: identical to the baseline' -ForegroundColor Green; exit 0 }
Write-Host "tweak-dump: $($diff.Count) lines differ from the baseline (<= baseline only, => this dump only):" -ForegroundColor Red
$diff | Sort-Object InputObject | Select-Object -First 40 | ForEach-Object { Write-Host "  $($_.SideIndicator) $($_.InputObject)" }
if ($diff.Count -gt 40) { Write-Host "  ... $($diff.Count - 40) more" }
exit 1
