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

# ref<T> is a handle in redscript but "by reference" for the official compiler, which rejects it
# inside array<> and as a return type; a plain T is the handle there. Strips each ref<...> wrapper,
# matching nested angle brackets. script_ref<T> is left for the next rule (no word boundary).
function Remove-RefWrapper([string]$Code) {
  while ($true) {
    $m = [regex]::Match($Code, '\bref<')
    if (-not $m.Success) { return $Code }
    $start = $m.Index + $m.Length; $depth = 1; $i = $start
    while ($i -lt $Code.Length -and $depth -gt 0) {
      if ($Code[$i] -eq '<') { $depth++ } elseif ($Code[$i] -eq '>') { $depth-- }
      $i++
    }
    if ($depth -ne 0) { return $Code }  # unbalanced inside this segment: leave it for the compiler to report
    $Code = $Code.Substring(0, $m.Index) + $Code.Substring($start, $i - 1 - $start) + $Code.Substring($i)
  }
}

function Convert-ModioCode([string]$Code) {
  # Names that are keywords for the official compiler, before the converter writes its own "event".
  $Code = [regex]::Replace($Code, '\b(event|host)\b', '${1}_')
  # [T] array type (after ':', '<' or '->'; indexing and array literals never follow those).
  $Code = [regex]::Replace($Code, '(?<=(?:[:<]|->)\s*)\[([^\[\]]+)\]', 'array<$1>')
  $Code = Remove-RefWrapper $Code
  $Code = [regex]::Replace($Code, '\bwref<', 'weak<')
  $Code = [regex]::Replace($Code, '\bscript_ref<', 'ref<')
  # An event returns Bool implicitly and can't declare a return type.
  $Code = [regex]::Replace($Code, '\bcb\s+func(\s+\w+\s*\([^)]*\))\s*->\s*[\w<>]+', 'event$1')
  $Code = [regex]::Replace($Code, '\bcb\s+func\b', 'event')
  $Code = [regex]::Replace($Code, '\bnew\s+(\w+)\s*\(\s*\)', 'new $1')
  # @wrapMethod, @replaceMethod and @addField take no access modifier there (final stays);
  # @addMethod keeps its modifiers.
  $Code = [regex]::Replace($Code, '(@(?:wrapMethod|replaceMethod|addField)\(\w+\)\s*)(?:(?:public|private|protected)\s+)+', '$1')
  $Code = [regex]::Replace($Code, '\bfunc\b', 'function')
  $Code = $Code.Replace('->', ':')
  [regex]::Replace($Code, '\bpublic\s+struct\b', 'struct')
}

function Convert-ModioString([string]$Literal) {
  if ($Literal.StartsWith('n"')) { return "'" + $Literal.Substring(2, $Literal.Length - 3) + "'" }
  if ($Literal.StartsWith('t"')) { return 'T' + $Literal.Substring(1) }
  $Literal
}

# A class or struct field with a value (let x: T = v;) doesn't parse there when the value is an
# enum member; the game's own sources write the value as "default x = v;". Splits every such
# field, on the same line. Runs on converted text: walks it once, skipping comments and string or
# name literals, and keeps a stack of what each open brace belongs to (class/struct body or other).
$script:fieldWithValue = [regex]'(?m)^([ \t]*(?:(?:public|private|protected|persistent|const|native|final)\s+)*let\s+(\w+)\s*:\s*[^=;]+?)\s*=\s*([\s\S]+)$'

function Split-FieldValue([string]$Text) {
  $edits = New-Object System.Collections.Generic.List[object]
  $stack = New-Object System.Collections.Generic.List[string]
  $stmtStart = 0; $i = 0; $n = $Text.Length
  while ($i -lt $n) {
    $c = $Text[$i]
    if ($c -eq '/' -and $i + 1 -lt $n -and $Text[$i + 1] -eq '/') { $j = $Text.IndexOf("`n", $i); $i = if ($j -lt 0) { $n } else { $j }; continue }
    if ($c -eq '/' -and $i + 1 -lt $n -and $Text[$i + 1] -eq '*') { $j = $Text.IndexOf('*/', $i + 2); $i = if ($j -lt 0) { $n } else { $j + 2 }; continue }
    if ($c -eq '"' -or $c -eq "'") {
      $i++
      while ($i -lt $n -and $Text[$i] -ne $c) { if ($Text[$i] -eq '\') { $i++ }; $i++ }
      $i++; continue
    }
    if ($c -eq '{') {
      $header = $Text.Substring($stmtStart, $i - $stmtStart)
      $kind = if ($header -match '\b(class|struct)\s+\w+' -and $header -notmatch '\(') { 'type' } else { 'block' }
      $stack.Add($kind); $stmtStart = $i + 1
    } elseif ($c -eq '}') {
      if ($stack.Count) { $stack.RemoveAt($stack.Count - 1) }
      $stmtStart = $i + 1
    } elseif ($c -eq ';') {
      if ($stack.Count -and $stack[$stack.Count - 1] -eq 'type') {
        $stmt = $Text.Substring($stmtStart, $i - $stmtStart)
        $m = $script:fieldWithValue.Match($stmt)
        if ($m.Success) {
          $at = $stmtStart + $m.Index
          $edits.Add(@($at, $m.Length, ('{0}; default {1} = {2}' -f $m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value)))
        }
      }
      $stmtStart = $i + 1
    }
    $i++
  }
  for ($k = $edits.Count - 1; $k -ge 0; $k--) {
    $e = $edits[$k]
    $Text = $Text.Substring(0, $e[0]) + $e[2] + $Text.Substring($e[0] + $e[1])
  }
  $Text
}

function Convert-ModioSource {
  param([string]$Text)
  # module/import lines and @runtimeProperty lines (Mod Settings is PC only) go with their line end.
  $Text = [regex]::Replace($Text, '(?m)^[ \t]*(?:module[ \t]|import[ \t]|@runtimeProperty\()[^\r\n]*(?:\r?\n|$)', '')
  $out = New-Object System.Text.StringBuilder
  foreach ($m in $script:segment.Matches($Text)) {
    if ($m.Groups['comment'].Success) { [void]$out.Append($m.Value) }
    elseif ($m.Groups['string'].Success) { [void]$out.Append((Convert-ModioString $m.Value)) }
    else { [void]$out.Append((Convert-ModioCode $m.Value)) }
  }
  Split-FieldValue $out.ToString()
}

Export-ModuleMember -Function Convert-ModioSource
