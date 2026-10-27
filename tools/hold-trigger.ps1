<#
.SYNOPSIS
  Pulls the real trigger for a -Run script: holds the left mouse button in the game window each
  time the script raises a flag file.

.DESCRIPTION
  Some sounds only come from the player's own weapon path, e.g. the charge-start sound while the
  trigger is held, which AIWeapon.Fire can't reach. Start this in the background before
  tools/boot-check.ps1 -LoadSave -Run <file.lua>. Each time the Lua script writes trigger-now.txt in
  its CET mod folder (PreemBootRun), this script brings the game window to the front, holds the
  left button for -HoldMs, and deletes the flag; the Lua can raise it again. Mouse clicks injected
  this way fire the weapon, but they don't move the game's UI cursor (HANDOFF §5), so this is no
  use in menus. Stops after -TimeoutMin, or when the game exits after having started.

.EXAMPLE
  Start-Process pwsh -ArgumentList '-NoProfile','-File','tools/hold-trigger.ps1' -WindowStyle Hidden
  pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/sound-check.lua -HoldSec 70
#>
[CmdletBinding()]
param(
  [string]$GamePath,
  [int]$HoldMs = 2500,
  [int]$TimeoutMin = 8
)

Import-Module (Join-Path $PSScriptRoot 'GamePath.psm1') -Force
$game = Resolve-GamePath -GamePath $GamePath -EnvValue $env:REDCLI_GAME
$flag = Join-Path $game.Path 'bin\x64\plugins\cyber_engine_tweaks\mods\PreemBootRun\trigger-now.txt'
if (Test-Path -LiteralPath $flag) { Remove-Item -LiteralPath $flag }

Add-Type -Namespace PreemHold -Name Mouse -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
[DllImport("user32.dll")] public static extern void mouse_event(uint f, int dx, int dy, uint d, UIntPtr e);
'@

$deadline = (Get-Date).AddMinutes($TimeoutMin)
$seenGame = $false
$holds = 0
while ((Get-Date) -lt $deadline) {
  $proc = Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | Select-Object -First 1
  if ($proc) { $seenGame = $true } elseif ($seenGame) { break }
  if ($proc -and (Test-Path -LiteralPath $flag)) {
    [PreemHold.Mouse]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
    Start-Sleep -Milliseconds 200
    [PreemHold.Mouse]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds $HoldMs
    [PreemHold.Mouse]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
    Remove-Item -LiteralPath $flag -ErrorAction SilentlyContinue
    $holds++
    Write-Host "hold-trigger: held $HoldMs ms at $(Get-Date -Format HH:mm:ss)"
  }
  Start-Sleep -Milliseconds 200
}
Write-Host "hold-trigger: done, $holds holds"
