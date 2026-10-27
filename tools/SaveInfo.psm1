# Which save boot-check -LoadSave loads: the newest one in the game's save folder.
# Tests: tools/tests/SaveInfo.Tests.ps1.

<#
  The save the main menu's Continue loads: of the folders in $SaveDir that hold a sav.dat, the
  one whose sav.dat was written last. Returns Name and Time from its metadata.*.json ("name",
  "timestampString", e.g. "20:32:04, 26.10.2026"), falling back to the folder name and the file
  time in the same format; nothing when there is no save.
#>
function Get-NewestSave {
  param([string]$SaveDir)
  $newest = @(Get-ChildItem -LiteralPath $SaveDir -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { Get-Item -LiteralPath (Join-Path $_.FullName 'sav.dat') -ErrorAction SilentlyContinue } |
    Sort-Object LastWriteTime -Descending) | Select-Object -First 1
  if (-not $newest) { return }
  $name = $newest.Directory.Name
  $time = $newest.LastWriteTime.ToString('HH:mm:ss, dd.MM.yyyy', [cultureinfo]::InvariantCulture)
  $meta = Get-ChildItem -LiteralPath $newest.DirectoryName -Filter 'metadata.*.json' -File | Select-Object -First 1
  if ($meta) {
    try {
      $m = (Get-Content -LiteralPath $meta.FullName -Raw | ConvertFrom-Json).Data.metadata
      if ($m.name) { $name = $m.name }
      if ($m.timestampString) { $time = $m.timestampString }
    } catch { }
  }
  [pscustomobject]@{ Name = $name; Time = $time; Folder = $newest.DirectoryName }
}

Export-ModuleMember -Function Get-NewestSave
