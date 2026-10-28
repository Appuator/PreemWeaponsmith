# The mod.io converter: rewrites redscript source into the syntax of CDPR's official script compiler
# (ADR 0003; the syntax table is in notes/modio-port.md). Pure text in, text out; tools/modio-build.ps1
# runs it on every file the manifest marks "convert".
#
# Code is split into segments first (comments, string literals with their n/t/s/r prefix, and
# code), so the code rules never touch the inside of a string or a comment. Each rule has a Pester
# case in tools/tests/ModioConvert.Tests.ps1.
# Not handled yet: s"..." interpolation and r"..." paths stay as they are.

# Comment, prefixed or plain string literal, or a run of other code.
# A code run stops before a comment and before a string with its prefix letter.
$script:segment = [regex]'(?<comment>//[^\r\n]*|/\*[\s\S]*?\*/)|(?<string>[ntsr]?"(?:\\.|[^"\\\r\n])*")|(?<code>(?:(?![ntsr]?"|//|/\*)[\s\S])+)'

function Convert-ModioCode([string]$Code) {
  $Code = [regex]::Replace($Code, '\bcb\s+func\b', 'event')
  $Code = [regex]::Replace($Code, '\bfunc\b', 'function')
  $Code = $Code.Replace('->', ':')
  [regex]::Replace($Code, '\bpublic\s+struct\b', 'struct')
}

function Convert-ModioString([string]$Literal) {
  if ($Literal.StartsWith('n"')) { return "'" + $Literal.Substring(2, $Literal.Length - 3) + "'" }
  if ($Literal.StartsWith('t"')) { return 'T' + $Literal.Substring(1) }
  $Literal
}

function Convert-ModioSource {
  param([string]$Text)
  # module/import lines go with their line end.
  $Text = [regex]::Replace($Text, '(?m)^[ \t]*(?:module|import)[ \t]+[^\r\n]*(?:\r?\n|$)', '')
  $out = New-Object System.Text.StringBuilder
  foreach ($m in $script:segment.Matches($Text)) {
    if ($m.Groups['comment'].Success) { [void]$out.Append($m.Value) }
    elseif ($m.Groups['string'].Success) { [void]$out.Append((Convert-ModioString $m.Value)) }
    else { [void]$out.Append((Convert-ModioCode $m.Value)) }
  }
  $out.ToString()
}

Export-ModuleMember -Function Convert-ModioSource
