# Pester 3.4. Source texts are small hand-written .reds snippets; expected results worked out by hand.
Import-Module (Join-Path $PSScriptRoot '..\SourceLint.psm1') -Force

Describe 'Test-ExecInModule' {
  It 'flags an exec func in a file with a module line' {
    $src = "module PreemDev`n`npublic static exec func PreemPing(gi: GameInstance) -> Void {`n  Print(`"pong`");`n}`n"
    Test-ExecInModule -Text $src | Should Be $true
  }

  It 'passes an exec func in a file without a module line' {
    $src = "// An exec function; no ``module`` line here.`npublic static exec func PreemPing(gi: GameInstance) -> Void {}`n"
    Test-ExecInModule -Text $src | Should Be $false
  }

  It 'passes a module file without exec functions' {
    $src = "module PreemDev`n`npublic class PreemDevSystem extends ScriptableSystem {}`n"
    Test-ExecInModule -Text $src | Should Be $false
  }

  It 'ignores a commented-out exec func or module line' {
    $src = "// module PreemDev`n/* module Old`npublic static exec func Old(gi: GameInstance) {} */`npublic static exec func PreemPing(gi: GameInstance) {}`n"
    Test-ExecInModule -Text $src | Should Be $false
    Test-ExecInModule -Text "module PreemDev`n// public static exec func Old(gi: GameInstance) {}`n" | Should Be $false
  }
}
