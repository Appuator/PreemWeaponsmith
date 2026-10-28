# Reads the output of CDPR's official script compiler (<game>\tools\redmod\bin\scc.exe) run with
# -logjson, for tools/modio-compile-check.ps1. One JSON object per line: severity 2 is an error,
# 1 a warning, 0 progress text; file and line are present on diagnostics only. The plain-text log
# interleaves lines from its compile threads, and -threads 1 stops at the first file that fails to
# parse, so the JSON log is the only one that can be read reliably (notes/modio-port.md).
# Tests: tools/tests/ModioCompile.Tests.ps1.

# Diagnostics (Level, File, Line, Message), Other (lines that aren't JSON, e.g. a crash), and the
# totals from the compiler's own summary line ("- 63 errors, 0 warnings -"). Summary is $false
# when that line is missing: the compiler stopped before finishing.
function Read-SccLog {
  param([string[]]$Lines)
  $diags = @(); $other = @()
  $errors = 0; $warnings = 0; $summary = $false
  # Two threads can write their objects onto one line ('}{"severity"...'): split them first.
  $pieces = @($Lines | ForEach-Object { [regex]::Split("$_", '(?<=\})(?=\{"severity")') })
  foreach ($line in $pieces) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    try { $o = $line | ConvertFrom-Json -ErrorAction Stop } catch { $other += $line; continue }
    $file = if ($o.PSObject.Properties['file']) { [string]$o.file } else { '' }
    if ($file) {
      $diags += [pscustomobject]@{
        Level   = switch ([int]$o.severity) { 2 { 'Error' } 1 { 'Warning' } default { 'Info' } }
        File    = $file
        Line    = if ($o.PSObject.Properties['line']) { [int]$o.line } else { 0 }
        Message = [string]$o.message
      }
      continue
    }
    $m = [regex]::Match([string]$o.message, '- (\d+) errors?, (\d+) warnings? -')
    if ($m.Success) {
      $errors = [int]$m.Groups[1].Value; $warnings = [int]$m.Groups[2].Value; $summary = $true
    }
  }
  [pscustomobject]@{ Diagnostics = $diags; Other = $other; ErrorCount = $errors; WarningCount = $warnings; Summary = $summary }
}

# Errors per file (File, Count), most first, then by file name.
function Group-SccDiagnostic {
  param($Diagnostics)
  @($Diagnostics | Where-Object Level -eq 'Error' | Group-Object File |
    Sort-Object @{ Expression = 'Count'; Descending = $true }, Name |
    ForEach-Object { [pscustomobject]@{ File = $_.Name; Count = $_.Count } })
}

# The manifest (modio/manifest.json) must name every source file under src/redscript/PreemWeaponsmith
# (paths relative to it, forward slashes) with an action: "convert" (goes into the mod.io build) or
# "pc-only" (left out). Missing: source files without an entry; Unknown: entries for files that no
# longer exist; BadAction: entries with another action. Each list is sorted.
$script:manifestActions = @('convert', 'pc-only')

function Compare-ModioManifest {
  param([string[]]$SourceFiles, [hashtable]$Entries)
  [pscustomobject]@{
    Missing   = @($SourceFiles | Where-Object { -not $Entries.ContainsKey($_) } | Sort-Object)
    Unknown   = @($Entries.Keys | Where-Object { $SourceFiles -notcontains $_ } | Sort-Object)
    BadAction = @($Entries.Keys | Where-Object { $script:manifestActions -notcontains $Entries[$_] } | Sort-Object)
  }
}

Export-ModuleMember -Function Read-SccLog, Group-SccDiagnostic, Compare-ModioManifest
