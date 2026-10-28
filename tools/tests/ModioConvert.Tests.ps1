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
    Convert @('protected cb func OnInitialize() {') | Should BeExactly 'protected event OnInitialize() {'
  }

  It 'turns -> Type into : Type, also for generic types' {
    Convert @('func Get(id: TweakDBID) -> array<CName> {') |
      Should BeExactly 'function Get(id: TweakDBID) : array<CName> {'
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

  It 'turns ref<T> into T, also nested and inside array<>' {
    Convert @('private let mods: array<ref<PreemMod>>; func F(m: ref<PreemMod>) -> ref<Map<ref<A>>> {}') |
      Should BeExactly 'private let mods: array<PreemMod>; function F(m: PreemMod) : Map<A> {}'
  }

  It 'turns wref<T> into weak<T>' {
    Convert @('let w: wref<inkCompoundWidget>; let a: array<wref<B>>;') |
      Should BeExactly 'let w: weak<inkCompoundWidget>; let a: array<weak<B>>;'
  }

  It 'turns script_ref<T> into ref<T> (by reference)' {
    Convert @('func F(s: script_ref<String>) -> Void {}') | Should BeExactly 'function F(s: ref<String>) : Void {}'
  }

  It 'drops @runtimeProperty lines' {
    Convert @('  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")', '  @runtimeProperty("ModSettings.displayValues", "\"A\",\"B\"")', '  let a: Int32 = 1;') |
      Should BeExactly '  let a: Int32 = 1;'
  }

  It 'gives an event no return type' {
    Convert @('protected cb func OnInitialize() -> Bool {', 'private cb func OnLoad(e: ref<ResourceEvent>) -> Void {', 'cb func OnX() {') |
      Should BeExactly (Lines @('protected event OnInitialize() {', 'private event OnLoad(e: ResourceEvent) {', 'event OnX() {'))
  }

  It 'drops the parentheses of new X()' {
    Convert @('let p: ref<P> = new P(); m = new inkMargin(0.0, 1.0, 0.0, 0.0);') |
      Should BeExactly 'let p: P = new P; m = new inkMargin(0.0, 1.0, 0.0, 0.0);'
  }

  It 'renames event and host, which are keywords there' {
    Convert @('func Trigger(event: CName) -> Void { this.CallCustomCallback(event); }', 'public let event: CName; f.event = n"x";', 'static func Create(host: ref<H>) -> Void { self.host = host; }') |
      Should BeExactly (Lines @("function Trigger(event_: CName) : Void { this.CallCustomCallback(event_); }", "public let event_: CName; f.event_ = 'x';", 'static function Create(host_: H) : Void { self.host_ = host_; }'))
  }

  It 'leaves names that only contain event or host alone' {
    Convert @('let e: ref<ResourceEvent>; let hostName: String; OnEventX(); ghost();') |
      Should BeExactly 'let e: ResourceEvent; let hostName: String; OnEventX(); ghost();'
  }

  It 'turns the [T] array type into array<T>, leaving indexing and array literals alone' {
    Convert @('func F(a: [TweakDBID], m: script_ref<[ref<M>]>) -> [CName] { let x: Int32 = a[0]; let l: array<Int32> = [1, 2]; }') |
      Should BeExactly 'function F(a: array<TweakDBID>, m: ref<array<M>>) : array<CName> { let x: Int32 = a[0]; let l: array<Int32> = [1, 2]; }'
  }

  It 'drops access modifiers after @wrapMethod, @replaceMethod and @addField, keeping final' {
    Convert @('@wrapMethod(A)', 'private final func F() -> Void {}', '@replaceMethod(B) public func G() -> Void {}', '@addField(C)', 'private let x: Int32;') |
      Should BeExactly (Lines @('@wrapMethod(A)', 'final function F() : Void {}', '@replaceMethod(B) function G() : Void {}', '@addField(C)', 'let x: Int32;'))
  }

  It 'keeps access modifiers after @addMethod' {
    Convert @('@addMethod(A) private final func F() -> Void {}') | Should BeExactly '@addMethod(A) private final function F() : Void {}'
  }

  It 'splits a class field with a value into the field and a default' {
    Convert @('public class A extends B {', '  private let e: gamedataWeaponEvolution = gamedataWeaponEvolution.Invalid;', '  let n: CName = n"x";', '}') |
      Should BeExactly (Lines @('public class A extends B {', '  private let e: gamedataWeaponEvolution; default e = gamedataWeaponEvolution.Invalid;', "  let n: CName; default n = 'x';", '}'))
  }

  It 'splits a struct field with a value the same way' {
    Convert @('public struct S { let a: Int32 = 3; }') | Should BeExactly 'struct S { let a: Int32; default a = 3; }'
  }

  It 'leaves a local with a value inside a method alone' {
    Convert @('class A {', '  func F() -> Int32 {', '    let e: Int32 = 1;', '    if (e > 0) { let f: Int32 = 2; }', '    return e;', '  }', '}') |
      Should BeExactly (Lines @('class A {', '  function F() : Int32 {', '    let e: Int32 = 1;', '    if (e > 0) { let f: Int32 = 2; }', '    return e;', '  }', '}'))
  }

  It 'is not fooled by braces in strings and comments' {
    Convert @('class A {', '  func F() -> Void { let s: String = "}"; } // }', '  let b: Bool = true;', '}') |
      Should BeExactly (Lines @('class A {', '  function F() : Void { let s: String = "}"; } // }', '  let b: Bool; default b = true;', '}'))
  }

  It 'keeps CRLF line ends' {
    Convert-ModioSource -Text "module A`r`nfunc F() -> Void {}`r`n" | Should BeExactly "function F() : Void {}`r`n"
  }
}
