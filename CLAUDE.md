# Preem Weaponsmith — Claude rules

Read at session start: `ROADMAP.md` (next task + rules), `HANDOFF.md` (architecture, bugs, gotchas). Design: `SPEC.md` (what the mod is; its status table says what is built). Toolchain background: `docs/MODDING-WORKFLOW.md`; game hook list: `docs/HOOKS.md`. Read a `notes/*.md` file only when a task points to it; `SPEC.md` wins on conflicts. Use the terms in `GLOSSARY.md`; before changing an area, check `docs/adr/` for decisions that cover it.

## How to help
The user wrote this mod and knows redscript hooks (`@wrapMethod`, `@addMethod`, `@addField`) and their own code. They are less sure how the game's own code is meant to work. When a task touches game classes, explain briefly:
- what the vanilla method does, and where it is called from;
- the game's conventions: TweakDB records vs `gameItemData`, `ItemID`, `TransactionSystem`/`ItemModificationSystem`, ink controllers and widget lifetimes, `ScriptableSystem`/`ScriptableTweak` timing;
- tool and engine details (what redscript, Codeware or TweakXL does under the hood) when they matter for the change.
Keep it short and tied to the change in hand, not a lecture. Then do the work.

## Locked-in decisions
- Core stays redscript + Codeware (hooks and UI). TweakXL for TweakDB data. No CET or RED4ext rewrite of mod features.
- PC / Nexus only. No console or mod.io build.
- Keep the optional EnhancedCraft integration working (`@if(ModuleExists("EnhancedCraft.Common"))`).
- Target game patch 2.5+ with current frameworks. Versions in use are in `HANDOFF.md` §3.

## Task rules
1. Top to bottom in ROADMAP; one task at a time; verify; mark `[x]`.
2. One task = one commit (message = task text).
3. Blocked or failed twice → `[!]` + one-line note, move on. Max 2 attempts.
4. Never delete/reorder tasks. Append a Run Log entry per session.
5. Stop at every 🧑 human gate.
6. At phase end: overwrite `HANDOFF.md` §6 (current state), update the `SPEC.md` status table. After any bug fix: add it to `HANDOFF.md` §4 (symptom → root cause → fix).
7. Process changes (this file, ROADMAP §2, lint/hook/CI config) are proposed at phase end and made only after the human approves them at the gate. A lesson that applies every session becomes a line under Gotchas below that way, or an automated check if it's mechanical.
8. Every decision gets a ROADMAP decisions-log entry. One that is hard to reverse, surprising without context, and a real trade-off also gets an ADR in `docs/adr/`, linked from that entry.

## Conventions
- Release source: `src/redscript/PreemWeaponsmith/`, modules `PreemCrafting.*`. Dev-only code (tests, debug commands): `dev/redscript/` (module `PreemDev`), never shipped. Hook targets are listed in `docs/HOOKS.md`; regenerate it when hooks change.
- Hooks: prefer `@wrapMethod` and always call `wrappedMethod(...)`. Avoid `@replaceMethod` (it breaks other mods and every patch).
- Game-class extensions are grouped by game area in `Adapters/` (weapon, inventory, crafting system, item data). UI code goes in `PreemMainUI/`. TweakDB changes go in `Tweaking/` (or `tweaks/*.yaml` once moved to TweakXL YAML).
- Mod and slot TweakDB IDs (`Items.Preem*`, `AttachmentSlots.Preem*`, `<weapon>_Preem<Evolution>`) are save-visible. Renaming one needs a decision-log entry.
- Tuning values (stat amounts, unlock rarities) belong in tweak data or `PreemModSettings`, not scattered literals.
- Rules that decide outcomes (slot compatibility, unlock checks, mod limits) stay in plain classes with no UI or game-state access where possible, so RedTest can call them.
- Indent 2 spaces in new code. Existing files use mixed tabs and spaces, so don't reformat a whole file inside a feature task.

## Build & test
Preconditions: `REDCLI_GAME` env var points to the game folder (`S:\SteamLibrary\steamapps\common\Cyberpunk 2077`), and the game is **not running** for install steps.
- Compile check (offline, no game): `{{TODO: redscript-cli compile command against the 2.5 bundle + Codeware/ModSettings/TweakXL script dirs — set up in Phase 0}}`
- Install to game: `red-cli install`. Copies `src/` into `r6/scripts/PreemWeaponsmith`. Hot reload while the game runs: `red-cli watch` (needs RedHotTools).
- Install dev code + tests: `{{TODO: dev install command — Phase 0}}`
- Boot check (launches the game, waits for the main menu, collects logs, closes the game): `{{TODO: tools/boot-check.ps1 — Phase 0}}`
- Release zip: `red-cli pack` → `dist/`. Add `archive/PreemWeaponsmith.archive` under `archive/pc/mod/` in the zip.
- Logs: `r6/logs/redscript_rCURRENT.log` (compile errors, `ModLog`), `red4ext/logs/`, `red4ext/plugins/TweakXL/TweakXL.log`, `red4ext/plugins/Codeware/Codeware.log`.
- Game boots and long log reads run in a subagent that reports only success or the first real error.

## Verification recipe (cheapest first)
1. **Compile check**: offline redscript compile against the current game bundle. This catches renamed or removed game methods and signature changes.
2. **Boot check + self-check**: launch the game with dev code installed, then read the logs. Covers redscript load errors, TweakXL/Codeware errors, the `PreemDev` self-check (all Preem TweakDB records exist and are wired) and RedTest results.
3. **In-game commands**: CET console calls into `PreemDev` exec functions (spawn a weapon, apply mods, dump state). For this layer Claude can also take screenshots of the crafting screen.
- Test seams: `PreemModSlotManager.CanInstallPreemModInSlot` (slot rules), `PreemModUnlocker` static unlock lists (progression), `PreemModMaker.GetModFromModStyleType` (mod definitions), `PreemCraftingSystem.ApplyMods` (crafting result), and the TweakDB records themselves via the self-check. Tests never reach past these.
- Tests: write the failing test first and see it fail on the missing behaviour. Expected values come from the spec, the 2.2.5 behaviour or a hand-worked example, never recomputed the way the code does.
- Human gate: crafting UI look and feel in the 2.5 crafting screen; weapon behaviour (fire modes, barrels, melee mods, dual-wielding) in actual play.
- Before every commit: `git status`. Revert anything generated (`stage/`, `dist/`, WolvenKit `packed/`).

## Gotchas
- `final.redscripts` in the game folder is the *modded* bundle after redscript runs. Compile and decompile against the vanilla backup (`final.redscripts.bk`) or the snapshot in `S:\source\CyberpunkModding\game-snapshots\`.
- `@addField` and new classes need a full game restart. Hot reload only handles method bodies.
- The `.archive` replaces the game's whole `cooked_metadata.audio_metadata`, so it must be rebuilt for each game patch or replaced (see SPEC §6).
- Never run install steps or the boot check while the user is playing.

## Search hygiene
- Exclude `stage/`, `dist/`, `wolvenkit/source/raw/` (15 MB JSON), `wolvenkit/source/archive/`, `archive/`.
- Glob before Grep. The commented-out `src/.../Codeware/` folder is dead code until it is removed in Phase 1. Ignore hits there.
