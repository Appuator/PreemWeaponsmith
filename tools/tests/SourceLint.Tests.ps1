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

Describe 'Find-ControlChar' {
  It 'finds nothing in plain text with LF or CRLF line ends' {
    @(Find-ControlChar -Text "# Title`n`nSome text.`r`nMore text.`n").Count | Should Be 0
  }

  It 'reports a tab with its line and column' {
    $hits = @(Find-ControlChar -Text "line one`nbin`tx64`n")
    $hits.Count | Should Be 1
    $hits[0].Line | Should Be 2
    $hits[0].Column | Should Be 4
    $hits[0].Code | Should Be 'U+0009'
  }

  It 'reports a lone CR, a backspace and DEL but not CRLF' {
    $hits = @(Find-ControlChar -Text "a`rb`r`nc$([char]8)d$([char]0x7f)`n")
    $hits.Count | Should Be 3
    ($hits | ForEach-Object Code) -join ',' | Should Be 'U+000D,U+0008,U+007F'
    ($hits | ForEach-Object Line) -join ',' | Should Be '1,2,2'
  }

  It 'with -AllowTab skips tabs but still reports other control characters' {
    $hits = @(Find-ControlChar -AllowTab -Text "`tlet x = 1;`n`tlet y$([char]8) = 2;`n")
    $hits.Count | Should Be 1
    $hits[0].Line | Should Be 2
    $hits[0].Code | Should Be 'U+0008'
  }
}

Describe 'Get-ControlCharMode' {
  It 'checks Markdown, PowerShell and Lua strictly (tabs count)' {
    Get-ControlCharMode -Path 'HANDOFF.md' | Should Be 'Strict'
    Get-ControlCharMode -Path 'tools/boot-check.ps1' | Should Be 'Strict'
    Get-ControlCharMode -Path 'tools\SourceLint.psm1' | Should Be 'Strict'
    Get-ControlCharMode -Path 'dev/cet/craft-e2e.lua' | Should Be 'Strict'
  }

  It 'checks plain text strictly (the Nexus page text has Windows paths with backslashes)' {
    Get-ControlCharMode -Path 'docs/nexus-description.txt' | Should Be 'Strict'
    Get-ControlCharMode -Path 'dev/baseline/tweak-dump.TXT' | Should Be 'Strict'
  }

  It 'allows tabs in redscript (existing files indent with them)' {
    Get-ControlCharMode -Path 'src/redscript/PreemWeaponsmith/Tweaking/PreemWeaponAlteration.reds' | Should Be 'AllowTab'
  }

  It 'skips other file types' {
    Get-ControlCharMode -Path 'archive/PreemWeaponsmith.archive' | Should BeNullOrEmpty
    Get-ControlCharMode -Path 'red.config.json' | Should BeNullOrEmpty
    Get-ControlCharMode -Path 'tools/hooks/pre-commit' | Should BeNullOrEmpty
  }
}
