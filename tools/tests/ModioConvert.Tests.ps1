# Pester 3.4. One case per rewrite rule of the mod.io converter (ADR 0003, notes/modio-port.md).
# Inputs are small hand-written redscript snippets; expected outputs written by hand in the
# official compiler's syntax (the game's own sources in <game>\tools\redmod\scripts).
Import-Module (Join-Path $PSScriptRoot '..\ModioConvert.psm1') -Force

function Convert([string[]]$Lines) { Convert-ModioSource -Text ($Lines -join "`n") }
function Lines([string[]]$Lines) { $Lines -join "`n" }

Describe 'Convert-ModioSource' {
  It 'drops module and import lines' {
    Convert @('module PreemCrafting.PreemUI', 'import Codeware.UI.*', 'import PreemCrafting.Core.*', '', 'public class A {}') |
      Should BeExactly (Lines @('', 'public class A {}'))
  }

  It 'keeps a line that only mentions module or import later on' {
    Convert @('  let importance: Int32 = 1; // module order') |
      Should BeExactly (Lines @('  let importance: Int32 = 1; // module order'))
  }

  It 'turns func into function' {
    Convert @('public static func Make() -> Void {}') | Should BeExactly 'public static function Make() : Void {}'
  }

  It 'turns cb func into event' {
    Convert @('protected cb func OnInitialize() -> Bool {') | Should BeExactly 'protected event OnInitialize() : Bool {'
  }

  It 'turns -> Type into : Type, also for generic types' {
    Convert @('func Get(id: TweakDBID) -> array<ref<PreemMod>> {') |
      Should BeExactly 'function Get(id: TweakDBID) : array<ref<PreemMod>> {'
  }

  It 'turns n"Name" into a single-quoted name' {
    Convert @('LogChannel(n"DEBUG", "x");') | Should BeExactly "LogChannel('DEBUG', `"x`");"
  }

  It 'turns t"Rec.Id" into T"Rec.Id"' {
    Convert @('let id: TweakDBID = t"AttachmentSlots.PreemBarrelMod01";') |
      Should BeExactly 'let id: TweakDBID = T"AttachmentSlots.PreemBarrelMod01";'
  }

  It 'turns public struct into struct' {
    Convert @('public struct PreemSoundFill {') | Should BeExactly 'struct PreemSoundFill {'
  }

  It 'leaves strings and comments alone' {
    Convert @('let s: String = "cb func -> public struct"; // cb func -> t"y"', '/* func', 'n"x" -> */') |
      Should BeExactly (Lines @('let s: String = "cb func -> public struct"; // cb func -> t"y"', '/* func', 'n"x" -> */'))
  }

  It 'leaves a name that only contains func alone' {
    Convert @('let funcName: CName = n"x"; DoFunc();') | Should BeExactly "let funcName: CName = 'x'; DoFunc();"
  }

  It 'keeps CRLF line ends' {
    Convert-ModioSource -Text "module A`r`nfunc F() -> Void {}`r`n" | Should BeExactly "function F() : Void {}`r`n"
  }
}
