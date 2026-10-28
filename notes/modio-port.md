# mod.io port

Scratchpad for the console / mod.io build (Phase 9). The decision is in [ADR 0003](../docs/adr/0003-modio-build-derived-from-pc-source.md).

## What mod.io accepts (patch 2.5, read 2026-10-28)
Sources: mod.io guides "How-to: Create Mods for Cross-Platform Mod Support" and "Mod Content available in Cross-Platform Mod Support".
- **Scripts**: precompiled by mod.io's cloud cook with CDPR's own compiler. A blacklist of engine functions that must not run on console fails the compile. `@wrapMethod`, `@addMethod`, `@replaceMethod` and `@addField` are listed as supported. No string interpolation. A few math functions are missing (`IsInRange`, `RoundMath`, the angle helpers).
- **TweakDB**: TweakXL-style YAML only. Supported: new records with new flats, cloning (`$base`), modifying flats, extra flats on existing records. Not supported: binary tweaks, new enums ("later"). Appending to lists (`!append`, `!append-from`) isn't mentioned either way.
- **Archives**: most resource types are fine, including `.inkwidget`, `.inkatlas`, `.inkstyle`. PC only: `.ent`, `.app`, `.morphtarget`, `.particle`, physics.
- **No native code**: RED4ext plugins (Codeware, TweakXL's scripting API, Mod Settings) don't exist on console.
- **Local test on PC**: compile with `redMod.exe validate-mod-scripts`, copy the resulting `final.redscripts` into `<game>\r6\c77` (renaming it is optional) and launch with `-LoadScriptMods`. That didn't load anything for us; the layout that works is in "Run-time results" below.

## redscript PR #207 (read 2026-10-28)
[jac3km4/redscript#207](https://github.com/jac3km4/redscript/pull/207), a draft by Roms1383: `redscript-cli convert` rewrites `.reds` into `.script` with redscript's own parser and type checker (it fills in the types of untyped `let` locals), and warns about what REDmod can't do. Its guide `REDSCRIPT_TO_REDMOD_CONVERSION.md` corrects or adds to the table below:
- `\n` works; only `\"` fails (`\u{22}` replaces it). `r"..."` becomes `R"..."`, `opt` becomes `optional`, `null` becomes `NULL`.
- `@module "X"` / `@using` and `@if(ModuleExists(...))` exist, with limits.
- `name` is also reserved. `@addMethod` should lose its access modifier too. Overriding a base-class method needs `override`. `-> T`, `wref<T>` and `script_ref<T>` are accepted as they are.
- Persistent storage: `ModdingSystem` fields added with `@addField` are saved in `EnabledMods.json` (`mods_config`).
- Known REDmod run-time bugs reported to CDPR: `@replaceMethod` skipped by callers in the same class; a wrapper sometimes runs twice; repeated script calls reach a patch only once (reproduced here); a crash when a cast-produced enum returned directly is discarded.
- Building it needs a Rust toolchain (not installed here). Re-planning Phase 9 around it is still open.

## First compile against the official compiler (2026-10-28)
Compiler: `<game>\tools\redmod\bin\scc.exe`, "REDscript Compiler v1.2.2" (CDPR), run as `scc.exe -compile <scriptsDir> <out.redscripts> -optionalPrecompiledBlobPath <vanilla final.redscripts>`. Add `-threads 1` to stop log lines from different files interleaving.
- `redMod.exe validate-mod-scripts` reads only `.script` files. With `.reds` files it reports success without compiling anything, and on failure it prints no errors. Run `scc.exe` directly to see them.
- Pass 1, the 2.5.0 source renamed to `.script`: 63 errors, all syntax. Every file fails on its first line (`module`).
- Pass 2, after mechanical fixes (drop `module`/`import`/`@runtimeProperty`/`@if` lines, `func` to `function`, strip `\"` and `\n`): 46 errors. These are the next layer of syntax (below) plus `Unknown base class` for `inkCustomController` (4), `CustomPopup` and `CustomButton`.

## redscript to official syntax
From the compile errors, the game's own sources in `<game>\tools\redmod\scripts`, and one-line probes: a scratch `.script` file compiled with `scc.exe` (2026-10-28, "Converter, declarations and types"). "Built" = the converter does it (`tools/ModioConvert.psm1`).

| redscript (this mod) | official compiler | Mechanical? |
|---|---|---|
| `module X` / `import X.*` | none (one namespace) | built: drop the lines; names must stay unique across the mod |
| `func` | `function` | built |
| `cb func OnX() -> Bool` | `event OnX()`: an event returns Bool implicitly and can't declare a return type | built |
| `-> Type` | `: Type` | built |
| `wref<T>` | accepted as it is; `weak<T>` is the game's own form | built: `weak<T>` |
| `ref<T>` (a handle) | `T`. `ref<T>` there means "by reference": rejected inside `array<>` and as a return type | built |
| `script_ref<T>` | `ref<T>` | built |
| `[T]` (array type) | `array<T>` | built (after `:`, `<` or `->` only) |
| `let x: T = v;` (local) | accepted as it is (also `var x : T = v;`) | nothing to do |
| `let x = v;` (local, type inferred) | rejected: "unexpected '=', expecting ':'" | **no**: the converter can't infer types, so the source has to write them |
| `let x: T = v;` (field) | accepted for a literal; rejected when the value is an enum member | built: `let x: T; default x = v;` for every class or struct field with a value |
| `private let` field, modifiers | accepted | nothing to do |
| `new X()` | `new X`; parentheses rejected. `new inkMargin(a, b, c, d)` (struct with values) not checked yet | built for `()` |
| `@wrapMethod(C) public final func` | no access modifier after `@wrapMethod`, `@replaceMethod` or `@addField` (`final` is fine). `@addMethod` keeps them | built |
| `wrappedMethod(...)` | the method's own name: `GetAuthorizeUserClearance()` inside its `@wrapMethod` runs the original (**proven at run time 2026-10-28**, see "Run-time results"). `wrappedMethod` and `super.X()` don't compile. Per redscript PR #207, `this.X()` inside the wrapper calls the wrapper itself | to build: `wrappedMethod(` to `<method name>(` |
| a wrapped event, `@wrapMethod(C) cb func OnX() -> Bool` | `@wrapMethod(C) event OnX() : Bool`. Unlike an event declared in a class, a wrapper that returns needs `: Bool` | built wrongly today (the event rule drops it); fix noted under "Converter, intrinsics" |
| `LogChannel(n"X", s)` | "Could not find valid function 'LogChannel'" | check the game's own logging call when a file that logs parses |
| `n"Name"` | `'Name'` | built |
| `t"Rec.Id"` | `T"Rec.Id"` | built |
| `"a \"b\" c\n"` | no escapes in the game's sources | **no**: the source should avoid them (use `'` quotes; build line breaks some other way) |
| `public struct` | `struct` | built |
| `@runtimeProperty` | none | built: drop (Mod Settings is PC only) |
| `@if(...)` | none | not used any more (the EnhancedCraft branch was deleted) |
| `if cond {`, `while cond {` (no parentheses) | `if (cond) {`: rejected without them | yes, not built (~190 places) |
| `for x in arr {` | rejected; needs an index loop | yes, not built (63 places) |
| `IsDefined(x)`, `ArraySize(a)` and the other `Array*` intrinsics, `Equals`/`NotEquals` | "Could not find valid function". The mod.io guide's table: `if (x)`, `a.Size()`, `a.PushBack(...)`, `==`, `!=` | yes, not built (~450 places) |
| `Cast<T>(x)`, `x as T` | not checked yet | check when those files parse |
| `s"... \(x) ..."` interpolation | none | **no**: used in `FTLog` lines and commented-out debug logs (9 files); build the string with `+` or drop the log |
| `r"base\\..."` resource path | unknown | check when the files that use it convert (`PreemSoundSets`, `BasePreemButton`) |
| a name that is a keyword there: `event`, `host` | rename | built: `event_`, `host_` everywhere in code (`Trigger(event: CName)` in three UI classes, `PreemSoundFill.event`, `PreemSlotFrame.Create(host: ...)`) |

## Run-time results (console-mode boot on PC, 2026-10-28)
How to load a local script patch, from the conversion guide in redscript PR #207 (`REDSCRIPT_TO_REDMOD_CONVERSION.md`): copy the **whole compiled mod folder** (`r6\scripts`, `r6\cache`, `about.json`) to `<game>\r6\c77\<ModFolder>` (no period in the name) and launch with `-LoadScriptMods -logScripts`. Loose `final.redscripts` files in `r6\c77` are ignored, which is why the earlier tries never bound. `tools/console-boot.ps1` does this now.
- **Log:** `-logScripts` writes `<game>\ScriptLogger.log`: "Success pre-loading/binding script mod <path>", script errors, and `ScriptLog` lines (declare it with `import function ScriptLog(const text : ref<String>);`). `console-boot` moves it to `logs/` and prints the `[Preem` lines.
- **CET is blind in this mode:** with a c77 script mod loaded, CET's Lua sees no game types (`DefaultActionsParametersHolder` is nil) and no `ObserveAfter`, so the main-menu marker never fires and `boot-check` times out at 300 s although the game is at the menu. Read results from `ScriptLogger.log` instead.
- **Probe** (`dev/modio/wrap-probe`): a `@wrapMethod` on `SingleplayerMenuGameController.OnInitialize` (an event) calls two static game methods three times each and logs the results. `logs/console-boot-2026-10-28_14-47-10-ScriptLogger.log`:
  - the event wrapper ran; `@replaceMethod` ran (7777); the `@wrapMethod` ran and its own-name call returned the original's 9 (1009). **The wrapper question is answered.**
  - **calls 2 and 3 returned 0 for both methods**, and neither patch logged anything: after the first call, a script call to a patched method from script runs neither the patch nor the original. This is the "repeated script calls reach a patch only once" bug in the PR's guide, reproduced. Preem's hooks are called many times per session, so this alone could make the port unworkable until CDPR fixes it.
- **Probe 2** (`logs/console-boot-2026-10-28_14-57-25-ScriptLogger.log`), to pin the bug down. Patched: two `constexpr static` methods (`DefaultActionsParametersHolder`) and two ordinary static ones that read TweakDB (`PlayerStaminaHelpers.GetJumpStaminaCost` replaced to 77, `GetDodgeStaminaCost` wrapped to +1000), plus untouched controls (`GetQuestClearance` = 99; `GetSlideStaminaCost` read 0 every time, so it tells nothing). Results:

  | call | status | authorize | jump | dodge | quest (untouched) |
  |---|---|---|---|---|---|
  | menu `OnInitialize` wrapper, loop 0 | 7777 | 1009 | 77 | 1025 | 99 |
  | loop 1, loop 2 (same call site) | 0 | 0 | 0 | 0 | 99 |
  | a second call site in the same function | 0 | 0 | 0 | 0 | — |
  | from an `@addMethod` helper (not in a wrapper), twice | 0 | 0 | 0 | 0 | 99 |
  | 80 s later, `OnSaveMetadataReady` wrapper (a new engine callback) | 7777 | 1009 | 77 | 1025 | 99 |

  - **Not about `constexpr` and not about the call site:** every patched method, constexpr or not, works on its first call and then returns the type's default (0) without running the patch or the original, from any call site and from any function. Untouched methods are fine on every call.
  - **It resets:** in the next engine callback, each patched method works once again. So it is "once per patched method per entry from the engine into script" (or per frame; this probe can't tell the two apart).
  - **Engine callbacks are fine:** the `OnSaveMetadataReady` wrapper ran when the engine called it (it fired once, for save 0).
  - **What it means for Preem:** any patched game method the game's own script calls twice within one engine callback (a crafting list refresh calling it per item, a loop over inventory, an install followed by a stat read) gets 0/false/null from the second call on, and the original game logic is skipped too. Many of Preem's hooks sit on methods like that, so the port would break vanilla behaviour as well as Preem's, until CDPR fixes this. Not tested: whether a game method that is *not* patched but *calls* a patched one is affected the same way (almost certainly, since the call is a script call).

## What can't be converted
- **Codeware UI**: `inkCustomController`, `CustomPopup`, `CustomButton` and the rest of `Codeware.UI`. The whole `PreemMainUI/` folder. A console UI is new work (spike task). The game does ship Codeware's `CallbackSystem` and `ScriptableService` as official classes (`<game>\tools\redmod\scripts\mods\codeware`).
- **Records made at load**: `Tweaking/` (`ScriptableTweak`, `TweakDBManager`) builds the `_Preem<Evolution>` variants and other records per weapon. On console they have to ship as static YAML. Idea: generate that YAML from a PC run's record dump, so the PC code stays the source.
- **Sound fills** (`Audio/PreemSoundSets`, ADR 0001) patch the loaded sound metadata through Codeware. Without them, fire modes that borrow sounds are silent or play the wrong shot. Unknown whether YAML or an archive can do it on console.
- **Settings**: the per-save settings store is plain script, but its panel is Codeware UI. Mod Settings is PC only.

## Open questions
- **Answered 2026-10-28: how a wrapper calls the original.** By the method's own name ("Run-time results").
- **What a console-mode boot on PC needs:** no RED4ext, no redscript (the game runs `engine\tools\scc.exe` at every start; redscript's version overwrites the vanilla `final.redscripts` when RED4ext is missing), an empty `r6\scripts`, and the mod folder in `r6\c77\<ModFolder>` with `-LoadScriptMods -logScripts`. `tools/console-boot.ps1` sets this up and restores it. Whether RED4ext and redscript really have to go was not retested with the right layout.
- **Repeated calls (see "Run-time results"):** answered: once per patched method per engine callback, any call site. Open: per engine callback or per frame; whether CDPR plans a fix (ask in CDPR's modding Discord, with the probe 2 table).
- Which engine functions does the blacklist reject? This shows up only once the syntax compiles.
- Does `-LoadScriptMods` with `r6\c77` boot cleanly next to RED4ext and redscript, or does it need a clean game folder?
- Are `!append` / `!append-from` accepted by the console YAML loader?
- Can a usable crafting UI be built from plain ink widgets in vanilla script, or from an `.inkwidget` archive?
