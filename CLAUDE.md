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
- Never require Mod Settings: settings live in our own per-save store and panel; Mod Settings is optional and only sets defaults for new saves.
- Fire-mode sounds: fill only empty fields of the game's loaded sound metadata at load (Codeware, ADR 0001); never ship an `audio_metadata` override.

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
- Game-class extensions are grouped by game area in `Adapters/` (weapon, inventory, crafting system, item data). UI code goes in `PreemMainUI/`. TweakDB changes: fixed records in `tweaks/*.yaml` (TweakXL), records made per weapon in `Tweaking/` (`ScriptableTweak`).
- Mod and slot TweakDB IDs (`Items.Preem*`, `AttachmentSlots.Preem*`, `<weapon>_Preem<Evolution>`) are save-visible. Saves from before 2.5 are out of scope, so the 2.5 rework may rename or restructure them freely; list breaking changes in the CHANGELOG. Once 2.3.0 ships, renaming one needs a decision-log entry.
- Tuning values (stat amounts, unlock rarities) belong in tweak data or `PreemModSettings`, not scattered literals.
- Rules that decide outcomes (slot compatibility, unlock checks, mod limits) stay in plain classes with no UI or game-state access where possible, so RedTest can call them.
- Indent 2 spaces in new code. Existing files use mixed tabs and spaces, so don't reformat a whole file inside a feature task.

## Build & test
Preconditions: `REDCLI_GAME` env var points to the game folder (`S:\SteamLibrary\steamapps\common\Cyberpunk 2077`), or the tool scripts fall back to that folder (`tools/GamePath.psm1`; a bare `red-cli` command still needs the variable), and the game is **not running** for install steps.
- Frameworks: `pwsh tools/install-deps.ps1` installs or updates the pins in `docs/DEPENDENCIES.md` (`-DryRun` to preview, `-Only <names>`).
- Tooling tests (the boot check's rules): `pwsh -c "Invoke-Pester tools/tests"` (Pester 3.4, built into Windows).
- Compile check (offline, no game): `pwsh tools/compile-check.ps1`. It compiles `src/` plus every framework script in `<game>\red4ext\plugins` against the vanilla `r6\cache\final.redscripts` and never writes to the game folder. Exit 1 on any error; errors are printed, full output goes to `logs/compile-check.log`. `-WithEnhancedCraft` also compiles the EnhancedCraft branches; `-Extra <path>` adds dev code or a scratch file. redscript-cli itself exits 0 on a failed build, so always use the script, not the raw command.
- Install to game: `pwsh tools/install.ps1` runs `red-cli install` (copies `src/` into `r6/scripts/PreemWeaponsmith`) and copies `tweaks/*.yaml` into `r6/tweaks/PreemWeaponsmith/`, which red-cli doesn't know about. Run it after changing either. `-ScriptsOnly` skips the YAML and leaves `r6/tweaks` as it is (red run of a tweak move). The release zip ships both. No hot reload on 2.5 for now: `red-cli watch` needs RedHotTools, which crashes 2.5 and is disabled (HANDOFF §4).
- Install dev code + tests: `pwsh tools/dev-install.ps1` (`-Uninstall` removes it). It copies `dev/redscript/PreemDev` and the RedTest submodule into `r6\scripts`. The boot check then reports `[PreemDev]` game-log lines and the RedTest summary, and fails on any failed test. In the CET console: `Game.PreemPing()` prints `[PreemDev] pong`.
- Boot check (launches the game, waits for the main menu, collects logs, closes the game): `pwsh tools/boot-check.ps1` (about 1 min). It boots whatever is in `r6\scripts` and prints the list, so it is framework-only when that folder is empty. Exit 1 on timeout, crash, a redscript error, an error line in any RED4ext/plugin/CET log, or a dependency that didn't load at its pinned version (`docs/DEPENDENCIES.md`). Logs go to `logs/boot-<timestamp>/`. Needs CET: the main-menu marker is the dev CET mod `dev/cet/PreemBoot`, installed and removed by the script.
- Boot check options: `-Run <file.lua> -HoldSec <s>` runs a Lua file as a one-off CET mod and keeps the game open (`dev/cet/*.lua`); `-LoadSave` loads the newest save first (it presses Space in the game window, so it takes keyboard focus); `-Screenshot` saves a screenshot to the log folder; `-Without '<pin>'` boots without an optional dependency (e.g. `'Mod Settings'`) and puts it back afterwards; `-WithEnhancedCraft` copies the staged EnhancedCraft release (`downloads/2026-10-25_EnhancedCraft`) in for the run and removes exactly those files afterwards (refuses if any is already installed).
- Crafting-screen UI: drive it through the dev-only `PreemUi*` exec functions (they call the same handlers a click does) and check with `-Screenshot`; injected mouse clicks don't reach the game's cursor (HANDOFF §5).
- Control-character check (`.md`, `.ps1`, `.psm1`, `.lua`, `.reds`; tabs allowed in `.reds` only): `pwsh tools/check-text-chars.ps1`; the pre-commit hook runs it once a clone has `git config core.hooksPath tools/hooks`.
- Record dump (any tweak-data change): `pwsh tools/tweak-dump.ps1` boots to the main menu and compares every flat of every `Items.Preem*`/`AttachmentSlots.Preem*` record with `dev/baseline/tweak-dump.txt`, printing the lines that differ. For an intended change, write the expected lines into the baseline by hand first; `-SaveBaseline` only from a state already proven.
- Vanilla-marker comparison (any change to evolution variants): `pwsh tools/variant-markers.ps1` boots to the main menu with `dev/cet/weapon-dump.lua` (every `WeaponItem` record, about 70 MB) and lists, per flat, the `Items.Preset_*` variants that keep an old-evolution marker or lack one their new evolution's weapons share (`-Dump <file>` reuses a dump, `-Csv` writes every row). Some differences are expected (stat groups, `rangedAttacks`, the Phase 2 gate's list); compare the counts before and after a change.
- New game patch or framework build: follow `docs/PATCH-UPGRADE.md`.
- Release zip: `pwsh tools/pack-release.ps1` → `dist/PreemWeaponsmith-<version>.zip`. Never ship a `red-cli pack` zip: red-cli 0.5.1 drops the mod code (HANDOFF §4).
- Logs: `r6/logs/redscript_rCURRENT.log` (compile errors), `bin/x64/plugins/cyber_engine_tweaks/gamelog.log` (`FTLog`/`ModLog`/`Print`, RedTest), `red4ext/logs/`, `red4ext/plugins/TweakXL/TweakXL.log`, `red4ext/plugins/Codeware/Codeware.log`.
- Game boots and long log reads run in a subagent that reports only success or the first real error.

## Verification recipe (cheapest first)
1. **Compile check**: offline redscript compile against the current game bundle. This catches renamed or removed game methods and signature changes.
2. **Boot check + self-check**: launch the game with dev code installed, then read the logs. Covers redscript load errors, TweakXL/Codeware errors, the `PreemDev` self-check (all Preem TweakDB records exist and are wired) and RedTest results.
3. **In-game commands**: CET console calls into `PreemDev` exec functions (spawn a weapon, apply mods, dump state), automated with `boot-check -LoadSave -Run <file.lua>`. End-to-end scripts in `dev/cet/`: `craft-e2e` (crafting), `owned-e2e` (mods on an owned weapon), `upgrade-e2e` (Upgrades tab), `iconic-e2e` (iconic trigger behaviour), `silencer-e2e` (the Silencer, its hidden muzzle part, brake twins and the vanilla mod-screen paths), `silencer-check` (silenced sound sets; read with `tools/sound-sweep-report.ps1`). Installs and equips need a loaded save; at the main menu they are never processed. For this layer Claude can also drive the crafting screen with `PreemUi*` and take screenshots.
- Test seams: `PreemModSlotManager.CanInstallPreemModInSlot` (slot rules), `PreemModUnlocker` static unlock lists (progression), `PreemModMaker.GetModFromModStyleType` (mod definitions), `PreemCraftingSystem.ApplyMods` (crafting result), `PreemCraftingSystem.GetCraftRecord` (which record a craft makes), `PreemCraftingSystem.AreModsCompatible` (incompatibility and required evolution, which `CanInstallPreemModInSlot` doesn't check), `PreemSoundSets.Patch` (fire-mode sound fills), `PreemCraftingSystem.PlanModSlots`/`PlanModChanges` (install plan on a new or owned item), `PreemCraftingSystem.PlanMuzzlePart` (what the muzzle slot holds with or without the Silencer), `PreemMuzzleParts.HidesMuzzleSlot` (which weapons' muzzle slot the vanilla screens hide), `PreemCraftingSystem.GetInstalledMods` (read-back of an item's Preem mods), `PreemCraftingSystem.IsModAllowedOnOwnedWeapon` and `CanInstallMods` (owned-weapon rules and limit), and the TweakDB records themselves via the self-check (wiring) and the record dump (every flat value). Tests never reach past these.
- Tests: write the failing test first and see it fail on the missing behaviour. Expected values come from the spec, the 2.2.5 behaviour or a hand-worked example, never recomputed the way the code does.
- Human gate: crafting UI look and feel in the 2.5 crafting screen; weapon behaviour (fire modes, barrels, melee mods, dual-wielding) in actual play.
- Before every commit: `git status`. Revert anything generated (`stage/`, `dist/`, WolvenKit `packed/`).

## Gotchas
- redscript 0.5.32 leaves `r6\cache\final.redscripts` vanilla and writes the modded bundle to `final.redscripts.modded`; the compile check relies on that. Older redscript versions overwrote it and kept the vanilla copy as `final.redscripts.bk`. Patch snapshots are in `S:\source\CyberpunkModding\game-snapshots\`.
- CET writes `gamelog.log` and `scripting.log` only when the game exits; script output (`FTLog`/`ModLog`/`Print`) is there. Read them after the game closes; to see something live, write a file from a CET mod (as `dev/cet/PreemBoot` does).
- `@addField` and new classes need a full game restart. Hot reload only handles method bodies.
- The game folder must not hold 2.2.5's `archive\pc\mod\PreemWeaponsmith.archive`: it replaces the game's whole `cooked_metadata.audio_metadata`.
- Never run install steps or the boot check while the user is playing.
- redscript: a method called through a null record reference (`wref`) returns garbage instead of failing; check `IsDefined` before using the result.
- PowerShell: wrap function results and `Get-Content` in `@(...)` before `-match`, `.Count` or indexing (one element unrolls to a scalar).
- A `SetFlat` (or YAML) value of the wrong type, e.g. a String for a CName flat, is ignored without an error; prove a tweak change with the record dump.
- A cloned record's flat ID can collide with an existing flat (IDs are 32-bit hashes); check `VariantTypeName` before reading or rewriting a flat on a clone.
- Edit text containing backslashes with the Edit tool, never through Python string literals (escapes like `\t` and `\r` turn into control characters).
- In Claude's shell, `Remove-Item` on paths under the game folder can be refused by the path guard; use `rm -rf "<path>"` from Bash.

## Search hygiene
- Exclude `stage/`, `dist/`, `wolvenkit/source/raw/` (15 MB JSON), `wolvenkit/source/archive/`, `archive/`.
- Glob before Grep.
