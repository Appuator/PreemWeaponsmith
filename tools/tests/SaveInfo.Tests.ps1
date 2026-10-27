# Pester 3.4 (the copy that ships with Windows): pwsh -c "Invoke-Pester tools/tests"
# Save folders are hand-made in TestDrive, laid out like the game's (sav.dat + metadata.9.json);
# the metadata fields are copied from AutoSave-15 of 2026-10-26.
Import-Module (Join-Path $PSScriptRoot '..\SaveInfo.psm1') -Force

function New-Save([string]$folder, [string]$name, [string]$stamp, [datetime]$written, [switch]$NoMetadata) {
  $dir = Join-Path $TestDrive $folder
  New-Item -ItemType Directory -Force $dir | Out-Null
  $sav = Join-Path $dir 'sav.dat'
  Set-Content -LiteralPath $sav -Value 'x'
  (Get-Item -LiteralPath $sav).LastWriteTime = $written
  if (-not $NoMetadata) {
    $json = '{ "RootType": "saveMetadataContainer", "Data": { "metadata": { "timestampString": "' + $stamp + '", "name": "' + $name + '" } } }'
    Set-Content -LiteralPath (Join-Path $dir 'metadata.9.json') -Value $json
  }
}

Describe 'Get-NewestSave' {
  It 'picks the save whose sav.dat was written last and reads its name and time' {
    New-Save 'AutoSave-15' 'AutoSave-15' '20:32:04, 26.10.2026' ([datetime]'2026-10-26 20:32:04')
    New-Save 'ManualSave-3' 'ManualSave-3' '21:05:10, 26.10.2026' ([datetime]'2026-10-26 21:05:10')
    New-Save 'AutoSave-9' 'AutoSave-9' '19:00:00, 26.10.2026' ([datetime]'2026-10-26 19:00:00')
    # Not a save: the game keeps its settings folders here too.
    New-Item -ItemType Directory -Force (Join-Path $TestDrive 'Settings') | Out-Null
    $s = Get-NewestSave -SaveDir $TestDrive
    $s.Name | Should Be 'ManualSave-3'
    $s.Time | Should Be '21:05:10, 26.10.2026'
  }
  It 'falls back to the folder name and file time when the metadata is missing' {
    New-Save 'AutoSave-20' '' '' ([datetime]'2026-10-27 08:15:00') -NoMetadata
    $s = Get-NewestSave -SaveDir $TestDrive
    $s.Name | Should Be 'AutoSave-20'
    $s.Time | Should Be '08:15:00, 27.10.2026'
  }
  It 'returns nothing when there is no save' {
    $empty = Join-Path $TestDrive 'empty'
    New-Item -ItemType Directory -Force $empty | Out-Null
    Get-NewestSave -SaveDir $empty | Should BeNullOrEmpty
  }
}
