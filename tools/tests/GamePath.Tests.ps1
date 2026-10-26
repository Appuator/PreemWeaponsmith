# Pester 3.4. The game folder comes from -GamePath, else REDCLI_GAME, else the folder CLAUDE.md names.
Import-Module (Join-Path $PSScriptRoot '..\GamePath.psm1') -Force

Describe 'Resolve-GamePath' {
  It 'uses -GamePath when given, over REDCLI_GAME' {
    $r = Resolve-GamePath -GamePath 'D:\Games\CP' -EnvValue 'E:\Other'
    $r.Path | Should Be 'D:\Games\CP'
    $r.Note | Should BeNullOrEmpty
  }

  It 'uses REDCLI_GAME when no -GamePath is given' {
    $r = Resolve-GamePath -GamePath '' -EnvValue 'E:\Other'
    $r.Path | Should Be 'E:\Other'
    $r.Note | Should BeNullOrEmpty
  }

  It 'falls back to the CLAUDE.md game folder when both are empty, and says so' {
    $r = Resolve-GamePath -GamePath '' -EnvValue ''
    $r.Path | Should Be 'S:\SteamLibrary\steamapps\common\Cyberpunk 2077'
    $r.Note | Should Be 'REDCLI_GAME is not set; using S:\SteamLibrary\steamapps\common\Cyberpunk 2077'
  }
}
