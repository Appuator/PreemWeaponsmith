# Whether the game window is in front, for the boot check's keyboard and screenshot steps: a key
# press goes to whatever window has focus, and a screenshot shows whatever is on screen.
# Tests: tools/tests/GameWindow.Tests.ps1.

<#
  The rule: $null when the foreground window belongs to one of the game processes, else a message
  that names what is in front and the step ($Action) the run stopped before. A foreground PID of 0
  means no window has focus (locked screen, UAC prompt). A minimized game window doesn't count:
  Windows can leave it the foreground window while something else is on screen (seen 2026-10-27).
#>
function Get-ForegroundProblem {
  param([int]$ForegroundPid, [string]$ForegroundName, [switch]$ForegroundMinimized, [int[]]$GamePids, [string]$Action)
  if (@($GamePids).Count -eq 0) { return "the game has no window before $Action" }
  $hint = 'keep off the PC during -LoadSave and -Screenshot runs, then run again'
  if (@($GamePids) -contains $ForegroundPid) {
    if ($ForegroundMinimized) { return "the game window is minimized before $Action; $hint" }
    return $null
  }
  if ($ForegroundPid -eq 0) { return "no window is in front (locked screen or a system dialog?) before $Action; $hint" }
  return "the game window is not in front ($ForegroundName is) before $Action; $hint"
}

<#
  The process that owns the foreground window: Pid (0 when no window has focus), Name, and
  Minimized (the window is iconic).
#>
function Get-ForegroundWindowProcess {
  Add-Type -Namespace PreemBoot -Name Foreground -MemberDefinition @'
[DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
[DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
'@ -ErrorAction SilentlyContinue
  $hwnd = [PreemBoot.Foreground]::GetForegroundWindow()
  [uint32]$fgPid = 0
  $minimized = $false
  if ($hwnd -ne [IntPtr]::Zero) {
    [PreemBoot.Foreground]::GetWindowThreadProcessId($hwnd, [ref]$fgPid) | Out-Null
    $minimized = [PreemBoot.Foreground]::IsIconic($hwnd)
  }
  $name = ''
  if ($fgPid -ne 0) { $name = (Get-Process -Id $fgPid -ErrorAction SilentlyContinue).ProcessName }
  [pscustomobject]@{ Pid = [int]$fgPid; Name = $name; Minimized = $minimized }
}

Export-ModuleMember -Function Get-ForegroundProblem, Get-ForegroundWindowProcess
