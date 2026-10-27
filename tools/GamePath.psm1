# Which game folder the tool scripts use: -GamePath, else REDCLI_GAME (the variable red-cli reads),
# else the folder CLAUDE.md names. A shell started before REDCLI_GAME was set doesn't have it
# (HANDOFF §2), hence the fallback. Tests: tools/tests/GamePath.Tests.ps1.

$script:defaultGamePath = 'S:\SteamLibrary\steamapps\common\Cyberpunk 2077'

# Path, and Note: a line for the script to print when the fallback was used, else $null.
function Resolve-GamePath {
  param([string]$GamePath, [string]$EnvValue)
  if ($GamePath) { return [pscustomobject]@{ Path = $GamePath; Note = $null } }
  if ($EnvValue) { return [pscustomobject]@{ Path = $EnvValue; Note = $null } }
  [pscustomobject]@{ Path = $script:defaultGamePath; Note = "REDCLI_GAME is not set; using $script:defaultGamePath" }
}

Export-ModuleMember -Function Resolve-GamePath
