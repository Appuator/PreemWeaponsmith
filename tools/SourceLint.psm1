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

Export-ModuleMember -Function Test-ExecInModule
