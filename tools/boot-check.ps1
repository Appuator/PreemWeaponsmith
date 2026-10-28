<#
.SYNOPSIS
  Boot check: launches the game, waits for the main menu, closes it, collects and checks the logs.

.DESCRIPTION
  Installs the dev CET mod dev/cet/PreemBoot (main-menu marker), starts Cyberpunk2077.exe with
  -skipStartScreen and waits until the marker file says the main menu controller initialized.
  Then it closes the game the way the window's close button does (logs are flushed only on a
  clean exit; killed only if it hangs), copies every log written during the run into
  logs\boot-<timestamp>\ (of CET's logs, which every run appends to, only this run's lines; rule
  in tools/BootDeps.psm1, Select-RunLogLines) and checks them:
    - redscript compiled (a "Compilation complete" line, no [ERROR] lines)
    - no error/critical lines in the RED4ext, plugin or CET logs (CET's: this run's lines only)
    - dependency check: every enabled pin in docs/DEPENDENCIES.md loaded at its pinned version
      and no disabled pin loaded (rules in tools/BootDeps.psm1; each pin's bootLog field says
      which log shows it)
    - dev code (tools/dev-install.ps1): RedTest results, and with the mod installed the PreemDev
      TweakDB self-check (one PASS/FAIL line per record check; any FAIL fails the boot check)
  On a timeout or an early exit it saves a screenshot of the primary screen (screen.png in the
  log folder) before closing the game, since a stall is often a dialog only visible on screen.
  Removes the marker mod again at the end, even on failure. Prints which script mods were
  installed in r6\scripts, so a framework-only boot can be told apart from a modded one.

  -Run <file.lua> installs that Lua file as a one-off CET mod (PreemBootRun) for this run, e.g.
  to call PreemDev exec functions at the main menu; -HoldSec keeps the game open that long after
  the main menu so the script can finish. Both are removed again at the end; files the script
  wrote in its mod folder are copied to the log folder first.

  -Screenshot saves screen.png in the log folder at the end of the hold (to look at UI a -Run
  script opened). If the game window isn't in front then, it takes no screenshot and fails.

  -LoadSave loads the newest save from the main menu (as Continue does), presses Space to get
  past "Press Space to continue" (the game window comes to the front), and waits until game time
  runs; a -Run script should wait for that itself (dev/cet/debug-smoke.lua shows how). If the
  game window still isn't in front before a press (someone is using the PC), it stops and fails
  without pressing (tools/GameWindow.psm1). It prints
  the name and time of that save (read from -SaveDir before launch, tools/SaveInfo.psm1), at the
  start and again in the summary.

  -Without <pin names> boots without those dependencies (e.g. "Mod Settings", which is optional):
  their plugin folder (the folder of the pin's versionFile) is moved to
  game-folder-backup\boot-without\ for the run, left out of the dependency check, and moved back
  at the end. A folder left there by an interrupted run is moved back first.

  -WithEnhancedCraft copies the staged EnhancedCraft release (-EnhancedCraftStage, laid out like the
  game folder) into the game for this run and removes exactly the files it copied (and the folders
  it created) at the end, also on failure. It refuses to start if any of those files is already in
  the game (rules in tools/StagedMod.psm1).

  -ExtraArgs adds launch arguments after -skipStartScreen, e.g. -LoadScriptMods (loads the mod.io
  style script patches in <game>\r6\c77).

  -ConsoleMode is for tools/console-boot.ps1 only, which sets up the game folder for it.

  Never runs while the game is open (the user may be playing). Exit code 0 = reached the main
  menu with clean logs, 1 = timeout, crash, log errors or bad setup.

.EXAMPLE
  pwsh tools/boot-check.ps1
  pwsh tools/boot-check.ps1 -TimeoutSec 400
  pwsh tools/boot-check.ps1 -Run dev/cet/craft-e2e.lua -HoldSec 20
  pwsh tools/boot-check.ps1 -WithEnhancedCraft
#>
[CmdletBinding()]
param(
  # Game folder; default: REDCLI_GAME (the variable red-cli reads), else the CLAUDE.md folder
  # (tools/GamePath.psm1).
  [string]$GamePath,
  # How long to wait for the main menu marker.
  [int]$TimeoutSec = 300,
  # Where log captures go (gitignored).
  [string]$LogRoot = (Join-Path $PSScriptRoot '..\logs'),
  # Pins the dependency check compares against, and the release cache install-deps fills.
  [string]$PinFile = (Join-Path $PSScriptRoot '..\docs\DEPENDENCIES.md'),
  [string]$CacheDir = (Join-Path $PSScriptRoot '..\..\downloads\deps-cache'),
  # A Lua file to run as a one-off CET mod during this boot, and how long to keep the game open
  # after the main menu for it.
  [string]$Run,
  [int]$HoldSec = 0,
  # Load the newest save from the main menu and wait until the player is in the game (marker
  # "in-game") instead of stopping at the main menu. -HoldSec then counts from there.
  [switch]$LoadSave,
  # The game's save folder; -LoadSave prints the name and time of its newest save.
  [string]$SaveDir = (Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Saved Games\CD Projekt Red\Cyberpunk 2077'),
  # Save screen.png in the log folder at the end of the hold (to look at UI a -Run script opened).
  [switch]$Screenshot,
  # Pin names (docs/DEPENDENCIES.md) to boot without, e.g. 'Mod Settings'.
  [string[]]$Without = @(),
  [string]$WithoutStash = (Join-Path $PSScriptRoot '..\..\game-folder-backup\boot-without'),
  # Boot with the staged EnhancedCraft release copied in for this run only.
  [switch]$WithEnhancedCraft,
  [string]$EnhancedCraftStage = (Join-Path $PSScriptRoot '..\..\downloads\2026-10-25_EnhancedCraft'),
  # More launch arguments, e.g. -LoadScriptMods.
  [string[]]$ExtraArgs = @(),
  # Set by tools/console-boot.ps1, which has taken RED4ext, redscript and r6\scripts out for the
  # run: skips the redscript check and every dependency but CET, and prints every [Preem...] game
  # log line.
  [switch]$ConsoleMode
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3
Add-Type -AssemblyName System.IO.Compression.FileSystem
Import-Module (Join-Path $PSScriptRoot 'BootDeps.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'RedTestLog.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'SelfCheckLog.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'StagedMod.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'SaveInfo.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'GameWindow.psm1') -Force

function Read-Pins([string]$path) {
  $text = Get-Content -LiteralPath $path -Raw
  $m = [regex]::Match($text, '(?s)<!-- install-deps:begin -->\s*```json\s*(.*?)```\s*<!-- install-deps:end -->')
  if (-not $m.Success) { throw "No install-deps pin block found in $path" }
  return @($m.Groups[1].Value | ConvertFrom-Json)
}

# redscript logs no version: compare scc.exe and scc_lib.dll with the pinned release zip.
# $null when the zip is not in the cache (run tools/install-deps.ps1 to fill it).
function Test-RedscriptMatchesPin($pin) {
  $zipPath = Join-Path $CacheDir $pin.asset
  if (-not (Test-Path -LiteralPath $zipPath)) { return $null }
  $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
  try {
    foreach ($name in 'engine/tools/scc.exe', 'engine/tools/scc_lib.dll') {
      $entry = $zip.GetEntry($name)
      $dest = Join-Path $GamePath $name
      if (-not $entry -or -not (Test-Path -LiteralPath $dest)) { return $false }
      $tmp = [IO.Path]::GetTempFileName()
      try {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $tmp, $true)
        if ((Get-FileHash -LiteralPath $tmp).Hash -ne (Get-FileHash -LiteralPath $dest).Hash) { return $false }
      } finally { Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue }
    }
    return $true
  } finally { $zip.Dispose() }
}

# Saves the primary screen as a PNG, in physical pixels (the process is made DPI-aware so a
# scaled display isn't cropped). $false when no screen could be captured.
function Save-Screenshot([string]$path) {
  try {
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    Add-Type -Namespace PreemBoot -Name Dpi -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetProcessDPIAware();' -ErrorAction SilentlyContinue
    [PreemBoot.Dpi]::SetProcessDPIAware() | Out-Null
    $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
    try {
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)
      $g.Dispose()
      $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $bmp.Dispose() }
    return $true
  } catch {
    Write-Host "boot-check: screenshot failed: $($_.Exception.Message)" -ForegroundColor Yellow
    return $false
  }
}

# Brings the game window to the front and presses Space (by scan code, which the game's raw
# input sees like a real key press). Used to dismiss the loading screen after -LoadSave.
# Returns a problem message, without pressing, when the game window didn't come to the front
# (Windows refuses SetForegroundWindow while someone is using another window).
function Send-GameKeySpace {
  Add-Type -Namespace PreemBoot -Name Keys -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
'@ -ErrorAction SilentlyContinue
  $game = Get-Game | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | Select-Object -First 1
  if (-not $game) { return }
  [PreemBoot.Keys]::SetForegroundWindow($game.MainWindowHandle) | Out-Null
  Start-Sleep -Milliseconds 200
  $problem = Get-GameFocusProblem 'pressing Space'
  if ($problem) { return $problem }
  [PreemBoot.Keys]::keybd_event(0x20, 0x39, 0x0008, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 80
  [PreemBoot.Keys]::keybd_event(0x20, 0x39, 0x000A, [UIntPtr]::Zero)
}

function Fail([string]$msg) { Write-Host "boot-check: $msg" -ForegroundColor Red; exit 1 }
function Get-Game { Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue }

# $null when the game window is in front, else why not (before $action).
function Get-GameFocusProblem([string]$action) {
  $fg = Get-ForegroundWindowProcess
  $pids = @(Get-Game | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | ForEach-Object { $_.Id })
  return Get-ForegroundProblem -ForegroundPid $fg.Pid -ForegroundName $fg.Name -ForegroundMinimized:$fg.Minimized -GamePids $pids -Action $action
}

Import-Module (Join-Path $PSScriptRoot 'GamePath.psm1') -Force
$game = Resolve-GamePath -GamePath $GamePath -EnvValue $env:REDCLI_GAME
$GamePath = $game.Path
if ($game.Note) { Write-Host "boot-check: $($game.Note)" }
$exe = Join-Path $GamePath 'bin\x64\Cyberpunk2077.exe'
if (-not (Test-Path -LiteralPath $exe)) { Fail "game not found: $exe" }
if (Get-Game) { Fail 'Cyberpunk 2077 is running; close it first' }
$cetMods = Join-Path $GamePath 'bin\x64\plugins\cyber_engine_tweaks\mods'
if (-not (Test-Path -LiteralPath $cetMods)) { Fail 'CET not installed (the main-menu marker needs it)' }

$scriptMods = @(Get-ChildItem -LiteralPath (Join-Path $GamePath 'r6\scripts') -ErrorAction SilentlyContinue | ForEach-Object Name)
Write-Host "boot-check: script mods in r6\scripts: $(if ($scriptMods) { $scriptMods -join ', ' } else { 'none (framework-only boot)' })"

# Plugin folders to move aside for -Without, as (game folder, stash folder) pairs.
$allPins = Read-Pins $PinFile
$stashes = @(foreach ($name in $Without) {
  # Without RED4ext, redscript's scc.exe (run by the game at every start) overwrites the vanilla
  # r6\cache\final.redscripts and keeps it as .bk, which breaks the compile checks (HANDOFF §4).
  if ($name -eq 'RED4ext') { Fail "-Without RED4ext: redscript would overwrite the vanilla r6\cache\final.redscripts (HANDOFF section 4, 2026-10-28)" }
  $pin = $allPins | Where-Object name -eq $name | Select-Object -First 1
  if (-not $pin) { Fail "-Without: no pin named '$name' in $PinFile" }
  $folder = Join-Path $GamePath (Split-Path ($pin.versionFile -replace '/', '\'))
  [pscustomobject]@{ Name = $name; Folder = $folder; Stash = (Join-Path $WithoutStash ($name -replace '[^\w]', '_')) }
})
function Restore-Stashes {
  foreach ($st in $stashes) {
    if ((Test-Path -LiteralPath $st.Stash) -and -not (Test-Path -LiteralPath $st.Folder)) {
      Move-Item -LiteralPath $st.Stash -Destination $st.Folder
      Write-Host "boot-check: restored $($st.Name) to $($st.Folder)"
    }
  }
}
Restore-Stashes
foreach ($st in $stashes) {
  if (-not (Test-Path -LiteralPath $st.Folder)) { Fail "-Without: $($st.Name) is not installed ($($st.Folder))" }
  New-Item -ItemType Directory -Force (Split-Path $st.Stash) | Out-Null
  Move-Item -LiteralPath $st.Folder -Destination $st.Stash
  Write-Host "boot-check: booting without $($st.Name) (moved to $($st.Stash))"
}

$markerMod = Join-Path $cetMods 'PreemBoot'
$runMod = Join-Path $cetMods 'PreemBootRun'
if ($Run -and -not (Test-Path -LiteralPath $Run)) { Fail "run script not found: $Run" }
$marker = Join-Path $markerMod 'boot-marker.txt'
$start = Get-Date
$runDir = Join-Path $LogRoot ('boot-' + $start.ToString('yyyy-MM-dd_HH-mm-ss'))
$result = 'timeout'
$problems = @()

# The save -LoadSave will load, read before launch (the run's own autosaves come later), so save
# drift between runs shows in the output.
$save = $null
if ($LoadSave) {
  $save = Get-NewestSave -SaveDir $SaveDir
  if (-not $save) { Restore-Stashes; Fail "-LoadSave: no save in $SaveDir" }
  Write-Host "boot-check: will load save $($save.Name) ($($save.Time))"
}

$enhancedCraft = $null
if ($WithEnhancedCraft) {
  if (-not (Test-Path -LiteralPath $EnhancedCraftStage)) { Restore-Stashes; Fail "EnhancedCraft stage not found: $EnhancedCraftStage" }
  try { $enhancedCraft = Copy-StagedMod -StageRoot $EnhancedCraftStage -GamePath $GamePath }
  catch { Restore-Stashes; Fail "-WithEnhancedCraft: $($_.Exception.Message)" }
  Write-Host "boot-check: EnhancedCraft copied in for this run ($($enhancedCraft.Files.Count) files)"
}

try {
  Remove-Item -LiteralPath $markerMod -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force $markerMod | Out-Null
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot '..\dev\cet\PreemBoot\init.lua') -Destination $markerMod
  # With -LoadSave the marker mod loads the newest save and the run waits for "in-game".
  $target = 'main-menu'
  if ($LoadSave) {
    Set-Content -LiteralPath (Join-Path $markerMod 'load-save.txt') -Value 'load the newest save'
    $target = 'playing'
  }
  $lastPress = Get-Date
  Remove-Item -LiteralPath $runMod -Recurse -Force -ErrorAction SilentlyContinue
  if ($Run) {
    New-Item -ItemType Directory -Force $runMod | Out-Null
    Copy-Item -LiteralPath $Run -Destination (Join-Path $runMod 'init.lua')
    Write-Host "boot-check: running $Run as CET mod PreemBootRun"
  }

  Write-Host "boot-check: launching, waiting up to $TimeoutSec s for $(if ($LoadSave) { 'the newest save to load' } else { 'the main menu' })..."
  $launchArgs = @('-skipStartScreen') + $ExtraArgs
  if ($ExtraArgs.Count) { Write-Host "boot-check: launch arguments $($launchArgs -join ' ')" }
  Start-Process -FilePath $exe -ArgumentList $launchArgs -WorkingDirectory (Split-Path $exe)
  $seen = $false
  $goneSince = $null
  while (((Get-Date) - $start).TotalSeconds -lt $TimeoutSec) {
    Start-Sleep -Seconds 1
    if ((Test-Path -LiteralPath $marker) -and (Select-String -LiteralPath $marker -Pattern $target -SimpleMatch -Quiet)) {
      $result = 'main-menu'; break
    }
    # The loaded save waits on "Press Space to continue" with the world paused.
    if ($LoadSave -and ((Get-Date) - $lastPress).TotalSeconds -ge 3 -and (Test-Path -LiteralPath $marker) -and
        (Select-String -LiteralPath $marker -Pattern 'in-game' -SimpleMatch -Quiet)) {
      $focusProblem = Send-GameKeySpace
      if ($focusProblem) { $problems += $focusProblem; $result = 'not-in-front'; break }
      $lastPress = Get-Date
    }
    # Steam may restart the process once, so only a lasting absence counts as a crash.
    if (Get-Game) { $seen = $true; $goneSince = $null }
    elseif ($seen) {
      if (-not $goneSince) { $goneSince = Get-Date }
      elseif (((Get-Date) - $goneSince).TotalSeconds -gt 15) { $result = 'exited'; break }
    }
  }
  $elapsed = ((Get-Date) - $start).TotalSeconds
  switch ($result) {
    'main-menu' {
      Write-Host ("boot-check: {0} after {1:N0} s" -f $(if ($LoadSave) { 'save loaded' } else { 'main menu' }), $elapsed)
      if ($HoldSec -gt 0) { Write-Host "boot-check: holding $HoldSec s"; Start-Sleep -Seconds $HoldSec }
      if ($Screenshot) {
        $focusProblem = Get-GameFocusProblem 'the screenshot'
        if ($focusProblem) { $problems += $focusProblem }
        else {
          New-Item -ItemType Directory -Force $runDir | Out-Null
          $shot = Join-Path $runDir 'screen.png'
          if (Save-Screenshot $shot) { Write-Host "boot-check: screenshot saved to $((Resolve-Path -LiteralPath $shot).Path)" }
        }
      }
    }
    # The message is in $problems already; no screenshot of someone else's screen.
    'not-in-front' { Write-Host "boot-check: stopped: $($problems[-1])" -ForegroundColor Red }
    'exited' { $problems += ("game exited after {0:N0} s without reaching the main menu (crash?)" -f $elapsed) }
    default { $problems += "no $(if ($LoadSave) { 'loaded save' } else { 'main menu' }) within $TimeoutSec s" }
  }
  if ($result -notin 'main-menu', 'not-in-front') {
    New-Item -ItemType Directory -Force $runDir | Out-Null
    $shot = Join-Path $runDir 'screen.png'
    if (Save-Screenshot $shot) { Write-Host "boot-check: screenshot saved to $((Resolve-Path -LiteralPath $shot).Path)" }
  }

  $game = Get-Game
  if ($game) {
    foreach ($p in $game) { $p.CloseMainWindow() | Out-Null }
    foreach ($p in $game) { $p.WaitForExit(60000) | Out-Null }
    if (Get-Game) {
      # Before the window exists (a timeout during loading) closing it does nothing.
      Get-Game | Stop-Process -Force
      Get-Game | Wait-Process -Timeout 60 -ErrorAction SilentlyContinue
      $problems += 'game did not close within 60 s and was killed (CET logs may be incomplete)'
    }
  }
} finally {
  # Keep the marker with the logs, then remove the mod from the game. A game that is still
  # exiting holds the files open for a few seconds.
  New-Item -ItemType Directory -Force $runDir | Out-Null
  if (Test-Path -LiteralPath $marker) { Copy-Item -LiteralPath $marker -Destination $runDir }
  # Files a -Run script wrote in its mod folder (e.g. tweak-dump.txt) go with the logs too.
  if (Test-Path -LiteralPath $runMod) {
    Get-ChildItem -LiteralPath $runMod -File | Where-Object Name -ne 'init.lua' |
      Copy-Item -Destination $runDir -ErrorAction SilentlyContinue
  }
  foreach ($mod in $markerMod, $runMod) {
    for ($i = 0; $i -lt 10 -and (Test-Path -LiteralPath $mod); $i++) {
      Remove-Item -LiteralPath $mod -Recurse -Force -ErrorAction SilentlyContinue
      if (Test-Path -LiteralPath $mod) { Start-Sleep -Seconds 3 }
    }
    if (Test-Path -LiteralPath $mod) { Write-Host "boot-check: could not remove $mod; delete it by hand" -ForegroundColor Yellow }
  }
  Restore-Stashes
  if ($enhancedCraft) {
    $left = @(Remove-StagedMod -Copied $enhancedCraft)
    for ($i = 0; $i -lt 10 -and $left; $i++) { Start-Sleep -Seconds 3; $left = @(Remove-StagedMod -Copied $enhancedCraft) }
    if ($left) { Write-Host "boot-check: could not remove EnhancedCraft files; delete them by hand: $($left -join ', ')" -ForegroundColor Yellow }
    else { Write-Host "boot-check: EnhancedCraft removed ($($enhancedCraft.Files.Count) files)" }
  }
}

# Every log written during this run, keeping its path relative to the game folder. CET appends
# every run to the same logs; their copies keep only this run's lines (Select-RunLogLines).
$logs = @(foreach ($root in 'r6\logs', 'red4ext', 'bin\x64\plugins\cyber_engine_tweaks') {
  Get-ChildItem -LiteralPath (Join-Path $GamePath $root) -Recurse -File -Filter *.log -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $start }
})
foreach ($l in $logs) {
  $rel = $l.FullName.Substring($GamePath.TrimEnd('\').Length + 1)
  $dst = Join-Path $runDir $rel
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  $runLines = @(Select-RunLogLines -RelativePath $rel -Lines @(Get-Content -LiteralPath $l.FullName) -Since $start.AddSeconds(-2))
  Set-Content -LiteralPath $dst -Value $runLines -Encoding utf8
}

$redscriptLog = Join-Path $runDir 'r6\logs\redscript_rCURRENT.log'
if ($ConsoleMode) {
  if (Test-Path -LiteralPath $redscriptLog) { $problems += 'console mode: redscript ran (it should be out of the game folder)' }
} elseif (-not (Test-Path -LiteralPath $redscriptLog)) {
  $problems += 'redscript did not run (no redscript_rCURRENT.log written)'
} else {
  $text = @(Get-Content -LiteralPath $redscriptLog)
  if (-not ($text -match 'Compilation complete')) { $problems += 'redscript: no "Compilation complete" line' }
  foreach ($e in ($text -match '^\[ERROR')) { $problems += "redscript: $e" }
}
# The copies hold only this run's lines already.
function Get-RunLines([IO.FileInfo]$log) { return @(Get-Content -LiteralPath $log.FullName) }
foreach ($l in (Get-ChildItem -LiteralPath $runDir -Recurse -File -Filter *.log)) {
  if ($l.Name -eq 'redscript_rCURRENT.log') { continue }
  foreach ($line in (@(Get-RunLines $l) -match '\[(error|critical)\s*\]')) {
    $problems += "$($l.Name): $($line.Trim())"
  }
}

# Dependency check: every enabled pin loaded at its pinned version, no disabled pin loaded.
$red4extLog = Get-ChildItem -LiteralPath (Join-Path $runDir 'red4ext\logs') -Filter 'red4ext-*.log' -ErrorAction SilentlyContinue |
  Sort-Object Name | Select-Object -Last 1
$cetLog = Get-Item -LiteralPath (Join-Path $runDir 'bin\x64\plugins\cyber_engine_tweaks\cyber_engine_tweaks.log') -ErrorAction SilentlyContinue
$pins = @($allPins | Where-Object { $Without -notcontains $_.name })
foreach ($name in $Without) { Write-Host "  ${name}: not checked (-Without)" }
if ($ConsoleMode) { $pins = @($pins | Where-Object name -eq 'CET'); Write-Host '  console mode: only CET checked' }
$redscriptPin = $pins | Where-Object { $_.PSObject.Properties.Name -contains 'bootLog' -and $_.bootLog -eq 'redscript' } | Select-Object -First 1
$report = @(Get-BootDependencyReport -Pins $pins `
  -Red4extLog $(if ($red4extLog) { Get-Content -LiteralPath $red4extLog.FullName } else { @() }) `
  -CetLog $(if ($cetLog) { @(Get-RunLines $cetLog) } else { @() }) `
  -RedscriptLog $(if (Test-Path -LiteralPath $redscriptLog) { Get-Content -LiteralPath $redscriptLog } else { @() }) `
  -RedscriptMatchesPin $(if ($redscriptPin) { Test-RedscriptMatchesPin $redscriptPin } else { $null }))
Write-Host 'boot-check: dependencies'
$report | Format-Table Name, Pinned, Found, Status -AutoSize | Out-String -Stream | Where-Object { $_.Trim() } |
  ForEach-Object { Write-Host "  $_" }
$failing = Get-BootDependencyFailingStatuses
foreach ($r in $report) {
  if ($failing -contains $r.Status) { $problems += "dependency $($r.Name): $($r.Status) (pinned $($r.Pinned), found $(if ($r.Found) { $r.Found } else { 'nothing' }))" }
  elseif ($r.Status -eq 'unverified') { Write-Host "  $($r.Name): version not verified (pinned release not in $CacheDir)" -ForegroundColor Yellow }
}

# Dev code output (FTLog/ModLog/Print all land in CET's gamelog.log): PreemDev lines and the
# RedTest summary, which RedTest writes at the main menu.
$gameLog = Get-Item -LiteralPath (Join-Path $runDir 'bin\x64\plugins\cyber_engine_tweaks\gamelog.log') -ErrorAction SilentlyContinue
$gameLines = if ($gameLog) { @(Get-RunLines $gameLog) } else { @() }
foreach ($line in ($gameLines -match $(if ($ConsoleMode) { '\[Preem' } else { '\[PreemDev\]' }))) { Write-Host "boot-check: game log: $($line.Trim())" }
$tests = Get-RedTestResult -Lines $gameLines
if ($tests) {
  Write-Host ("boot-check: RedTest: {0} passed, {1} failed, {2} total" -f $tests.Passed, $tests.Failed, $tests.Total)
  if ($tests.Failed -gt 0) { $problems += "RedTest: $($tests.Failed) failed: $($tests.Failures -join '; ')" }
} elseif ($scriptMods -contains 'RedTest') {
  $problems += 'RedTest is installed but wrote no results'
}
$selfCheck = Get-SelfCheckResult -Lines $gameLines
if ($selfCheck) {
  Write-Host ("boot-check: self-check: {0} passed, {1} failed" -f $selfCheck.Passed, $selfCheck.Failed)
  foreach ($f in $selfCheck.Failures) { $problems += "self-check: $f" }
  foreach ($line in ($gameLines -match '\[PreemCheck\] (info|PASS \w+):')) { Write-Host "boot-check: $($line -replace '^.*\[PreemCheck\] ', 'self-check: ')" }
} elseif ($scriptMods -contains 'PreemDev' -and $scriptMods -contains 'PreemWeaponsmith') {
  $problems += 'self-check: PreemDev and the mod are installed but the self-check wrote no results'
}

if ($save) { Write-Host "boot-check: loaded save $($save.Name) ($($save.Time))" }
Write-Host "boot-check: $($logs.Count) logs saved to $((Resolve-Path -LiteralPath $runDir).Path)"
if ($problems) {
  foreach ($p in $problems) { Write-Host "  $p" -ForegroundColor Red }
  Write-Host 'boot-check: FAILED' -ForegroundColor Red
  exit 1
}
Write-Host 'boot-check: OK' -ForegroundColor Green
exit 0
