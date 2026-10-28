# mod.io port

Scratchpad for the console / mod.io build (Phase 9). The decision is in [ADR 0003](../docs/adr/0003-modio-build-derived-from-pc-source.md).

## What mod.io accepts (patch 2.5, read 2026-10-28)
Sources: mod.io guides "How-to: Create Mods for Cross-Platform Mod Support" and "Mod Content available in Cross-Platform Mod Support".
- **Scripts**: precompiled by mod.io's cloud cook with CDPR's own compiler. A blacklist of engine functions that must not run on console fails the compile. `@wrapMethod`, `@addMethod`, `@replaceMethod` and `@addField` are listed as supported. No string interpolation. A few math functions are missing (`IsInRange`, `RoundMath`, the angle helpers).
- **TweakDB**: TweakXL-style YAML only. Supported: new records with new flats, cloning (`$base`), modifying flats, extra flats on existing records. Not supported: binary tweaks, new enums ("later"). Appending to lists (`!append`, `!append-from`) isn't mentioned either way.
- **Archives**: most resource types are fine, including `.inkwidget`, `.inkatlas`, `.inkstyle`. PC only: `.ent`, `.app`, `.morphtarget`, `.particle`, physics.
- **No native code**: RED4ext plugins (Codeware, TweakXL's scripting API, Mod Settings) don't exist on console.
- **Local test on PC**: compile with `redMod.exe validate-mod-scripts`, copy the resulting `final.redscripts` into `<game>\r6\c77` (renaming it is optional) and launch with `-LoadScriptMods`.

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
| `wrappedMethod(...)` | **"Could not find valid function 'wrappedMethod'"**, also through `redMod.exe validate-mod-scripts`, also when wrapping a game method (`CraftingSystem.UpgradeItem`). `super.UpgradeItem(...)` fails the same way. Calling the method by its own name compiles. Decompiled, the wrapper becomes a patch function `UpgradeItem__annot__1_M_<hash>_ID_0` whose body calls `UpgradeItem(owner, itemID)`. The compiler has strings `##original` and "Skipped SetSuperFunction for '%hs' due to mods annotations", so the engine likely renames the original and binds that call to it at load. Not proven | **likely built later as `wrappedMethod(` to `<method name>(`**; prove it at run time in the console-mode boot task first |
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

## What can't be converted
- **Codeware UI**: `inkCustomController`, `CustomPopup`, `CustomButton` and the rest of `Codeware.UI`. The whole `PreemMainUI/` folder. A console UI is new work (spike task). The game does ship Codeware's `CallbackSystem` and `ScriptableService` as official classes (`<game>\tools\redmod\scripts\mods\codeware`).
- **Records made at load**: `Tweaking/` (`ScriptableTweak`, `TweakDBManager`) builds the `_Preem<Evolution>` variants and other records per weapon. On console they have to ship as static YAML. Idea: generate that YAML from a PC run's record dump, so the PC code stays the source.
- **Sound fills** (`Audio/PreemSoundSets`, ADR 0001) patch the loaded sound metadata through Codeware. Without them, fire modes that borrow sounds are silent or play the wrong shot. Unknown whether YAML or an archive can do it on console.
- **Settings**: the per-save settings store is plain script, but its panel is Codeware UI. Mod Settings is PC only.

## Open questions
- **How does a wrapper call the original method?** There is no `wrappedMethod()` and no `super.<method>()`. Calling the method by its own name compiles, and the compiled patch function calls the method by name, which points to the engine routing it to the original at load. Not a tooling mismatch: REDmod is 2.5.0.0, installed with patch 2.5 (`redMod.exe` and `scc.exe` dated 2026-10-25 13:16, as the game exe). The mod.io guide lists `@wrapMethod` as supported but never shows the call. Prove it at run time (console-mode boot task); every Preem hook depends on it.
- Which engine functions does the blacklist reject? This shows up only once the syntax compiles.
- Does `-LoadScriptMods` with `r6\c77` boot cleanly next to RED4ext and redscript, or does it need a clean game folder?
- Are `!append` / `!append-from` accepted by the console YAML loader?
- Can a usable crafting UI be built from plain ink widgets in vanilla script, or from an `.inkwidget` archive?
