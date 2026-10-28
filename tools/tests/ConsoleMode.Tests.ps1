# Pester 3.4. A fake game folder in TestDrive; expected moves worked out by hand from it.
Import-Module (Join-Path $PSScriptRoot '..\ConsoleMode.psm1') -Force

function New-FakeGame([string]$root) {
  foreach ($d in 'red4ext\plugins', 'engine\tools', 'engine\config\base', 'r6\scripts\PreemWeaponsmith', 'r6\scripts\RedTest', 'r6\cache') {
    New-Item -ItemType Directory -Force (Join-Path $root $d) | Out-Null
  }
  foreach ($f in 'red4ext\RED4ext.dll', 'engine\tools\scc.exe', 'engine\tools\scc_lib.dll', 'engine\config\base\scripts.ini',
      'engine\config\base\general.ini', 'r6\scripts\PreemWeaponsmith\a.reds', 'r6\cache\final.redscripts') {
    Set-Content -LiteralPath (Join-Path $root $f) -Value $f
  }
}

Describe 'Get-ConsoleModeMoves' {
  It 'lists RED4ext, redscript''s files and each r6\scripts entry, and nothing else' {
    $g = Join-Path $TestDrive 'g1'; New-FakeGame $g
    $moves = @(Get-ConsoleModeMoves -GamePath $g -StashRoot (Join-Path $TestDrive 's1'))
    @($moves | ForEach-Object Relative | Sort-Object) | Should Be @(
      'engine\config\base\scripts.ini', 'engine\tools\scc.exe', 'engine\tools\scc_lib.dll',
      'r6\scripts\PreemWeaponsmith', 'r6\scripts\RedTest', 'red4ext')
    $moves[0].Stash | Should Match '^.*\\s1\\'
  }

  It 'skips what is not installed' {
    $g = Join-Path $TestDrive 'g2'; New-FakeGame $g
    Remove-Item -LiteralPath (Join-Path $g 'red4ext') -Recurse
    Remove-Item -LiteralPath (Join-Path $g 'engine\config\base\scripts.ini')
    @(Get-ConsoleModeMoves -GamePath $g -StashRoot (Join-Path $TestDrive 's2') | ForEach-Object Relative) -contains 'red4ext' | Should Be $false
    @(Get-ConsoleModeMoves -GamePath $g -StashRoot (Join-Path $TestDrive 's2')).Count | Should Be 4
  }
}

Describe 'Move-ConsoleModeAside and Restore-ConsoleMode' {
  It 'moves everything out and puts it back exactly' {
    $g = Join-Path $TestDrive 'g3'; New-FakeGame $g; $s = Join-Path $TestDrive 's3'
    $before = @(Get-ChildItem -LiteralPath $g -Recurse -File | ForEach-Object { $_.FullName.Substring($g.Length) } | Sort-Object)
    $moves = @(Get-ConsoleModeMoves -GamePath $g -StashRoot $s)
    Move-ConsoleModeAside -Moves $moves
    Test-Path -LiteralPath (Join-Path $g 'red4ext') | Should Be $false
    Test-Path -LiteralPath (Join-Path $g 'engine\tools\scc.exe') | Should Be $false
    @(Get-ChildItem -LiteralPath (Join-Path $g 'r6\scripts')).Count | Should Be 0
    Test-Path -LiteralPath (Join-Path $g 'engine\config\base\general.ini') | Should Be $true
    $left = @(Restore-ConsoleMode -StashRoot $s -GamePath $g)
    $left.Count | Should Be 0
    @(Get-ChildItem -LiteralPath $g -Recurse -File | ForEach-Object { $_.FullName.Substring($g.Length) } | Sort-Object) | Should Be $before
    Test-Path -LiteralPath $s | Should Be $false
  }

  It 'restores from the stash alone, as after an interrupted run' {
    $g = Join-Path $TestDrive 'g4'; New-FakeGame $g; $s = Join-Path $TestDrive 's4'
    Move-ConsoleModeAside -Moves @(Get-ConsoleModeMoves -GamePath $g -StashRoot $s)
    Remove-Module ConsoleMode; Import-Module (Join-Path $PSScriptRoot '..\ConsoleMode.psm1') -Force
    @(Restore-ConsoleMode -StashRoot $s -GamePath $g).Count | Should Be 0
    Test-Path -LiteralPath (Join-Path $g 'engine\tools\scc.exe') | Should Be $true
    Test-Path -LiteralPath (Join-Path $g 'r6\scripts\PreemWeaponsmith\a.reds') | Should Be $true
  }

  It 'leaves an item in the stash, and reports it, when the game folder has that path again' {
    $g = Join-Path $TestDrive 'g5'; New-FakeGame $g; $s = Join-Path $TestDrive 's5'
    Move-ConsoleModeAside -Moves @(Get-ConsoleModeMoves -GamePath $g -StashRoot $s)
    Set-Content -LiteralPath (Join-Path $g 'engine\tools\scc.exe') -Value 'written during the run'
    $left = @(Restore-ConsoleMode -StashRoot $s -GamePath $g)
    $left | Should Be @('engine\tools\scc.exe')
    Get-Content -LiteralPath (Join-Path $g 'engine\tools\scc.exe') | Should Be 'written during the run'
    Test-Path -LiteralPath (Join-Path $s 'engine\tools\scc.exe') | Should Be $true
  }
}
