# Pester 3.4 (the copy that ships with Windows): pwsh -c "Invoke-Pester tools/tests"
# Log lines are copied from the 2026-10-25 framework-only boot on 2.5; expected values are
# worked out by hand from the pins below, not recomputed by the module.
Import-Module (Join-Path $PSScriptRoot '..\BootDeps.psm1') -Force

function New-Pin($name, $version, $bootLog, [bool]$enabled = $true) {
  [pscustomobject]@{ name = $name; version = $version; bootLog = $bootLog; enabled = $enabled }
}

$pins = @(
  New-Pin 'RED4ext' '1.31.0' 'red4ext'
  New-Pin 'redscript' '0.5.32' 'redscript'
  New-Pin 'CET' '1.38.0' 'cet'
  New-Pin 'Codeware' '1.21.0' 'red4ext-plugin'
  New-Pin 'TweakXL' '1.12.0' 'red4ext-plugin'
  New-Pin 'Mod Settings' '0.2.22' 'red4ext-plugin'
  New-Pin 'Audioware' '1.9.9' 'red4ext-plugin' $false
)

$red4ext = @(
  '[2026-10-25 16:10:05.250] [info    ] [ 61876] [RED4ext] RED4ext (v1.31.0) is initializing...'
  '[2026-10-25 16:10:07.066] [info    ] [ 61876] [RED4ext] ArchiveXL (version: 1.28.0, author(s): psiberx) has been loaded'
  '[2026-10-25 16:10:08.591] [info    ] [ 61876] [RED4ext] Codeware (version: 1.21.0, author(s): psiberx) has been loaded'
  '[2026-10-25 16:10:08.593] [info    ] [ 61876] [RED4ext] Mod Settings (version: 0.2.22, author(s): Jack Humbert) has been loaded'
  '[2026-10-25 16:10:08.821] [info    ] [ 61876] [RED4ext] TweakXL (version: 1.12.0, author(s): psiberx) has been loaded'
  '[2026-10-25 16:10:08.821] [info    ] [ 61876] [RED4ext] 4 plugin(s) loaded'
)
$cet = @('[2026-10-25 16:10:04 UTC-07:00] [info] [__cdecl Options::Options(struct Paths &)] [61876] CET version v1.38.0 [HEAD]')
$redscript = @(
  '[INFO - Sun, 25 Oct 2026 16:10:17 -0700] Compilation complete'
  '[INFO - Sun, 25 Oct 2026 16:10:17 -0700] Output successfully saved to final.redscripts.modded'
)

function Get-Row($report, $name) { $report | Where-Object Name -eq $name }

Describe 'Get-BootDependencyReport' {
  It 'passes every enabled pin on the real 2.5 boot logs' {
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog $red4ext -CetLog $cet -RedscriptLog $redscript -RedscriptMatchesPin $true
    @($r).Count | Should Be 7
    (Get-Row $r 'RED4ext').Status | Should Be 'ok'
    (Get-Row $r 'RED4ext').Found | Should Be '1.31.0'
    (Get-Row $r 'redscript').Status | Should Be 'ok'
    (Get-Row $r 'CET').Found | Should Be '1.38.0'
    (Get-Row $r 'CET').Status | Should Be 'ok'
    (Get-Row $r 'Codeware').Status | Should Be 'ok'
    (Get-Row $r 'TweakXL').Status | Should Be 'ok'
    (Get-Row $r 'Mod Settings').Found | Should Be '0.2.22'
    (Get-Row $r 'Mod Settings').Status | Should Be 'ok'
    (Get-Row $r 'Audioware').Status | Should Be 'disabled'
  }

  It 'reports a plugin that did not load' {
    $log = $red4ext | Where-Object { $_ -notmatch 'Codeware' }
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog $log -CetLog $cet -RedscriptLog $redscript -RedscriptMatchesPin $true
    (Get-Row $r 'Codeware').Status | Should Be 'not-loaded'
    (Get-Row $r 'TweakXL').Status | Should Be 'ok'
  }

  It 'reports a plugin version that differs from the pin' {
    $log = $red4ext -replace 'TweakXL \(version: 1\.12\.0', 'TweakXL (version: 1.11.0'
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog $log -CetLog $cet -RedscriptLog $redscript -RedscriptMatchesPin $true
    (Get-Row $r 'TweakXL').Status | Should Be 'version-mismatch'
    (Get-Row $r 'TweakXL').Found | Should Be '1.11.0'
  }

  It 'reports RED4ext and CET version mismatches' {
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog ($red4ext -replace 'v1\.31\.0', 'v1.30.1') `
      -CetLog ($cet -replace 'v1\.38\.0', 'v1.37.2') -RedscriptLog $redscript -RedscriptMatchesPin $true
    (Get-Row $r 'RED4ext').Status | Should Be 'version-mismatch'
    (Get-Row $r 'RED4ext').Found | Should Be '1.30.1'
    (Get-Row $r 'CET').Status | Should Be 'version-mismatch'
    (Get-Row $r 'CET').Found | Should Be '1.37.2'
  }

  It 'reports CET missing from the log' {
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog $red4ext -CetLog @() -RedscriptLog $redscript -RedscriptMatchesPin $true
    (Get-Row $r 'CET').Status | Should Be 'not-loaded'
  }

  It 'reports a disabled plugin that loaded anyway' {
    $log = $red4ext + '[2026-10-25 16:10:09.000] [info    ] [ 61876] [RED4ext] Audioware (version: 1.9.9, author(s): Roms1383) has been loaded'
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog $log -CetLog $cet -RedscriptLog $redscript -RedscriptMatchesPin $true
    (Get-Row $r 'Audioware').Status | Should Be 'disabled-but-loaded'
  }

  It 'reports redscript not compiling, and an unverifiable or different redscript version' {
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog $red4ext -CetLog $cet -RedscriptLog @('[ERROR - x] boom') -RedscriptMatchesPin $true
    (Get-Row $r 'redscript').Status | Should Be 'not-loaded'
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog $red4ext -CetLog $cet -RedscriptLog $redscript -RedscriptMatchesPin $null
    (Get-Row $r 'redscript').Status | Should Be 'unverified'
    $r = Get-BootDependencyReport -Pins $pins -Red4extLog $red4ext -CetLog $cet -RedscriptLog $redscript -RedscriptMatchesPin $false
    (Get-Row $r 'redscript').Status | Should Be 'version-mismatch'
  }
}

Describe 'Select-LinesSince' {
  # CET appends to the same log every run; only this run's lines may count.
  $log = @(
    '[2026-10-25 14:50:51 UTC-07:00] [info] [x] [58580] CET version v1.37.0 [HEAD]'
    '[2026-10-25 14:50:52 UTC-07:00] [error] [x] [58580] old failure'
    '  old continuation line'
    '[2026-10-25 16:10:04 UTC-07:00] [info] [x] [61876] CET version v1.38.0 [HEAD]'
    '  new continuation line'
    '[2026-10-25 16:10:30 UTC-07:00] [info] [x] [61876] later'
  )
  It 'keeps only lines stamped at or after the start, with their continuation lines' {
    $r = @(Select-LinesSince -Lines $log -Since ([datetime]'2026-10-25 16:10:00'))
    $r.Count | Should Be 3
    $r[0] | Should Match 'v1\.38\.0'
    $r[1] | Should Be '  new continuation line'
    $r[2] | Should Match 'later'
  }
  It 'also reads the spdlog stamp with milliseconds' {
    $r = @(Select-LinesSince -Lines @('[2026-10-25 16:09:59.999] [info] a', '[2026-10-25 16:10:00.000] [info] b') -Since ([datetime]'2026-10-25 16:10:00'))
    $r.Count | Should Be 1
    $r[0] | Should Match ' b$'
  }
}
