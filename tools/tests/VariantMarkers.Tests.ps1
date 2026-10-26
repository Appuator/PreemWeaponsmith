# Pester 3.4. Lines follow dev/cet/weapon-dump.lua's output ("<record>.<flat> = <value>", lists as
# "[a, b]", an "-- end: ..." last line). Expected rows are worked out by hand from the small dump below.
Import-Module (Join-Path $PSScriptRoot '..\VariantMarkers.psm1') -Force

Describe 'Split-FlatValue' {
  It 'splits a list at its top-level commas, not inside quotes' {
    $parts = @(Split-FlatValue '[n"Weapon", "a, b", t"Price.SmartWeapon"]')
    $parts.Count | Should Be 3
    $parts[1] | Should Be '"a, b"'
    $parts[2] | Should Be 't"Price.SmartWeapon"'
  }

  It 'gives no elements for an empty list and one for a scalar' {
    @(Split-FlatValue '[]').Count | Should Be 0
    @(Split-FlatValue 't"TriggerMode.FullAuto"') -join '|' | Should Be 't"TriggerMode.FullAuto"'
  }
}

Describe 'Get-VariantMarkerReport' {
  # Power: P1, P2 and the base B; Smart: S1, S2. B_PreemSmart is B's Smart variant with only its
  # evolution changed. Q_PreemSmart has no base in the dump and is skipped.
  $dump = @(
    'Items.P1.evolution = t"WeaponEvolution.Power"'
    'Items.P1.tags = [n"Weapon", n"Power"]'
    'Items.P1.primaryTriggerMode = t"TriggerMode.FullAuto"'
    'Items.P1.OnAttach = []'
    'Items.P1.slotPartList = []'
    'Items.P2.evolution = t"WeaponEvolution.Power"'
    'Items.P2.tags = [n"Weapon", n"Power"]'
    'Items.P2.primaryTriggerMode = t"TriggerMode.SemiAuto"'
    'Items.P2.OnAttach = []'
    'Items.P2.slotPartList = []'
    'Items.B.evolution = t"WeaponEvolution.Power"'
    'Items.B.tags = [n"Weapon", n"Power"]'
    'Items.B.primaryTriggerMode = t"TriggerMode.FullAuto"'
    'Items.B.OnAttach = [t"Items.Rare"]'
    'Items.B.slotPartList = []'
    'Items.S1.evolution = t"WeaponEvolution.Smart"'
    'Items.S1.tags = [n"Weapon", n"Smart"]'
    'Items.S1.primaryTriggerMode = t"TriggerMode.SemiAuto"'
    'Items.S1.OnAttach = []'
    'Items.S1.slotPartList = [t"Items.SmartScopes"]'
    'Items.S2.evolution = t"WeaponEvolution.Smart"'
    'Items.S2.tags = [n"Weapon", n"Smart"]'
    'Items.S2.primaryTriggerMode = t"TriggerMode.SemiAuto"'
    'Items.S2.OnAttach = []'
    'Items.S2.slotPartList = [t"Items.SmartScopes"]'
    'Items.B_PreemSmart.evolution = t"WeaponEvolution.Smart"'
    'Items.B_PreemSmart.tags = [n"Weapon", n"Power"]'
    'Items.B_PreemSmart.primaryTriggerMode = t"TriggerMode.FullAuto"'
    'Items.B_PreemSmart.OnAttach = [t"Items.Rare"]'
    'Items.B_PreemSmart.slotPartList = []'
    'Items.Q_PreemSmart.evolution = t"WeaponEvolution.Smart"'
    'Items.Q_PreemSmart.tags = [n"Power"]'
    '-- end: 7 records, 31 flats'
  )

  It 'flags old-evolution values the variant keeps and new-evolution values it lacks' {
    $rows = @(Get-VariantMarkerReport -Records (ConvertFrom-FlatDump $dump))
    # FullAuto: 2 of 3 Power weapons (>= 1/2), no Smart one. Power tag: 3 of 3 Power, no Smart.
    # Smart tag and SmartScopes: 2 of 2 Smart (>= 9/10). Items.Rare: 1 of 3 Power, not flagged.
    # SemiAuto is on 2 of 2 Smart, but primaryTriggerMode is a scalar: no lacks-new row. n"Weapon" is
    # on both sides, not flagged.
    ($rows | ForEach-Object { "$($_.Record) $($_.Flat) $($_.Kind) $($_.Value)" }) -join '|' | Should Be (@(
      'Items.B_PreemSmart primaryTriggerMode keeps-old t"TriggerMode.FullAuto"'
      'Items.B_PreemSmart slotPartList lacks-new t"Items.SmartScopes"'
      'Items.B_PreemSmart tags keeps-old n"Power"'
      'Items.B_PreemSmart tags lacks-new n"Smart"'
    ) -join '|')
  }

  It 'does not flag a scalar that differs from the new evolution''s usual value unless it is an old-evolution marker' {
    # IsIKEnabled: true on B (1 of 3 Power, < 1/2), false on 2 of 2 Smart. The variant keeps B's own
    # true: a property of the base, not of its evolution, so not flagged as lacking false.
    $withIk = @($dump | Where-Object { $_ -notmatch '^-- ' }) + @(
      'Items.P1.IsIKEnabled = false', 'Items.P2.IsIKEnabled = false', 'Items.B.IsIKEnabled = true'
      'Items.S1.IsIKEnabled = false', 'Items.S2.IsIKEnabled = false', 'Items.B_PreemSmart.IsIKEnabled = true'
    )
    @(Get-VariantMarkerReport -Records (ConvertFrom-FlatDump $withIk) | Where-Object Flat -eq 'IsIKEnabled').Count | Should Be 0
  }

  It 'covers only the variants matching -VariantLike, still counting every vanilla weapon' {
    # B_PreemSmart doesn't match Items.Preset_*; its base B still counts as a vanilla Power weapon.
    $preset = @($dump | Where-Object { $_ -notmatch '^-- ' }) + @(
      'Items.Preset_P1_PreemSmart.evolution = t"WeaponEvolution.Smart"'
      'Items.Preset_P1_PreemSmart.tags = [n"Weapon", n"Smart"]'
      'Items.Preset_P1_PreemSmart.primaryTriggerMode = t"TriggerMode.FullAuto"'
      'Items.Preset_P1.evolution = t"WeaponEvolution.Power"'
      'Items.Preset_P1.tags = [n"Weapon", n"Power"]'
      'Items.Preset_P1.primaryTriggerMode = t"TriggerMode.FullAuto"'
    )
    # FullAuto: 3 of 4 Power (P1, B, Preset_P1), no Smart one.
    $rows = @(Get-VariantMarkerReport -Records (ConvertFrom-FlatDump $preset) -VariantLike 'Items.Preset_*')
    ($rows | ForEach-Object { "$($_.Record) $($_.Flat) $($_.Kind) $($_.Value)" }) -join '|' |
      Should Be 'Items.Preset_P1_PreemSmart primaryTriggerMode keeps-old t"TriggerMode.FullAuto"'
  }

  It 'flags nothing once the variant carries its new evolution''s markers' {
    $fixed = @($dump | ForEach-Object {
      $_ -replace '^(Items\.B_PreemSmart\.tags) = .*', '$1 = [n"Weapon", n"Smart"]' `
         -replace '^(Items\.B_PreemSmart\.primaryTriggerMode) = .*', '$1 = t"TriggerMode.SemiAuto"' `
         -replace '^(Items\.B_PreemSmart\.slotPartList) = .*', '$1 = [t"Items.SmartScopes"]'
    })
    @(Get-VariantMarkerReport -Records (ConvertFrom-FlatDump $fixed)).Count | Should Be 0
  }
}
