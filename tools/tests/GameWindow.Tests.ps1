# Pester 3.4 (the copy that ships with Windows): pwsh -c "Invoke-Pester tools/tests"
# The rule only; the Win32 lookup of the foreground window (Get-ForegroundWindowProcess) is
# checked by the boot-check runs.
Import-Module (Join-Path $PSScriptRoot '..\GameWindow.psm1') -Force

Describe 'Get-ForegroundProblem' {
  It 'is quiet when the game window is in front' {
    Get-ForegroundProblem -ForegroundPid 4242 -ForegroundName 'Cyberpunk2077' -GamePids @(4242) -Action 'pressing Space' | Should BeNullOrEmpty
  }
  It 'is quiet when the window in front is any of the game processes (Steam may restart it once)' {
    Get-ForegroundProblem -ForegroundPid 5000 -ForegroundName 'Cyberpunk2077' -GamePids @(4242, 5000) -Action 'pressing Space' | Should BeNullOrEmpty
  }
  It 'names the window in front and the step it stopped before' {
    $p = Get-ForegroundProblem -ForegroundPid 777 -ForegroundName 'notepad' -GamePids @(4242) -Action 'the screenshot'
    $p | Should Be 'the game window is not in front (notepad is) before the screenshot; keep off the PC during -LoadSave and -Screenshot runs, then run again'
  }
  It 'says so when no window is in front (locked screen or a system dialog)' {
    $p = Get-ForegroundProblem -ForegroundPid 0 -ForegroundName '' -GamePids @(4242) -Action 'pressing Space'
    $p | Should Be 'no window is in front (locked screen or a system dialog?) before pressing Space; keep off the PC during -LoadSave and -Screenshot runs, then run again'
  }
  It 'treats a minimized game window as not in front (it can keep the foreground while minimized)' {
    $p = Get-ForegroundProblem -ForegroundPid 4242 -ForegroundName 'Cyberpunk2077' -ForegroundMinimized -GamePids @(4242) -Action 'the screenshot'
    $p | Should Be 'the game window is minimized before the screenshot; keep off the PC during -LoadSave and -Screenshot runs, then run again'
  }
  It 'says so when the game has no window' {
    $p = Get-ForegroundProblem -ForegroundPid 777 -ForegroundName 'notepad' -GamePids @() -Action 'the screenshot'
    $p | Should Be 'the game has no window before the screenshot'
  }
}
