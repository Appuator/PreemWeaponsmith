# ADR 0003: The mod.io build is converted from the PC source, never edited on its own

- Status: accepted (2026-10-28, planning Phase 9)

## Context
Until now the mod was PC / Nexus only (decision 2026-10-25), because console mods couldn't run scripts. Patch 2.5 lets mod.io mods ship scripts, but they're compiled by CDPR's own compiler (`<game>\tools\redmod\bin\scc.exe`), not redscript. A first compile of 2.5.0 failed every file (`notes/modio-port.md`):
- **Syntax:** the official compiler uses the game's own script syntax (`function`, `event`, `var x : T`, `: Type`, `weak<>`, no modules, no string escapes).
- **Frameworks:** there is no native code on console. That rules out the Codeware UI classes, TweakXL's `TweakDBManager`/`ScriptableTweak`, and Mod Settings.

The user wants to try a console port, but keep the PC files as the ones features and fixes go into. The options were:
- **A hand-maintained fork:** every change made twice, and the copies drift apart.
- **Rewriting the main source in the official syntax:** that would drop redscript, Codeware and the PC tooling (compile check, RedTest, Nexus build).
- **A converter:** generate the console build from the PC source.

## Decision
(user, 2026-10-28) The PC source (`src/redscript/PreemWeaponsmith/`, `tweaks/`) stays the only place features and fixes are made. The mod.io build is generated from it:
- `modio/` holds only what the PC source can't supply. A manifest says which source files convert as they are, which are PC only and left out, and which have a hand-written console stand-in in `modio/overrides/`. It also holds the baked records (below).
- `tools/modio-build.ps1` (PowerShell, like the rest of the tooling, with Pester tests per rewrite rule) converts the syntax and assembles the build in `stage/modio/`, which is generated and ignored by git. `tools/modio-compile-check.ps1` compiles it with the official compiler; it's to this build what `compile-check.ps1` is to the PC build.
- Where a redscript form can't be converted mechanically (an inferred `let` type, `\"` in a string), the PC source gives up that form, and a lint rule in `tools/SourceLint.psm1` keeps it out. These are the "convertible subset" rules.
- Records that `Tweaking/` builds at load are baked into static YAML from a PC run's record dump. They're committed under `modio/`, because making them needs the game.
- The Nexus build is unchanged and still the main release. The console build doesn't hold up a PC release.

## Consequences
- A PC change can break the console build without anyone noticing. The mod.io compile check catches the syntax and type side; `/phase-end` runs it once the converter exists.
- The PC source gets a few style rules it didn't have before (explicit `let` types, no string escapes). They're enforced by lint, so they cost nothing to remember.
- The console UI and the sound fills have no mechanical path. They need their own design (Phase 9 spikes). Until then, the console build may ship without a crafting screen, or not ship at all.
- Overrides in `modio/overrides/` can drift from the PC files they stand in for. Keep them few and small, and list in the manifest which PC file each one follows.
- Baked YAML goes stale whenever `Tweaking/` or the game's weapon records change. Re-bake it on every tweak-data change and every game patch (`docs/PATCH-UPGRADE.md`).
