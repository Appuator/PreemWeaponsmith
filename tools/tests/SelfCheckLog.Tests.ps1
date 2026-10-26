# Pester 3.4. Lines follow the PreemDev self-check's FTLog output as CET's gamelog.log writes it:
# "[<stamp>] [<thread>] [PreemCheck] PASS|FAIL <check>[: reason]", ending with a "done" summary.
# Expected counts are worked out by hand.
Import-Module (Join-Path $PSScriptRoot '..\SelfCheckLog.psm1') -Force

Describe 'Get-SelfCheckResult' {
  It 'returns nothing when the self-check did not run' {
    Get-SelfCheckResult -Lines @('[x] [1] [PreemDev] PreemDevSystem attached') | Should BeNullOrEmpty
  }

  It 'reads the summary and the failed checks' {
    $log = @(
      '[2026-10-25 18:00:00 UTC-07:00] [1] [PreemCheck] PASS slot AttachmentSlots.PreemBarrelMod01'
      '[2026-10-25 18:00:00 UTC-07:00] [1] [PreemCheck] FAIL slot AttachmentSlots.PreemTriggerMod02: entitySlotName is PreemTriggerMod01'
      '[2026-10-25 18:00:00 UTC-07:00] [1] [PreemCheck] PASS mod Items.PreemBarrelModSmart'
      '[2026-10-25 18:00:00 UTC-07:00] [1] [PreemCheck] FAIL mod Items.PreemBladeModChemBlade: no stat modifiers'
      '[2026-10-25 18:00:00 UTC-07:00] [1] [PreemCheck] done: 2 passed, 2 failed'
    )
    $r = Get-SelfCheckResult -Lines $log
    $r.Passed | Should Be 2
    $r.Failed | Should Be 2
    @($r.Failures).Count | Should Be 2
    $r.Failures[0] | Should Be 'slot AttachmentSlots.PreemTriggerMod02: entitySlotName is PreemTriggerMod01'
    $r.Failures[1] | Should Be 'mod Items.PreemBladeModChemBlade: no stat modifiers'
  }

  It 'counts a FAIL line even when the summary is missing a failure' {
    # A summary that disagrees with the lines (a check that logged FAIL but wasn't counted) must still fail.
    $log = @(
      '[x] [1] [PreemCheck] FAIL variant Items.Preset_Ajax_Default_PreemSmart: missing'
      '[x] [1] [PreemCheck] done: 5 passed, 0 failed'
    )
    (Get-SelfCheckResult -Lines $log).Failed | Should Be 1
  }
}
