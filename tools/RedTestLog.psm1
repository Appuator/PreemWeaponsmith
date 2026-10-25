# Reads RedTest results out of CET's gamelog.log lines (RedTest writes with FTLog).
# Pure; tools/boot-check.ps1 passes this run's lines. Tests: tools/tests/RedTestLog.Tests.ps1.

# $null when no "Tests: X failed, Y passed, Z total" line (RedTest not installed or never ran),
# else Failed/Passed/Total from the last summary and the names of failed checks ("FAIL: <name>").
function Get-RedTestResult {
  param([string[]]$Lines)
  $summary = @($Lines | Select-String -Pattern 'Tests: (\d+) failed, (\d+) passed, (\d+) total') | Select-Object -Last 1
  if (-not $summary) { return $null }
  $g = $summary.Matches[0].Groups
  [pscustomobject]@{
    Failed   = [int]$g[1].Value
    Passed   = [int]$g[2].Value
    Total    = [int]$g[3].Value
    Failures = @($Lines | Select-String -Pattern 'FAIL: (.+)$' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() })
  }
}

Export-ModuleMember -Function Get-RedTestResult
