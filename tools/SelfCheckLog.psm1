# Reads the PreemDev self-check results out of CET's gamelog.log lines (the self-check writes with
# FTLog). Pure; tools/boot-check.ps1 passes this run's lines. Tests: tools/tests/SelfCheckLog.Tests.ps1.

# $null when there is no "[PreemCheck] done: X passed, Y failed" line (self-check not installed or
# it never finished), else Passed from that summary, the "FAIL <check>: <reason>" texts, and Failed
# as the larger of the summary's count and the FAIL lines seen, so a miscounted summary can't hide one.
function Get-SelfCheckResult {
  param([string[]]$Lines)
  $done = @($Lines | Select-String -Pattern '\[PreemCheck\] done: (\d+) passed, (\d+) failed') | Select-Object -Last 1
  if (-not $done) { return $null }
  $g = $done.Matches[0].Groups
  $failures = @($Lines | Select-String -Pattern '\[PreemCheck\] FAIL (.+)$' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() })
  [pscustomobject]@{
    Passed   = [int]$g[1].Value
    Failed   = [Math]::Max([int]$g[2].Value, $failures.Count)
    Failures = $failures
  }
}

Export-ModuleMember -Function Get-SelfCheckResult
