# Rules for the boot check's dependency check: which pinned framework loaded, at which version.
# Pure functions over log lines; tools/boot-check.ps1 does the file reading.
# Tests: tools/tests/BootDeps.Tests.ps1.

# Statuses that fail the boot check. 'unverified' only warns; 'ok' and 'disabled' pass.
$script:FailingStatuses = @('not-loaded', 'version-mismatch', 'disabled-but-loaded')

function Get-BootDependencyFailingStatuses { $script:FailingStatuses }

<#
  One row per pin: Name, Pinned, Found, Status.
  A pin's bootLog field says where its load shows up:
    red4ext         "RED4ext (vX) is initializing" in the RED4ext log
    red4ext-plugin  "<name> (version: X, ...) has been loaded" in the RED4ext log
                    (logName overrides the name when the plugin calls itself something else)
    cet             "CET version vX" in this run's part of cyber_engine_tweaks.log
    redscript       "Compilation complete" in redscript_rCURRENT.log. redscript logs no version,
                    so the caller compares scc.exe with the pinned release and passes the result
                    as RedscriptMatchesPin ($true, $false, or $null when it couldn't check).
  Disabled pins are reported 'disabled', or 'disabled-but-loaded' if their load line shows up.
#>
function Get-BootDependencyReport {
  param(
    [object[]]$Pins,
    [string[]]$Red4extLog = @(),
    [string[]]$CetLog = @(),
    [string[]]$RedscriptLog = @(),
    $RedscriptMatchesPin = $null
  )
  foreach ($pin in $Pins) {
    $props = $pin.PSObject.Properties.Name
    $bootLog = if ($props -contains 'bootLog') { $pin.bootLog } else { '' }
    $logName = if ($props -contains 'logName' -and $pin.logName) { $pin.logName } else { $pin.name }
    $pinned = "$($pin.version)".TrimStart('v')
    $found = $null
    $loaded = $false

    switch ($bootLog) {
      'red4ext' {
        $m = @($Red4extLog | Select-String -Pattern 'RED4ext \(v([^)]+)\) is initializing') | Select-Object -Last 1
        if ($m) { $loaded = $true; $found = $m.Matches[0].Groups[1].Value }
      }
      'red4ext-plugin' {
        $pattern = '\] ' + [regex]::Escape($logName) + ' \(version: ([^,)]+)[,)].*has been loaded'
        $m = @($Red4extLog | Select-String -Pattern $pattern) | Select-Object -Last 1
        if ($m) { $loaded = $true; $found = $m.Matches[0].Groups[1].Value.Trim() }
      }
      'cet' {
        $m = @($CetLog | Select-String -Pattern 'CET version v?(\S+)') | Select-Object -Last 1
        if ($m) { $loaded = $true; $found = $m.Matches[0].Groups[1].Value }
      }
      'redscript' {
        $loaded = [bool]($RedscriptLog -match 'Compilation complete')
        if ($loaded -and $RedscriptMatchesPin -eq $true) { $found = $pinned }
        elseif ($loaded -and $RedscriptMatchesPin -eq $false) { $found = 'differs from the pinned release' }
      }
      default { $found = "unknown bootLog '$bootLog'" }
    }
    if ($found) { $found = "$found".TrimStart('v') }

    $status =
      if (-not $pin.enabled) { if ($loaded) { 'disabled-but-loaded' } else { 'disabled' } }
      elseif (-not $loaded) { 'not-loaded' }
      elseif ($bootLog -eq 'redscript' -and $null -eq $RedscriptMatchesPin) { 'unverified' }
      elseif ($bootLog -eq 'redscript' -and $RedscriptMatchesPin -eq $false) { 'version-mismatch' }
      elseif ($found -ne $pinned) { 'version-mismatch' }
      else { 'ok' }

    [pscustomobject]@{ Name = $pin.name; Pinned = $pinned; Found = $found; Status = $status }
  }
}

<#
  The lines of a log written at or after $Since. For logs that every run appends to (CET's).
  Reads the leading "[yyyy-MM-dd HH:mm:ss" stamp (CET and spdlog formats); a line without one
  belongs to the line above it.
#>
function Select-LinesSince {
  param([string[]]$Lines, [datetime]$Since)
  $keep = $false
  foreach ($line in $Lines) {
    $m = [regex]::Match($line, '^\[(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)(\.\d+)?')
    if ($m.Success) {
      $stamp = [datetime]::ParseExact($m.Groups[1].Value, 'yyyy-MM-dd HH:mm:ss', $null)
      if ($m.Groups[2].Success) { $stamp = $stamp.AddSeconds([double]('0' + $m.Groups[2].Value)) }
      $keep = $stamp -ge $Since
    }
    if ($keep) { $line }
  }
}

Export-ModuleMember -Function Get-BootDependencyReport, Get-BootDependencyFailingStatuses, Select-LinesSince
