<#
.SYNOPSIS
  mod.io compile check: compiles the mod.io build with CDPR's official script compiler, no game launch.

.DESCRIPTION
  Runs tools/modio-build.ps1 (manifest check, converter, stage\modio), then runs
  <game>\tools\redmod\bin\scc.exe -compile on the result against the vanilla r6\cache\final.redscripts.
  It does for the mod.io build what tools/compile-check.ps1 does for the PC build (ADR 0003).

  A manifest out of step with the source stops the check before compiling. The compiled bundle
  goes to a temp file and is thrown away; the game folder is never written.

  scc.exe runs with -logjson: its plain log interleaves its threads' lines, and -threads 1 stops at
  the first file that fails to parse (tools/ModioCompile.psm1). Prints the errors grouped by file
  and a total. The JSON log is saved to logs\modio-compile-check.log.
  Exit code 0 = compiles, 1 = compile errors or bad setup.

.EXAMPLE
  pwsh tools/modio-compile-check.ps1
#>
[CmdletBinding()]
param(
  # Game folder; default: REDCLI_GAME, else the CLAUDE.md folder (tools/GamePath.psm1).
  [string]$GamePath,
  # Vanilla bundle to compile against. Default: <game>\r6\cache\final.redscripts (redscript 0.5.32
  # leaves it vanilla; CLAUDE.md Gotchas).
  [string]$Bundle,
  [string]$Src = (Join-Path $PSScriptRoot '..\src\redscript\PreemWeaponsmith'),
  [string]$Manifest = (Join-Path $PSScriptRoot '..\modio\manifest.json'),
  [string]$Stage = (Join-Path $PSScriptRoot '..\stage\modio'),
  [string]$LogFile = (Join-Path $PSScriptRoot '..\logs\modio-compile-check.log')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Fail([string]$msg) { Write-Host "modio-compile-check: $msg" -ForegroundColor Red; exit 1 }

Import-Module (Join-Path $PSScriptRoot 'GamePath.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'ModioCompile.psm1') -Force
$game = Resolve-GamePath -GamePath $GamePath -EnvValue $env:REDCLI_GAME
$GamePath = $game.Path
if ($game.Note) { Write-Host "modio-compile-check: $($game.Note)" }
if (-not (Test-Path -LiteralPath $GamePath)) { Fail "game folder not found: $GamePath" }
$scc = Join-Path $GamePath 'tools\redmod\bin\scc.exe'
if (-not (Test-Path -LiteralPath $scc)) { Fail "official compiler not found: $scc (install REDmod from the game's DLC list)" }
if (-not $Bundle) { $Bundle = Join-Path $GamePath 'r6\cache\final.redscripts' }
if (-not (Test-Path -LiteralPath $Bundle)) { Fail "bundle not found: $Bundle" }

# Build the mod.io build (manifest check, convert, stage).
& (Join-Path $PSScriptRoot 'modio-build.ps1') -Src $Src -Manifest $Manifest -Stage $Stage
if ($LASTEXITCODE -ne 0) { Fail 'build failed' }

# Compile.
$out = Join-Path ([IO.Path]::GetTempPath()) "preem-modio-compile-check-$PID.redscripts"
Write-Host "modio-compile-check: $scc against $Bundle"
$lines = @(& $scc -compile (Join-Path $Stage 'r6\scripts') $out -optionalPrecompiledBlobPath $Bundle -logjson 2>&1 |
  ForEach-Object { "$_" })
$exit = $LASTEXITCODE
Remove-Item -LiteralPath $out -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force (Split-Path $LogFile) | Out-Null
$lines | Set-Content -LiteralPath $LogFile -Encoding utf8

$log = Read-SccLog -Lines $lines
foreach ($g in Group-SccDiagnostic -Diagnostics $log.Diagnostics) {
  Write-Host ("{0,4}  {1}" -f $g.Count, $g.File) -ForegroundColor Red
  foreach ($d in @($log.Diagnostics | Where-Object { $_.Level -eq 'Error' -and $_.File -eq $g.File })) {
    Write-Host "        $($d.Line): $($d.Message)"
  }
}
foreach ($o in $log.Other) { Write-Host $o -ForegroundColor Red }
if (-not $log.Summary) { Fail "the compiler stopped without a summary (exit $exit). Full output: $LogFile" }
Write-Host ("modio-compile-check: {0} errors, {1} warnings. Full output: {2}" -f
  $log.ErrorCount, $log.WarningCount, (Resolve-Path -LiteralPath $LogFile).Path)

if ($log.ErrorCount -gt 0 -or $exit -ne 0) { Write-Host 'modio-compile-check: FAILED' -ForegroundColor Red; exit 1 }
Write-Host 'modio-compile-check: OK' -ForegroundColor Green
exit 0
