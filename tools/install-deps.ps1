<#
.SYNOPSIS
  Installs or updates the game-folder frameworks pinned in docs/DEPENDENCIES.md.

.DESCRIPTION
  Reads the JSON pin block in docs/DEPENDENCIES.md. For each enabled pin it fetches the
  release asset from GitHub (cached in -CacheDir), refuses it unless its SHA256 matches the pin,
  and extracts it into the game folder. A pin is skipped as up to date when every file in its
  asset already matches the game folder byte for byte. Disabled pins are never installed; the
  script only warns if one is found in the game folder. Ends with a table of installed versions.

  Never runs while Cyberpunk 2077 is open. Exit code 0 = everything up to date or installed,
  1 = a pin failed (download, hash or extract) or the game is running.

.EXAMPLE
  pwsh tools/install-deps.ps1 -DryRun
  pwsh tools/install-deps.ps1
  pwsh tools/install-deps.ps1 -Only Codeware,TweakXL -Force
#>
[CmdletBinding()]
param(
  # Game folder; default: REDCLI_GAME (the variable red-cli reads), else the CLAUDE.md folder
  # (tools/GamePath.psm1).
  [string]$GamePath,
  # Where downloaded release assets are kept between runs. Outside the repo.
  [string]$CacheDir = (Join-Path $PSScriptRoot '..\..\downloads\deps-cache'),
  # File holding the pin block.
  [string]$PinFile = (Join-Path $PSScriptRoot '..\docs\DEPENDENCIES.md'),
  # Limit the run to these pin names.
  [string[]]$Only,
  # Reinstall even when the game folder already matches.
  [switch]$Force,
  # Show what would happen; no downloads, no writes.
  [switch]$DryRun,
  # Where release assets come from: <base>/<repo>/releases/download/<tag>/<asset>.
  # An http(s) URL, or a local folder laid out the same way (offline mirror, tests).
  [string]$ReleaseBase = 'https://github.com'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Read-Pins([string]$path) {
  $text = Get-Content -LiteralPath $path -Raw
  $m = [regex]::Match($text, '(?s)<!-- install-deps:begin -->\s*```json\s*(.*?)```\s*<!-- install-deps:end -->')
  if (-not $m.Success) { throw "No install-deps pin block found in $path" }
  return @($m.Groups[1].Value | ConvertFrom-Json)
}

function Get-Prop($obj, [string]$name, $default = '') {
  if ($obj.PSObject.Properties.Name -contains $name) { return $obj.$name }
  return $default
}

function Get-FileSha256([string]$path) {
  return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-StreamSha256([System.IO.Stream]$stream) {
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($sha.ComputeHash($stream)) -replace '-', '').ToLowerInvariant() }
  finally { $sha.Dispose() }
}

function Get-InstalledVersion($pin) {
  $vf = Get-Prop $pin 'versionFile'
  if (-not $vf) { return $null }
  $full = Join-Path $GamePath $vf
  if (-not (Test-Path -LiteralPath $full)) { return $null }
  return (Get-Item -LiteralPath $full).VersionInfo.FileVersion
}

# True when every file the asset would write already exists in the game folder with the same bytes.
function Test-AssetMatchesGame($pin, [string]$assetPath) {
  $target = Get-Prop $pin 'target'
  if ($target) {
    $dest = Join-Path $GamePath $target
    return (Test-Path -LiteralPath $dest) -and ((Get-FileSha256 $dest) -eq (Get-FileSha256 $assetPath))
  }
  $zip = [System.IO.Compression.ZipFile]::OpenRead($assetPath)
  try {
    foreach ($entry in $zip.Entries) {
      if ($entry.FullName.EndsWith('/')) { continue }
      $dest = Join-Path $GamePath $entry.FullName
      if (-not (Test-Path -LiteralPath $dest)) { return $false }
      if ((Get-Item -LiteralPath $dest).Length -ne $entry.Length) { return $false }
      $s = $entry.Open()
      try { $entryHash = Get-StreamSha256 $s } finally { $s.Dispose() }
      if ($entryHash -ne (Get-FileSha256 $dest)) { return $false }
    }
    return $true
  }
  finally { $zip.Dispose() }
}

# Returns the cached asset path, downloading it if needed. Throws on a hash mismatch.
function Get-Asset($pin) {
  $path = Join-Path $CacheDir $pin.asset
  if (Test-Path -LiteralPath $path) {
    if ((Get-FileSha256 $path) -eq $pin.sha256) { return $path }
    Write-Warning "$($pin.name): cached $($pin.asset) does not match the pinned SHA256; downloading again."
    Remove-Item -LiteralPath $path -Force
  }
  $url = "$ReleaseBase/$($pin.repo)/releases/download/$($pin.tag)/$($pin.asset)"
  Write-Host "  downloading $url"
  $tmp = "$path.part"
  if ($ReleaseBase -match '^https?://') { Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing }
  else { Copy-Item -LiteralPath $url -Destination $tmp -Force }
  $got = Get-FileSha256 $tmp
  if ($got -ne $pin.sha256) {
    Remove-Item -LiteralPath $tmp -Force
    throw "SHA256 mismatch for $($pin.asset) (got $got, pinned $($pin.sha256)). File deleted."
  }
  Move-Item -LiteralPath $tmp -Destination $path -Force
  return $path
}

function Install-Asset($pin, [string]$assetPath) {
  $target = Get-Prop $pin 'target'
  if ($target) {
    $dest = Join-Path $GamePath $target
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item -LiteralPath $assetPath -Destination $dest -Force
  }
  else {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($assetPath, $GamePath, $true)
  }
}

# --- checks ---
Import-Module (Join-Path $PSScriptRoot 'GamePath.psm1') -Force
$game = Resolve-GamePath -GamePath $GamePath -EnvValue $env:REDCLI_GAME
$GamePath = $game.Path
if ($game.Note) { Write-Host "install-deps: $($game.Note)" }
if (-not (Test-Path -LiteralPath (Join-Path $GamePath 'bin\x64\Cyberpunk2077.exe'))) {
  Write-Error "Not a Cyberpunk 2077 folder: $GamePath"; exit 1
}
if (Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue) {
  Write-Error 'Cyberpunk 2077 is running. Close the game first; installing into a running game corrupts files.'; exit 1
}

$pins = Read-Pins $PinFile
if ($Only) {
  $unknown = $Only | Where-Object { $_ -notin $pins.name }
  if ($unknown) { Write-Error "Unknown pin name(s): $($unknown -join ', ')"; exit 1 }
  $pins = @($pins | Where-Object { $_.name -in $Only })
}
if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null }

Write-Host "Game:  $GamePath"
Write-Host "Cache: $([System.IO.Path]::GetFullPath($CacheDir))"
if ($DryRun) { Write-Host 'Dry run: nothing is downloaded or written.' }

# --- install ---
$failed = $false
$results = foreach ($pin in $pins) {
  $status = ''
  if (-not $pin.enabled) {
    $marker = Get-Prop $pin 'target'
    if (-not $marker) { $marker = Get-Prop $pin 'versionFile' }
    $present = $marker -and (Test-Path -LiteralPath (Join-Path $GamePath $marker))
    $status = if ($present) { 'DISABLED BUT PRESENT: remove it' } else { 'disabled' }
    if ($present) { Write-Warning "$($pin.name) is disabled ($(Get-Prop $pin 'note')) but found in the game folder." }
  }
  else {
    Write-Host "$($pin.name) $($pin.tag)"
    try {
      $cached = Join-Path $CacheDir $pin.asset
      $haveCache = (Test-Path -LiteralPath $cached) -and ((Get-FileSha256 $cached) -eq $pin.sha256)
      if ($DryRun) {
        if (-not $haveCache) { $status = 'would download + install' }
        elseif (-not $Force -and (Test-AssetMatchesGame $pin $cached)) { $status = 'up to date' }
        else { $status = 'would install' }
      }
      else {
        $asset = Get-Asset $pin
        if (-not $Force -and (Test-AssetMatchesGame $pin $asset)) { $status = 'up to date' }
        else {
          Install-Asset $pin $asset
          if (-not (Test-AssetMatchesGame $pin $asset)) { throw 'files in the game folder differ from the asset after extracting' }
          $status = 'installed'
        }
      }
    }
    catch {
      $failed = $true
      $status = "FAILED: $($_.Exception.Message)"
      Write-Warning "$($pin.name): $($_.Exception.Message)"
    }
  }
  $installed = Get-InstalledVersion $pin
  [pscustomobject]@{
    Name      = $pin.name
    Pinned    = $pin.version
    Installed = if ($installed) { $installed } elseif (Get-Prop $pin 'versionFile') { '-' } else { '(no version resource)' }
    Match     = if ($installed) { $installed.StartsWith($pin.version) } else { '' }
    Status    = $status
  }
}

$results | Format-Table -AutoSize | Out-String -Width 200 | Write-Host
if ($failed) { exit 1 }
exit 0
