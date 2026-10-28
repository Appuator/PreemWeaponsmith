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
From the compile errors and the game's own sources in `<game>\tools\redmod\scripts`.

| redscript (this mod) | official compiler | Mechanical? |
|---|---|---|
| `module X` / `import X.*` | none (one namespace) | yes: drop the lines; names must stay unique across the mod |
| `func` | `function` | yes |
| `cb func OnX()` | `event OnX()` | yes |
| `-> Type` | `: Type` | yes |
| `wref<T>` | `weak< T >` | yes |
| `ref<T>` (a handle) | `T` (`ref< T >` means by reference) | yes |
| `script_ref<T>` / `out` parameters | `ref< T >` / `out` | check per case |
| `let x: T = v;` (local) | `var x : T;` then `x = v;` | yes |
| `let x = v;` (local, type inferred) | needs the type written out | **no**: the converter can't infer types, so the source has to write them |
| `let x: T = v;` (field) | `var x : T;` plus `default x = v;` | yes |
| `n"Name"` | `'Name'` | yes |
| `t"Rec.Id"` | `T"Rec.Id"` | yes |
| `"a \"b\" c\n"` | no escapes in the game's sources | **no**: the source should avoid them (use `'` quotes; build line breaks some other way) |
| `public struct` | `struct` | yes |
| `@runtimeProperty`, `@if(...)` | none | drop (Mod Settings and EnhancedCraft are PC only) |
| `s"... \(x) ..."` interpolation | none | **no**: used in `FTLog` lines and commented-out debug logs (9 files); build the string with `+` or drop the log |
| `r"base\\..."` resource path | unknown | check when the files that use it convert (`PreemSoundSets`, `BasePreemButton`) |
| a name that is a keyword there: `event`, `host` | rename | yes: rename the identifier everywhere in code (`Trigger(event: CName)` in three UI classes, `PreemSoundFill.event`, `PreemSlotFrame.Create(host: ...)`). Found by the converter's first rules, 2026-10-28 |

## What can't be converted
- **Codeware UI**: `inkCustomController`, `CustomPopup`, `CustomButton` and the rest of `Codeware.UI`. The whole `PreemMainUI/` folder. A console UI is new work (spike task). The game does ship Codeware's `CallbackSystem` and `ScriptableService` as official classes (`<game>\tools\redmod\scripts\mods\codeware`).
- **Records made at load**: `Tweaking/` (`ScriptableTweak`, `TweakDBManager`) builds the `_Preem<Evolution>` variants and other records per weapon. On console they have to ship as static YAML. Idea: generate that YAML from a PC run's record dump, so the PC code stays the source.
- **Sound fills** (`Audio/PreemSoundSets`, ADR 0001) patch the loaded sound metadata through Codeware. Without them, fire modes that borrow sounds are silent or play the wrong shot. Unknown whether YAML or an archive can do it on console.
- **Settings**: the per-save settings store is plain script, but its panel is Codeware UI. Mod Settings is PC only.

## Open questions
- Which engine functions does the blacklist reject? This shows up only once the syntax compiles.
- Does `-LoadScriptMods` with `r6\c77` boot cleanly next to RED4ext and redscript, or does it need a clean game folder?
- Are `!append` / `!append-from` accepted by the console YAML loader?
- Can a usable crafting UI be built from plain ink widgets in vanilla script, or from an `.inkwidget` archive?
