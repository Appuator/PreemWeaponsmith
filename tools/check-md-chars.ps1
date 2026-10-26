<#
.SYNOPSIS
  Rejects tab and other control characters in the repo's Markdown files.

.DESCRIPTION
  Checks every tracked *.md file (working copy), or with -Staged the staged version of each
  staged *.md file (what the commit will contain). Prints file:line:column and the character
  code for each hit. Rules in tools/SourceLint.psm1 (Find-ControlChar). The pre-commit hook
  tools/hooks/pre-commit runs it with -Staged; enable the hook once per clone with
  `git config core.hooksPath tools/hooks`.

  Exit code 0 = clean, 1 = control characters found.

.EXAMPLE
  pwsh tools/check-md-chars.ps1
  pwsh tools/check-md-chars.ps1 -Staged
#>
[CmdletBinding()]
param([switch]$Staged)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3
Import-Module (Join-Path $PSScriptRoot 'SourceLint.psm1') -Force
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path

# Raw bytes of git's stdout, decoded as UTF-8, so a lone CR or other control byte survives
# (PowerShell's native-command pipe splits and re-joins lines).
function Get-GitText([string[]]$GitArgs) {
  $psi = New-Object System.Diagnostics.ProcessStartInfo 'git'
  foreach ($a in @('-C', $repo) + $GitArgs) { $psi.ArgumentList.Add($a) }
  $psi.RedirectStandardOutput = $true
  $psi.UseShellExecute = $false
  $p = [System.Diagnostics.Process]::Start($psi)
  $ms = New-Object System.IO.MemoryStream
  $p.StandardOutput.BaseStream.CopyTo($ms)
  $p.WaitForExit()
  if ($p.ExitCode -ne 0) { throw "git $($GitArgs -join ' ') failed ($($p.ExitCode))" }
  [Text.Encoding]::UTF8.GetString($ms.ToArray())
}

$list = if ($Staged) { Get-GitText @('diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z', '--', '*.md') }
        else { Get-GitText @('ls-files', '-z', '--', '*.md') }
$files = @($list.Split([char]0) | Where-Object { $_ })

$bad = 0
foreach ($f in $files) {
  $text = if ($Staged) { Get-GitText @('cat-file', 'blob', ":$f") }
          else { [IO.File]::ReadAllText((Join-Path $repo $f), [Text.Encoding]::UTF8) }
  foreach ($h in @(Find-ControlChar -Text $text)) {
    Write-Host "${f}:$($h.Line):$($h.Column): control character $($h.Code)" -ForegroundColor Red
    $bad++
  }
}
if ($bad) {
  Write-Host "check-md-chars: $bad control character(s) in Markdown$(if ($Staged) { ' (staged)' }). Replace tabs with spaces; check escapes like \t or \x in the edit that wrote them." -ForegroundColor Red
  exit 1
}
Write-Host "check-md-chars: OK ($($files.Count) file(s)$(if ($Staged) { ' staged' }))"
exit 0
