# Pester 3.4. Lines follow RedTest's FTLog output (dev/redscript/RedTest) as CET's gamelog.log
# writes it: "[<stamp>] [<thread>] <text>". Expected counts are worked out by hand.
Import-Module (Join-Path $PSScriptRoot '..\RedTestLog.psm1') -Force

Describe 'Get-RedTestResult' {
  It 'returns nothing when RedTest did not run' {
    Get-RedTestResult -Lines @('[2026-10-25 16:10:30 UTC-07:00] [1] [PreemDev] pong') | Should BeNullOrEmpty
  }

  It 'reads the summary and the failed test names' {
    $log = @(
      '[2026-10-25 16:10:30 UTC-07:00] [1] == PreemWeaponsmith - All Tests =='
      '[2026-10-25 16:10:30 UTC-07:00] [1] == PreemWeaponsmith - Test - Smoke =='
      '[2026-10-25 16:10:30 UTC-07:00] [1] PASS: 2 + 2 == 4'
      '[2026-10-25 16:10:30 UTC-07:00] [1] [ERROR] FAIL: slot rule'
      '[2026-10-25 16:10:30 UTC-07:00] [1] [ERROR]   Actual: false'
      '[2026-10-25 16:10:30 UTC-07:00] [1] [ERROR]   Expected: true'
      '[2026-10-25 16:10:30 UTC-07:00] [1] Tests: 1 failed, 1 passed, 2 total'
    )
    $r = Get-RedTestResult -Lines $log
    $r.Failed | Should Be 1
    $r.Passed | Should Be 1
    $r.Total | Should Be 2
    @($r.Failures).Count | Should Be 1
    $r.Failures[0] | Should Be 'slot rule'
  }

  It 'ignores an empty summary from a later session (a loaded save re-runs RedTest with no tests)' {
    $log = @(
      '[x] [1] Tests: 0 failed, 47 passed, 47 total'
      '[x] [1] Tests: 0 failed, 0 passed, 0 total'
    )
    $r = Get-RedTestResult -Lines $log
    $r.Passed | Should Be 47
    $r.Total | Should Be 47
  }

  It 'uses the last summary when tests ran twice' {
    $log = @(
      '[x] [1] Tests: 3 failed, 0 passed, 3 total'
      '[x] [1] Tests: 0 failed, 3 passed, 3 total'
    )
    (Get-RedTestResult -Lines $log).Failed | Should Be 0
    (Get-RedTestResult -Lines $log).Passed | Should Be 3
  }
}
