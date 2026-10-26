<#
.SYNOPSIS
  Offline compile check: compiles the mod against the vanilla game script bundle, no game launch.

.DESCRIPTION
  Runs redscript-cli compile on src/redscript/PreemWeaponsmith plus every framework script the
  game would load (all .reds under <game>\red4ext\plugins: Codeware, TweakXL, ArchiveXL,
  Mod Settings), on top of the vanilla r6\cache\final.redscripts. The compiled bundle goes to a
  temp file and is thrown away; the game folder is never written.

  redscript-cli exits 0 even when the build fails, so the result is read from its output.
  Prints the errors and a count of warnings (ours vs framework). Also warns (no failure) about
  our own files (-Src, -Extra) that declare an exec func and have a module line: CET can't
  find a module-qualified exec function (rules in tools/SourceLint.psm1). The full output is saved to
  logs\compile-check.log. Exit code 0 = compiles, 1 = compile errors or bad setup.

.EXAMPLE
  pwsh tools/compile-check.ps1
  pwsh tools/compile-check.ps1 -WithEnhancedCraft
  pwsh tools/compile-check.ps1 -Extra dev/redscript/PreemDev
#>
[CmdletBinding()]
param(
  # Game folder; defaults to the REDCLI_GAME environment variable (same one red-cli uses).
  [string]$GamePath = $env:REDCLI_GAME,
  # Vanilla bundle to compile against. Default: <game>\r6\cache\final.redscripts.bk if present
  # (older redscript versions keep the vanilla copy there), else final.redscripts.
  [string]$Bundle,
  # Mod source folder.
  [string]$Src = (Join-Path $PSScriptRoot '..\src\redscript\PreemWeaponsmith'),
  # More source files or folders to compile with the mod (dev code, a scratch file).
  [string[]]$Extra = @(),
  # Also compile the staged EnhancedCraft scripts, so the @if(ModuleExists) branches are checked.
  [switch]$WithEnhancedCraft,
  [string]$EnhancedCraftPath = (Join-Path $PSScriptRoot '..\..\downloads\2026-10-25_EnhancedCraft\r6\scripts\EnhancedCraft'),
  [string]$LogFile = (Join-Path $PSScriptRoot '..\logs\compile-check.log')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Fail([string]$msg) { Write-Host "compile-check: $msg" -ForegroundColor Red; exit 1 }

if (-not $GamePath) { Fail 'no game folder: set REDCLI_GAME or pass -GamePath' }
if (-not (Test-Path -LiteralPath $GamePath)) { Fail "game folder not found: $GamePath" }
$cli = Get-Command redscript-cli -ErrorAction SilentlyContinue
if (-not $cli) { Fail 'redscript-cli not on PATH' }

if (-not $Bundle) {
  $cache = Join-Path $GamePath 'r6\cache'
  $Bundle = Join-Path $cache 'final.redscripts.bk'
  if (-not (Test-Path -LiteralPath $Bundle)) { $Bundle = Join-Path $cache 'final.redscripts' }
}
if (-not (Test-Path -LiteralPath $Bundle)) { Fail "bundle not found: $Bundle" }

$sources = @((Resolve-Path -LiteralPath $Src).Path)
$frameworks = @(Get-ChildItem -LiteralPath (Join-Path $GamePath 'red4ext\plugins') -Recurse -Filter *.reds -File |
  ForEach-Object FullName)
if ($frameworks.Count -eq 0) { Fail 'no framework scripts under red4ext\plugins (run tools/install-deps.ps1)' }
$sources += $frameworks
if ($WithEnhancedCraft) {
  if (-not (Test-Path -LiteralPath $EnhancedCraftPath)) { Fail "EnhancedCraft scripts not found: $EnhancedCraftPath" }
  $sources += (Resolve-Path -LiteralPath $EnhancedCraftPath).Path
}
foreach ($e in $Extra) {
  if (-not (Test-Path -LiteralPath $e)) { Fail "extra source not found: $e" }
  $sources += (Resolve-Path -LiteralPath $e).Path
}

# Our own files only (not framework scripts): exec functions inside a module.
Import-Module (Join-Path $PSScriptRoot 'SourceLint.psm1') -Force
$ownSources = @((Resolve-Path -LiteralPath $Src).Path) + @($Extra | ForEach-Object { (Resolve-Path -LiteralPath $_).Path })
$execInModule = @($ownSources | ForEach-Object { Get-ChildItem -LiteralPath $_ -Recurse -Filter *.reds -File } |
  Where-Object { Test-ExecInModule -Text (Get-Content -LiteralPath $_.FullName -Raw) } | ForEach-Object FullName)

$out = Join-Path ([IO.Path]::GetTempPath()) "preem-compile-check-$PID.redscripts"
$cliArgs = @('compile')
foreach ($s in $sources) { $cliArgs += @('-s', $s) }
$cliArgs += @('-b', $Bundle, '-o', $out)

Write-Host "compile-check: bundle $Bundle"
Write-Host "compile-check: $($frameworks.Count) framework scripts$(if ($WithEnhancedCraft) { ' + EnhancedCraft' })$(if ($Extra) { " + $($Extra -join ', ')" })"
$lines = @(& $cli.Source @cliArgs 2>&1 | ForEach-Object { "$_" })
Remove-Item -LiteralPath $out -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Force (Split-Path $LogFile) | Out-Null
$lines | Set-Content -LiteralPath $LogFile -Encoding utf8

# Diagnostics start with "LEVEL [redscript_compiler::diagnostics] [CODE] At <file>:<line>:<col>:"
# (the code is optional), followed by the source line, a caret line and the message, up to the
# next blank line.
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$diags = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
  $m = [regex]::Match($lines[$i], '^(ERROR|WARN) \[redscript_compiler::diagnostics\] (?:\[(\w+)\] )?At (.+?):(\d+):(\d+):')
  if (-not $m.Success) { continue }
  $body = @()
  for ($j = $i + 1; $j -lt $lines.Count -and $lines[$j].Trim() -ne ''; $j++) { $body += $lines[$j] }
  $diags += [pscustomobject]@{
    Level   = $m.Groups[1].Value
    Code    = $m.Groups[2].Value
    File    = $m.Groups[3].Value
    Line    = [int]$m.Groups[4].Value
    Ours    = $m.Groups[3].Value.Replace('/', '\').StartsWith($repoRoot, 'OrdinalIgnoreCase')
    Message = if ($body.Count) { $body[-1].Trim() } else { '' }
  }
}
$errors = @($diags | Where-Object Level -eq 'ERROR')
$warns = @($diags | Where-Object Level -eq 'WARN')
$failed = ($errors.Count -gt 0) -or ($lines -match 'Build failed').Count -gt 0
# Errors redscript reports outside the diagnostics format (bad paths, unreadable bundle).
$other = @($lines | Where-Object { $_ -match '^ERROR ' -and $_ -notmatch 'diagnostics\]|Build failed' })

foreach ($d in $errors) {
  Write-Host "ERROR $(if ($d.Code) { "[$($d.Code)] " })$($d.File):$($d.Line): $($d.Message)" -ForegroundColor Red
}
foreach ($o in $other) { Write-Host $o -ForegroundColor Red }
foreach ($f in $execInModule) {
  Write-Host "WARN exec func in a file with a module line (CET can't call it; move it to a file without one): $f" -ForegroundColor Yellow
}
Write-Host ("compile-check: {0} errors, {1} warnings ({2} in this repo, {3} elsewhere). Full output: {4}" -f
  $errors.Count, $warns.Count, @($warns | Where-Object Ours).Count, @($warns | Where-Object { -not $_.Ours }).Count,
  (Resolve-Path -LiteralPath $LogFile).Path)

if ($failed -or $other.Count) { Write-Host 'compile-check: FAILED' -ForegroundColor Red; exit 1 }
Write-Host 'compile-check: OK' -ForegroundColor Green
exit 0
