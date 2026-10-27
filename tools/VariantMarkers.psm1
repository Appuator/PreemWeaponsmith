# Vanilla-marker comparison of evolution variants (<base>_Preem<Evolution> weapon records) against
# the vanilla weapons of their old and new evolution, read from dev/cet/weapon-dump.lua's dump. Pure;
# tools/variant-markers.ps1 runs it. Tests: tools/tests/VariantMarkers.Tests.ps1.

$script:variantPattern = [regex]'^(.+)_Preem(Smart|Tech|Power)$'
# One list element: quoted strings, {...} and (...) groups (vectors, LocKeys) or plain characters.
$script:elementPattern = [regex]'(?:"(?:[^"\\]|\\.)*"|\{[^}]*\}|\([^)]*\)|[^",{}()\[\]\s])(?:"(?:[^"\\]|\\.)*"|\{[^}]*\}|\([^)]*\)|[^",{}()\[\]])*'

# Dump lines ("<record>.<flat> = <value>"; "--" lines skipped) to record -> flat -> raw value.
function ConvertFrom-FlatDump {
  param($Lines)
  $records = [Collections.Generic.Dictionary[string, Collections.Generic.Dictionary[string, string]]]::new([StringComparer]::Ordinal)
  foreach ($line in $Lines) {
    if ($line.StartsWith('--')) { continue }
    $eq = $line.IndexOf(' = ')
    if ($eq -lt 0) { continue }
    $dot = $line.LastIndexOf('.', $eq)
    $name = $line.Substring(0, $dot)
    $flats = $null
    if (-not $records.TryGetValue($name, [ref]$flats)) {
      $flats = [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::Ordinal)
      $records[$name] = $flats
    }
    $flats[$line.Substring($dot + 1, $eq - $dot - 1)] = $line.Substring($eq + 3)
  }
  return , $records
}

# A flat value as its elements: a "[a, b]" list split at top-level commas, a scalar as itself.
function Split-FlatValue {
  param([string]$Value)
  if (-not ($Value.StartsWith('[') -and $Value.EndsWith(']'))) { return $Value }
  return @($script:elementPattern.Matches($Value.Substring(1, $Value.Length - 2)) | ForEach-Object { $_.Value.Trim() })
}

# For every vanilla weapon evolution: how many weapons it has, and per flat how many of them carry
# each element. Vanilla = every record with an evolution flat that is not a variant.
function Get-EvolutionCounts($Records) {
  $evos = @{}
  foreach ($name in $Records.Keys) {
    if ($script:variantPattern.IsMatch($name)) { continue }
    $flats = $Records[$name]
    $evo = $null
    if (-not $flats.TryGetValue('evolution', [ref]$evo)) { continue }
    if (-not $evos.ContainsKey($evo)) { $evos[$evo] = @{ Total = 0; Flats = @{} } }
    $e = $evos[$evo]
    $e.Total++
    foreach ($flat in $flats.Keys) {
      if (-not $e.Flats.ContainsKey($flat)) { $e.Flats[$flat] = [Collections.Generic.Dictionary[string, int]]::new([StringComparer]::Ordinal) }
      $c = $e.Flats[$flat]
      foreach ($el in [Collections.Generic.HashSet[string]]::new([string[]]@(Split-FlatValue $flats[$flat]), [StringComparer]::Ordinal)) {
        $n = 0; [void]$c.TryGetValue($el, [ref]$n); $c[$el] = $n + 1
      }
    }
  }
  return $evos
}

# One row per marker difference, sorted by record, flat, kind, value:
#   keeps-old: the variant's flat holds an element that at least KeepShare of its old evolution's
#              vanilla weapons carry and none of its new evolution's;
#   lacks-new: the variant's list flat lacks an element at least LackShare of its new evolution's
#              carry. Lists only: a scalar that differs from the new evolution's usual value is the
#              base's own property (IK, hit reaction), and an old-evolution scalar is already keeps-old.
# Old evolution = the base record's; new = the variant's suffix. A variant without its base is skipped.
# VariantLike limits which variants are reported (wildcard); every non-variant weapon stays vanilla.
function Get-VariantMarkerReport {
  param($Records, [double]$KeepShare = 0.5, [double]$LackShare = 0.9, [string]$VariantLike = '*')
  $evos = Get-EvolutionCounts $Records
  $names = [string[]]@($Records.Keys | Where-Object { $_ -like $VariantLike -and $script:variantPattern.IsMatch($_) })
  [Array]::Sort($names, [StringComparer]::Ordinal)
  foreach ($name in $names) {
    $m = $script:variantPattern.Match($name)
    $base = $null
    if (-not $Records.TryGetValue($m.Groups[1].Value, [ref]$base)) { continue }
    $oldEvo = $null
    if (-not $base.TryGetValue('evolution', [ref]$oldEvo)) { continue }
    $newEvo = 't"WeaponEvolution.' + $m.Groups[2].Value + '"'
    if ($oldEvo -eq $newEvo -or -not $evos.ContainsKey($oldEvo) -or -not $evos.ContainsKey($newEvo)) { continue }
    $old = $evos[$oldEvo]; $new = $evos[$newEvo]
    $flats = $Records[$name]
    $flatNames = [string[]]@($flats.Keys)
    [Array]::Sort($flatNames, [StringComparer]::Ordinal)
    foreach ($flat in $flatNames) {
      $have = [Collections.Generic.HashSet[string]]::new([string[]]@(Split-FlatValue $flats[$flat]), [StringComparer]::Ordinal)
      $oldC = $old.Flats[$flat]; $newC = $new.Flats[$flat]
      $keeps = [Collections.Generic.List[string]]::new()
      foreach ($el in $have) {
        $o = 0; $n = 0
        if ($oldC) { [void]$oldC.TryGetValue($el, [ref]$o) }
        if ($newC) { [void]$newC.TryGetValue($el, [ref]$n) }
        if ($n -eq 0 -and $o -ge $KeepShare * $old.Total) { $keeps.Add($el) }
      }
      $lacks = [Collections.Generic.List[string]]::new()
      if ($newC -and $flats[$flat].StartsWith('[')) {
        foreach ($kv in $newC.GetEnumerator()) {
          if ($kv.Value -ge $LackShare * $new.Total -and -not $have.Contains($kv.Key)) { $lacks.Add($kv.Key) }
        }
      }
      foreach ($pair in @(@('keeps-old', $keeps), @('lacks-new', $lacks))) {
        $vals = $pair[1].ToArray()
        [Array]::Sort($vals, [StringComparer]::Ordinal)
        foreach ($v in $vals) { [pscustomobject]@{ Record = $name; Flat = $flat; Kind = $pair[0]; Value = $v } }
      }
    }
  }
}

Export-ModuleMember -Function ConvertFrom-FlatDump, Split-FlatValue, Get-VariantMarkerReport
