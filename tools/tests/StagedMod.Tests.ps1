# Pester 3.4. A staged mod laid out like the game folder is copied in for one boot and removed again.
# The stage and game folders are built in TestDrive; expected paths are written out by hand.
Import-Module (Join-Path $PSScriptRoot '..\StagedMod.psm1') -Force

function New-TestFile([string]$path, [string]$text = 'x') {
  New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
  Set-Content -LiteralPath $path -Value $text
}

# Stage: two scripts in a new folder, one YAML in a new folder under the existing r6\tweaks, one
# archive in the existing archive\pc\mod. Game: r6\scripts, r6\tweaks\Other\other.yaml, archive\pc\mod.
function New-TestLayout {
  $stage = Join-Path $TestDrive 'stage'
  $game = Join-Path $TestDrive 'game'
  Remove-Item -LiteralPath $stage, $game -Recurse -Force -ErrorAction SilentlyContinue
  New-TestFile (Join-Path $stage 'r6\scripts\EC\a.reds')
  New-TestFile (Join-Path $stage 'r6\scripts\EC\core\b.reds')
  New-TestFile (Join-Path $stage 'r6\tweaks\EC\v.yaml')
  New-TestFile (Join-Path $stage 'archive\pc\mod\EC.archive')
  New-Item -ItemType Directory -Force (Join-Path $game 'r6\scripts') | Out-Null
  New-TestFile (Join-Path $game 'r6\tweaks\Other\other.yaml') 'keep'
  New-Item -ItemType Directory -Force (Join-Path $game 'archive\pc\mod') | Out-Null
  return @{ Stage = $stage; Game = $game }
}

# Relative paths joined with ';' (Pester 3's Should Be compares a piped array element by element).
function Get-GameFiles([string]$game) {
  $full = (Get-Item -LiteralPath $game).FullName
  (@(Get-ChildItem -LiteralPath $full -Recurse -File | ForEach-Object { $_.FullName.Substring($full.Length + 1) } | Sort-Object) -join ';')
}

Describe 'Copy-StagedMod' {
  It 'copies every staged file to the same path in the game and lists them' {
    $t = New-TestLayout
    $copied = Copy-StagedMod -StageRoot $t.Stage -GamePath $t.Game
    Get-GameFiles $t.Game | Should Be 'archive\pc\mod\EC.archive;r6\scripts\EC\a.reds;r6\scripts\EC\core\b.reds;r6\tweaks\EC\v.yaml;r6\tweaks\Other\other.yaml'
    @($copied.Files).Count | Should Be 4
  }

  It 'refuses when a staged file is already in the game, and copies nothing' {
    $t = New-TestLayout
    New-TestFile (Join-Path $t.Game 'r6\tweaks\EC\v.yaml') 'old'
    { Copy-StagedMod -StageRoot $t.Stage -GamePath $t.Game } | Should Throw 'r6\tweaks\EC\v.yaml'
    Get-GameFiles $t.Game | Should Be 'r6\tweaks\EC\v.yaml;r6\tweaks\Other\other.yaml'
    Get-Content -LiteralPath (Join-Path $t.Game 'r6\tweaks\EC\v.yaml') | Should Be 'old'
  }
}

Describe 'Remove-StagedMod' {
  It 'removes exactly the copied files and the folders the copy created' {
    $t = New-TestLayout
    $copied = Copy-StagedMod -StageRoot $t.Stage -GamePath $t.Game
    $left = @(Remove-StagedMod -Copied $copied)
    $left.Count | Should Be 0
    Get-GameFiles $t.Game | Should Be 'r6\tweaks\Other\other.yaml'
    Test-Path -LiteralPath (Join-Path $t.Game 'r6\scripts\EC') | Should Be $false
    Test-Path -LiteralPath (Join-Path $t.Game 'r6\tweaks\EC') | Should Be $false
    Test-Path -LiteralPath (Join-Path $t.Game 'r6\scripts') | Should Be $true
    Test-Path -LiteralPath (Join-Path $t.Game 'archive\pc\mod') | Should Be $true
  }

  It 'keeps a created folder that something else wrote into, and still removes the copied files' {
    $t = New-TestLayout
    $copied = Copy-StagedMod -StageRoot $t.Stage -GamePath $t.Game
    New-TestFile (Join-Path $t.Game 'r6\scripts\EC\written-by-game.log')
    Remove-StagedMod -Copied $copied | Out-Null
    Get-GameFiles $t.Game | Should Be 'r6\scripts\EC\written-by-game.log;r6\tweaks\Other\other.yaml'
  }

  It 'does not fail when a copied file is already gone' {
    $t = New-TestLayout
    $copied = Copy-StagedMod -StageRoot $t.Stage -GamePath $t.Game
    Remove-Item -LiteralPath (Join-Path $t.Game 'r6\scripts\EC\a.reds')
    $left = @(Remove-StagedMod -Copied $copied)
    $left.Count | Should Be 0
    Get-GameFiles $t.Game | Should Be 'r6\tweaks\Other\other.yaml'
  }
}
