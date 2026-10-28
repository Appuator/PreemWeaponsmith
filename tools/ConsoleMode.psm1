# Console mode for tools/console-boot.ps1: the game folder as a console player has it, for one run.
# The PC-only parts move to a stash: RED4ext (its plugins too), redscript's engine\tools\scc.exe,
# scc_lib.dll and engine\config\base\scripts.ini (the game runs that scc.exe at every start, and
# without RED4ext it overwrites the vanilla r6\cache\final.redscripts, HANDOFF section 4), and every
# entry of r6\scripts. The stash keeps a list of what it holds (moves.txt), so a restore also works
# after an interrupted run. Tests: tools/tests/ConsoleMode.Tests.ps1.

$script:fixedItems = @('red4ext', 'engine\tools\scc.exe', 'engine\tools\scc_lib.dll', 'engine\config\base\scripts.ini')
$script:listName = 'moves.txt'

# One (Relative, From, Stash) per item that exists in the game folder.
function Get-ConsoleModeMoves {
  param([string]$GamePath, [string]$StashRoot)
  $rel = @($script:fixedItems | Where-Object { Test-Path -LiteralPath (Join-Path $GamePath $_) })
  $scripts = Join-Path $GamePath 'r6\scripts'
  if (Test-Path -LiteralPath $scripts) {
    $rel += @(Get-ChildItem -LiteralPath $scripts | ForEach-Object { "r6\scripts\$($_.Name)" })
  }
  foreach ($r in $rel) {
    [pscustomobject]@{ Relative = $r; From = (Join-Path $GamePath $r); Stash = (Join-Path $StashRoot $r) }
  }
}

function Move-ConsoleModeAside {
  param($Moves)
  if (-not @($Moves).Count) { return }
  $root = $Moves[0].Stash.Substring(0, $Moves[0].Stash.Length - $Moves[0].Relative.Length).TrimEnd('\')
  New-Item -ItemType Directory -Force $root | Out-Null
  # The list first, so an interruption mid-move still knows every item.
  Set-Content -LiteralPath (Join-Path $root $script:listName) -Value @($Moves | ForEach-Object Relative)
  foreach ($m in $Moves) {
    New-Item -ItemType Directory -Force (Split-Path $m.Stash) | Out-Null
    Move-Item -LiteralPath $m.From -Destination $m.Stash
  }
}

# Moves every listed item back. Returns the relative paths left in the stash because the game
# folder has that path again (the stash is kept then); removes the stash when it is empty.
function Restore-ConsoleMode {
  param([string]$StashRoot, [string]$GamePath)
  $list = Join-Path $StashRoot $script:listName
  if (-not (Test-Path -LiteralPath $list)) { return }
  $left = @()
  foreach ($r in @(Get-Content -LiteralPath $list | Where-Object { $_ })) {
    $stash = Join-Path $StashRoot $r
    if (-not (Test-Path -LiteralPath $stash)) { continue }
    $dest = Join-Path $GamePath $r
    if (Test-Path -LiteralPath $dest) { $left += $r; continue }
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Move-Item -LiteralPath $stash -Destination $dest
  }
  if ($left.Count) { return $left }
  Remove-Item -LiteralPath $StashRoot -Recurse -Force
}

# The verdict of a console-mode run, from the game's ScriptLogger.log lines (-logScripts): the mod
# must have bound, and each -Expect regex must match a line. Returns the problems found.
function Get-ConsoleBootProblems {
  param([string[]]$Lines = @(), [string[]]$Expect = @())
  $problems = @()
  if (-not @($Lines -match 'Success binding script mod').Count) { $problems += 'no "Success binding script mod" line in ScriptLogger.log' }
  foreach ($e in $Expect) {
    if (-not @($Lines -match $e).Count) { $problems += "no ScriptLogger.log line matches: $e" }
  }
  return $problems
}

Export-ModuleMember -Function Get-ConsoleModeMoves, Move-ConsoleModeAside, Restore-ConsoleMode, Get-ConsoleBootProblems
