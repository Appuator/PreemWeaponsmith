# Pester 3.4. Log lines are copied from a real `scc.exe -compile ... -logjson` run of the 2.5.0 source
# (2026-10-28); expected results worked out by hand from those lines.
Import-Module (Join-Path $PSScriptRoot '..\ModioCompile.psm1') -Force

$script:realLog = @(
  '{"severity":0,"category":0,"message":"REDscript Compiler v1.2.2"}'
  '{"severity":0,"category":1,"message":"Compilation started with 20 threads"}'
  '{"severity":2,"category":4,"file":"PreemWeaponsmith\\Adapters\\ItemDataAdapter.script","line":1,"message":"syntax error, unexpected TOKEN_IDENT, expecting TOKEN_FUNCTION or TOKEN_OPERATOR or TOKEN_CAST or TOKEN_IMPLICIT, near ''module''"}'
  '{"severity":2,"category":4,"file":"PreemWeaponsmith\\Adapters\\ItemDataAdapter.script","line":2,"message":"Error parsing file"}'
  '{"severity":2,"category":4,"file":"PreemWeaponsmith\\Audio\\PreemSoundSets.script","line":12,"message":"syntax error, unexpected TOKEN_IDENT, expecting TOKEN_FUNCTION or TOKEN_OPERATOR or TOKEN_CAST or TOKEN_IMPLICIT, near ''module''"}'
  '{"severity":0,"category":2,"message":"------------ Failed - 63 errors, 0 warnings ------------"}'
)

Describe 'Read-SccLog' {
  It 'returns one diagnostic per error line, with file, line and message' {
    $r = Read-SccLog -Lines $script:realLog
    @($r.Diagnostics).Count | Should Be 3
    $r.Diagnostics[0].Level | Should Be 'Error'
    $r.Diagnostics[0].File | Should Be 'PreemWeaponsmith\Adapters\ItemDataAdapter.script'
    $r.Diagnostics[0].Line | Should Be 1
    $r.Diagnostics[0].Message | Should Match "near 'module'$"
    $r.Diagnostics[2].Line | Should Be 12
  }

  It 'reads the totals from the summary line' {
    $r = Read-SccLog -Lines $script:realLog
    $r.ErrorCount | Should Be 63
    $r.WarningCount | Should Be 0
    $r.Summary | Should Be $true
  }

  It 'skips the banner and progress lines' {
    $r = Read-SccLog -Lines $script:realLog
    @($r.Diagnostics | Where-Object { -not $_.File }).Count | Should Be 0
    @($r.Other).Count | Should Be 0
  }

  It 'splits two objects that two threads wrote onto one line' {
    $joined = '{"severity":2,"category":4,"file":"PreemWeaponsmith\\Core\\PreemSettings.script","line":1,"message":"syntax error, unexpected TOKEN_IDENT, expecting TOKEN_FUNCTION or TOKEN_OPERATOR or TOKEN_CAST or TOKEN_IMPLICIT, near ''module''"}{"severity":2,"category":4,"file":"PreemWeaponsmith\\Core\\PreemModSettings.script","line":32,"message":"Syntax error near: @"}'
    $r = Read-SccLog -Lines @($joined)
    @($r.Other).Count | Should Be 0
    @($r.Diagnostics).Count | Should Be 2
    $r.Diagnostics[0].File | Should Be 'PreemWeaponsmith\Core\PreemSettings.script'
    $r.Diagnostics[1].File | Should Be 'PreemWeaponsmith\Core\PreemModSettings.script'
    $r.Diagnostics[1].Line | Should Be 32
    $r.Diagnostics[1].Message | Should Be 'Syntax error near: @'
  }

  It 'keeps lines that are not JSON, and has no summary when the compiler stops early' {
    $r = Read-SccLog -Lines @('{"severity":0,"category":0,"message":"REDscript Compiler v1.2.2"}', 'Unhandled exception 0xC0000005')
    @($r.Other).Count | Should Be 1
    $r.Other[0] | Should Be 'Unhandled exception 0xC0000005'
    $r.Summary | Should Be $false
  }
}

Describe 'Group-SccDiagnostic' {
  It 'counts errors per file, most first' {
    $r = Read-SccLog -Lines $script:realLog
    $g = @(Group-SccDiagnostic -Diagnostics $r.Diagnostics)
    $g.Count | Should Be 2
    $g[0].File | Should Be 'PreemWeaponsmith\Adapters\ItemDataAdapter.script'
    $g[0].Count | Should Be 2
    $g[1].File | Should Be 'PreemWeaponsmith\Audio\PreemSoundSets.script'
    $g[1].Count | Should Be 1
  }
}

Describe 'Compare-ModioManifest' {
  It 'passes when every source file has exactly one entry' {
    $r = Compare-ModioManifest -SourceFiles @('Core/BaseEnums.reds', 'Adapters/ItemDataAdapter.reds') -Entries @{ 'Adapters/ItemDataAdapter.reds' = 'convert'; 'Core/BaseEnums.reds' = 'convert' }
    @($r.Missing).Count | Should Be 0
    @($r.Unknown).Count | Should Be 0
    @($r.BadAction).Count | Should Be 0
  }

  It 'lists a new source file without an entry, and an entry whose file is gone' {
    $r = Compare-ModioManifest -SourceFiles @('Core/BaseEnums.reds', 'Core/New.reds') -Entries @{ 'Core/BaseEnums.reds' = 'convert'; 'Core/Old.reds' = 'convert' }
    @($r.Missing) | Should Be @('Core/New.reds')
    @($r.Unknown) | Should Be @('Core/Old.reds')
  }

  It 'lists an entry with an action other than convert or pc-only' {
    $r = Compare-ModioManifest -SourceFiles @('Core/BaseEnums.reds') -Entries @{ 'Core/BaseEnums.reds' = 'skip' }
    @($r.BadAction) | Should Be @('Core/BaseEnums.reds')
  }
}
