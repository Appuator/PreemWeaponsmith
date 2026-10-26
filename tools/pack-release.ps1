<#
.SYNOPSIS
  Builds the release zip: dist\PreemWeaponsmith-<version>.zip, laid out like the 2.2.5 release.

.DESCRIPTION
  The zip holds the source tree as it is, so players extract it into the game folder:
    r6/scripts/PreemWeaponsmith/**   every .reds file under src/redscript/PreemWeaponsmith, plus License
    archive/pc/mod/PreemWeaponsmith.archive   the sound archive (until Phase 3 moves sounds to Audioware);
                                              -NoArchive leaves it out. On patch 2.5 it replaces the
                                              whole cooked_metadata.audio_metadata with a 2.12-era copy
                                              (Phase 1 release-candidate note), so check before shipping it.
  The version comes from red.config.json. Dev code (dev/) is never included.

  Why not `red-cli pack`: red-cli 0.5.1 bundles one file per module and, with this source tree,
  wrote only the module headers and the files without a module line (no hooks at all; Phase 1
  release-candidate task, 2026-10-25).

  Exit code 0 = zip written, 1 = missing input.

.EXAMPLE
  pwsh tools/pack-release.ps1
#>
[CmdletBinding()]
param(
  [string]$Root = (Join-Path $PSScriptRoot '..'),
  [string]$OutDir = (Join-Path $PSScriptRoot '..\dist'),
  [switch]$NoArchive
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

function Fail([string]$msg) { Write-Host "pack-release: $msg" -ForegroundColor Red; exit 1 }

$Root = (Resolve-Path -LiteralPath $Root).Path
$version = (Get-Content -Raw -LiteralPath (Join-Path $Root 'red.config.json') | ConvertFrom-Json).version
if (-not $version) { Fail 'no version in red.config.json' }
$src = Join-Path $Root 'src\redscript\PreemWeaponsmith'
$archive = Join-Path $Root 'archive\PreemWeaponsmith.archive'
foreach ($p in $src, (Join-Path $src 'License')) { if (-not (Test-Path -LiteralPath $p)) { Fail "missing $p" } }

# Zip path -> file on disk.
$entries = [ordered]@{}
foreach ($f in Get-ChildItem -LiteralPath $src -Recurse -File | Where-Object { $_.Extension -eq '.reds' -or $_.Name -eq 'License' } | Sort-Object FullName) {
  $entries['r6/scripts/PreemWeaponsmith/' + $f.FullName.Substring($src.Length + 1).Replace('\', '/')] = $f.FullName
}
if (-not $NoArchive) {
  if (-not (Test-Path -LiteralPath $archive)) { Fail "missing $archive" }
  $entries['archive/pc/mod/PreemWeaponsmith.archive'] = $archive
}

New-Item -ItemType Directory -Force $OutDir | Out-Null
$zipPath = Join-Path (Resolve-Path -LiteralPath $OutDir).Path "PreemWeaponsmith-$version$(if ($NoArchive) { '-noarchive' }).zip"
Remove-Item -LiteralPath $zipPath -ErrorAction SilentlyContinue
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
try {
  foreach ($name in $entries.Keys) {
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $entries[$name], $name, 'Optimal') | Out-Null
  }
} finally { $zip.Dispose() }

$reds = @($entries.Keys | Where-Object { $_ -like '*.reds' }).Count
Write-Host "pack-release: $zipPath ($($entries.Count) files: $reds .reds, License$(if (-not $NoArchive) { ', archive' }))"
exit 0
