# Copies a staged mod (a folder laid out like the game folder, e.g. downloads/2026-10-25_EnhancedCraft)
# into the game for one run and removes exactly what it copied afterwards. Used by
# tools/boot-check.ps1 -WithEnhancedCraft. Tests: tools/tests/StagedMod.Tests.ps1.

# Copies every file under StageRoot to the same relative path under GamePath. Throws, copying
# nothing, when any of them is already in the game (a user install, or a run that was killed before
# its cleanup), since removing it afterwards would delete a file this run didn't put there.
# Returns Files (copied paths) and Dirs (folders the copy created, deepest first) for Remove-StagedMod.
function Copy-StagedMod {
  param([string]$StageRoot, [string]$GamePath)
  $root = (Get-Item -LiteralPath $StageRoot).FullName.TrimEnd('\')
  $rels = @(Get-ChildItem -LiteralPath $root -Recurse -File | ForEach-Object { $_.FullName.Substring($root.Length + 1) })
  $present = @($rels | Where-Object { Test-Path -LiteralPath (Join-Path $GamePath $_) })
  if ($present) { throw "already in the game: $($present -join ', ')" }

  $copied = [pscustomobject]@{ Files = [Collections.Generic.List[string]]::new(); Dirs = [Collections.Generic.List[string]]::new() }
  try {
    foreach ($rel in $rels) {
      $target = Join-Path $GamePath $rel
      # Record each missing folder on the way down, so cleanup knows which ones the copy made.
      $missing = @()
      for ($d = Split-Path $target; -not (Test-Path -LiteralPath $d); $d = Split-Path $d) { $missing += $d }
      foreach ($d in ($missing | Sort-Object Length)) {
        New-Item -ItemType Directory $d | Out-Null
        $copied.Dirs.Add($d)
      }
      Copy-Item -LiteralPath (Join-Path $root $rel) -Destination $target
      $copied.Files.Add($target)
    }
  } catch {
    Remove-StagedMod -Copied $copied | Out-Null
    throw
  }
  $copied.Dirs = [Collections.Generic.List[string]]@($copied.Dirs | Sort-Object Length -Descending)
  return $copied
}

# Removes the files Copy-StagedMod copied (a file already gone is fine), then each folder it created
# if that folder is now empty. Returns the copied files still present (e.g. locked by a game that is
# still exiting); empty when cleanup is complete.
function Remove-StagedMod {
  param($Copied)
  foreach ($f in $Copied.Files) { Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue }
  foreach ($d in ($Copied.Dirs | Sort-Object Length -Descending)) {
    if ((Test-Path -LiteralPath $d) -and -not (Get-ChildItem -LiteralPath $d -Force)) { Remove-Item -LiteralPath $d -Force }
  }
  return @($Copied.Files | Where-Object { Test-Path -LiteralPath $_ })
}

Export-ModuleMember -Function Copy-StagedMod, Remove-StagedMod
