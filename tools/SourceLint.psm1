# Source checks on .reds text that the compiler doesn't make. Pure; tools/compile-check.ps1 reads
# the files. Tests: tools/tests/SourceLint.Tests.ps1.

# Comments removed (/* */ blocks, then // to end of line), so commented-out code doesn't count.
# Naive about "//" inside string literals; good enough for module and exec lines.
function Remove-RedsComments {
  param([string]$Text)
  $noBlocks = [regex]::Replace($Text, '/\*.*?\*/', '', 'Singleline')
  [regex]::Replace($noBlocks, '//[^\r\n]*', '')
}

# True when the file declares an exec function and has a module line. CET finds exec functions
# only by their bare global name, and a module qualifies it (PreemDev.PreemPing), so CET can't
# call it (HANDOFF §2, Dev module task).
function Test-ExecInModule {
  param([string]$Text)
  $code = Remove-RedsComments -Text $Text
  ($code -match '(?m)^\s*module\s+[\w.]+') -and ($code -match '\bexec\s+func\b')
}

# Control characters in text meant to be plain (Markdown docs): every C0 character and DEL,
# except LF and the CR of a CRLF. One row per character with its line, column (both 1-based) and
# code. Tabs count: escape slips while editing docs (a backslash-t written as an escape) produced
# them (Phase 0 gate #6).
function Find-ControlChar {
  param([string]$Text)
  $line = 1; $col = 0
  for ($i = 0; $i -lt $Text.Length; $i++) {
    $c = $Text[$i]
    if ($c -eq "`n") { $line++; $col = 0; continue }
    $col++
    if ($c -eq "`r" -and $i + 1 -lt $Text.Length -and $Text[$i + 1] -eq "`n") { continue }
    if ([int]$c -lt 0x20 -or [int]$c -eq 0x7f) {
      [pscustomobject]@{ Line = $line; Column = $col; Code = 'U+{0:X4}' -f [int]$c }
    }
  }
}

Export-ModuleMember -Function Test-ExecInModule, Find-ControlChar
