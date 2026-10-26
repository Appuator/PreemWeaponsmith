<#
.SYNOPSIS
  Vanilla-marker comparison: checks every evolution variant (<base>_Preem<Evolution>) against the
  vanilla weapons of its old and new evolution.

.DESCRIPTION
  Boots to the main menu with dev/cet/weapon-dump.lua (every flat of every WeaponItem record, about
  70 MB) through tools/boot-check.ps1, or reads an existing dump with -Dump. Then flags a variant
  flat that holds an element at least -KeepShare of its old evolution's vanilla weapons carry and
  none of its new evolution's (keeps-old), or a list flat that lacks one at least -LackShare of its
  new evolution's carry (lacks-new). Only variants matching -VariantLike (default Items.Preset_*, the
  scope of the Phase 2 comparison) are reported; every other weapon record counts as vanilla. Rules
  in tools/VariantMarkers.psm1. Prints one line per flat and kind with the
  number of variants and the most common values; -Csv writes every row. Differences are expected
  (the stat groups are kept on purpose), so the exit code only says whether the run worked:
  0 = report printed, 1 = boot failed or the dump is missing or incomplete.

.EXAMPLE
  pwsh tools/variant-markers.ps1
  pwsh tools/variant-markers.ps1 -Dump logs/boot-2026-10-26_10-35-49/weapon-dump.txt -Csv logs/markers.csv
#>
[CmdletBinding()]
param(
  [string]$Dump,
  # Which variants to report (wildcard); every other weapon record still counts as vanilla.
  [string]$VariantLike = 'Items.Preset_*',
  [double]$KeepShare = 0.5,
  [double]$LackShare = 0.9,
  [string]$Csv,
  [int]$HoldSec = 40,
  [hashtable]$BootArgs = @{},
  [string]$LogRoot = (Join-Path $PSScriptRoot '..\logs')
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3
Import-Module (Join-Path $PSScriptRoot 'VariantMarkers.psm1') -Force

function Fail([string]$msg) { Write-Host "variant-markers: $msg" -ForegroundColor Red; exit 1 }

if (-not $Dump) {
  $before = Get-Date
  & (Join-Path $PSScriptRoot 'boot-check.ps1') -Run (Join-Path $PSScriptRoot '..\dev\cet\weapon-dump.lua') -HoldSec $HoldSec -LogRoot $LogRoot @BootArgs
  $bootExit = $LASTEXITCODE
  $runDir = @(Get-ChildItem -LiteralPath $LogRoot -Directory -Filter 'boot-*' |
    Where-Object LastWriteTime -ge $before.AddSeconds(-5) | Sort-Object Name)
  if ($runDir.Count -eq 0) { Fail 'no boot log folder from this run' }
  $Dump = Join-Path $runDir[-1].FullName 'weapon-dump.txt'
  if ($bootExit -ne 0) { Fail 'boot check failed (see above)' }
}
if (-not (Test-Path -LiteralPath $Dump)) { Fail "no dump at $Dump" }
$lines = [IO.File]::ReadAllLines((Resolve-Path -LiteralPath $Dump).Path)
if ($lines.Count -eq 0 -or $lines[-1] -notmatch '^-- end: ') { Fail "dump incomplete: $(if ($lines.Count) { $lines[-1] })" }
Write-Host "variant-markers: $Dump ($($lines[-1].Substring(3)))"

$records = ConvertFrom-FlatDump $lines
$rows = @(Get-VariantMarkerReport -Records $records -KeepShare $KeepShare -LackShare $LackShare -VariantLike $VariantLike)
$variants = @($records.Keys | Where-Object { $_ -like $VariantLike -and $_ -match '_Preem(Smart|Tech|Power)$' }).Count
if ($Csv) { $rows | Export-Csv -LiteralPath $Csv -NoTypeInformation; Write-Host "variant-markers: rows written to $Csv" }

Write-Host "variant-markers: $variants variants ($VariantLike), $($rows.Count) differences (keep >= $KeepShare of old, lack >= $LackShare of new)"
foreach ($g in ($rows | Group-Object Flat, Kind | Sort-Object { @($_.Group.Record | Select-Object -Unique).Count } -Descending)) {
  $count = @($g.Group.Record | Select-Object -Unique).Count
  $top = @($g.Group | Group-Object Value | Sort-Object Count -Descending | Select-Object -First 3 |
    ForEach-Object { "$($_.Name) ($($_.Count))" })
  $more = @($g.Group | Group-Object Value).Count - $top.Count
  Write-Host ("  {0,5}  {1}  {2}{3}" -f $count, $g.Name, ($top -join ', '), $(if ($more -gt 0) { ", +$more more" }))
}
exit 0
