# Preem Weaponsmith — Roadmap

> **Companion docs:** `SPEC.md` (*what* we build) · this file (*order* and *how*) · `HANDOFF.md` (*what is true now*) · `CLAUDE.md` (*rules* every session) · `notes/` (reasoning behind decisions; merged into SPEC once decided, SPEC wins on conflicts) · `GLOSSARY.md` (the project's words) · `docs/adr/` (hard-to-reverse decisions).

## 1. Plan at a glance
```
Phase 0 Toolchain on 2.5 ─► Phase 1 Runs on patch 2.5 ─► Phase 2 Tweaks to YAML ─► Phase 3 Sounds ─► Phase 4 Release & upkeep
```

**Why this order**
- Phase 0 comes first because nothing can be verified until the game, the frameworks and the compile/boot checks work on 2.5.
- Phase 1 is the riskiest part: 19 wrapped game methods and hundreds of cloned TweakDB records may have moved in 2.5, and dual-wielding touches the same weapon classes. Proving the mod still works there comes before any restructuring.
- Phase 2 (YAML) comes after Phase 1 so the self-check built there can prove the move changed nothing: dump the records before and after, then diff.
- Phase 3 (sounds) is separate because its approach is undecided and the mod works without it (only some fire-mode sounds go missing).
- Phase 4 turns the upgrade into a repeatable runbook once one full upgrade has been done.

---

## 2. How we work

### 2.1 The document set
| File | Purpose | Kind | Updated |
|---|---|---|---|
| `CLAUDE.md` | Short, stable rules, commands, verification recipe, gotchas. Loaded every session. | Rules | Rarely, deliberately |
| `ROADMAP.md` | Phases, tasks, checkboxes, Run Log, decisions log | Plan + log | Every task |
| `HANDOFF.md` | Architecture map, bugs with root causes, hard-won facts, current state | Reference + snapshot (§6) | Phase end, after every bug |
| `SPEC.md` | What the project is, plus a status table of what is built | Intent | When the design changes; status at phase end |
| `notes/*.md` | Reasoning, options turned down, worked numbers | Scratchpad | During design |
| `GLOSSARY.md` | The project's own terms, one or two sentences each; no implementation details | Reference | When a term is settled |
| `docs/adr/*.md` | One short record per decision that is hard to reverse, surprising, and a real trade-off | Reference | When such a decision is made |

**Logs grow, snapshots get overwritten.** The Run Log and HANDOFF §4 are append-only. HANDOFF §6 and the SPEC status table are overwritten, never appended to.

### 2.2 Task rules
1. Work phases **top to bottom**; take **one** unchecked task, finish it, verify it, mark it `[x]`.
2. **One task = one commit**, with the task text as the message.
3. Blocked or failed twice → mark `[!]`, add a one-line note under it, move on. **No more than 2 attempts.**
4. Never delete or reorder tasks. Only change their status and append notes (`- Note (YYYY-MM-DD): ...`).
5. End each session with a **Run Log** entry (date, tasks done, blockers).
6. Every phase ends with a **🧑 human gate**. Don't start the next phase until it passes. Gate feedback becomes new tasks at the end of the phase. Process changes proposed at phase end are made only if approved at the gate.

Task markers: `[ ]` todo · `[x]` done · `[!]` blocked (note says why) · 🧑 human gate.

### 2.3 Writing tasks
- **Vertical slices.** Each task cuts a narrow but complete path through every layer it touches (data, logic, UI, test) and can be verified on its own. Not "all the models, then all the screens".
- **One session's worth.** A task fits in one fresh context window. Split anything bigger.
- **Prefactor first.** If the current code makes a task awkward, put a task before it that reshapes the code without changing behavior (tests stay green). Make the change easy, then make the easy change.
- **Wide refactors** (one mechanical change that breaks many call sites at once, like renaming a shared type) can't be a vertical slice. Split them into expand (add the new form beside the old), migrate (move callers over in batches, one task each), and contract (delete the old form). Tests stay green after every task.
- **Seams.** A task that adds behavior names its test seam unless it's one in `CLAUDE.md` "Test seams".
- **Order is the dependency.** Tasks run top to bottom. When a task can't start until an earlier, non-adjacent task is done, end it with `(needs: <first words of that task>)`; `/next-task` skips it while that task is `[!]`.
- Real names in task text are fine; code snippets aren't (they go stale; the spec or a note holds the detail).

### 2.4 The per-task loop
```
Read CLAUDE.md + next ROADMAP task
        │
        ▼
Failing test at a seam (new behavior) ──► change code ──► build ──► unit tests ──► higher verification layers as needed
        │
        ▼
git status (catch generated junk) ──► commit ──► mark [x] + note ──► next task
```

### 2.5 Verification strategy (cheapest first)
| Layer | Tests | How |
|---|---|---|
| 1. Compile check | Game API changes, type errors | offline redscript compile against the vanilla bundle (CLAUDE.md) |
| 2. Boot check + self-check + RedTest | Loading, TweakDB records, pure rules | `tools/boot-check.ps1`, results from the game logs |
| 3. In-game debug commands | Crafting and weapon state end to end | `PreemDev` exec functions from the CET console; screenshots |
| 🧑 Human gate | Crafting UI look and feel, weapon behaviour in play | You check it |

### 2.6 Keeping Claude's context clean
- Exclude generated folders from searches (listed in CLAUDE.md).
- Run long builds in a subagent that returns only success or the first error.
- One agent drives a shared resource (dev server, editor, device) at a time.

---


## 3. Phases

### Phase 0 — Toolchain on patch 2.5
**Goal:** a clean 2.5 game install with current frameworks, plus an offline compile check, a boot check and a dev-only debug module that Claude can run without the human.
- [x] Back up the pre-2.5 `final.redscripts` and TweakDB before Steam updates.
  - Note (2026-10-25): saved to `S:\source\CyberpunkModding\game-snapshots\pre-2.5_build19999047\`.
- [x] Create the git repo with every release imported as a tagged commit.
  - Note (2026-10-25): v1.0.0–v2.2.5 tagged, Sandbox builds tagged `-sandbox`. The unreleased 2024-04-27 archive rebuild is its own commit. HEAD scripts match the installed game copy.
- [x] Add red-cli, Redscript IDE and WolvenKit project scaffolding and docs.
- [x] 🧑 Update the game to 2.5 in Steam (user), and confirm the build ID changed in `appmanifest_1091500.acf`.
  - Note (2026-10-25): Steam build 19999047 → 26161058, `StateFlags` 4 (fully installed).
- [x] Clean the game folder: remove CyberCMD, CyberTweaks (`version.dll`, `global.ini`), stale `r6/cache` modded bundles and old framework folders. List what was removed in HANDOFF §2. (needs: Update the game to 2.5)
  - Note (2026-10-25): moved (not deleted) to `game-folder-backup/2026-10-25_pre-2.5-cleanup/`; list in HANDOFF §2. Also snapshotted the vanilla 2.5 bundle and TweakDB to `game-snapshots/2.5_build26161058/`.
- [x] Dependency manifest: write `docs/DEPENDENCIES.md`, listing every dependency by group: runtime-required (RED4ext, redscript, Codeware, TweakXL, Mod Settings), runtime-optional (EnhancedCraft), dev-runtime (CET, ArchiveXL, RedHotTools, RedTest), dev tools (red-cli, redscript CLI, redscript-ide + VS Code extension, redscript-dap, WolvenKit, .NET runtime it needs) and future (Audioware). For each: what the mod uses it for, source URL, minimum version and pinned version. Point the README requirements at it.
  - Note (2026-10-25): group changes per the decisions log: Mod Settings moves to runtime-optional; Audioware is runtime-required from Phase 3.
  - Note (2026-10-25): done. Versions checked today on GitHub releases. Mod Settings 0.2.22 (first 2.5 build) came out today. Unconfirmed on 2.5 (⚠ in the file): Audioware 1.9.9 (released 2026-08), EnhancedCraft (last known 4.0.4, Nexus page not readable by script), RedTest (last commit targets redscript 0.5.31). ArchiveXL added as dev-runtime (Mod Settings and RedHotTools need it). .NET 10 for WolvenKit 9.1. README requirements now point at the file.
- [ ] Install the 2.5 frameworks (RED4ext, redscript, CET, Codeware, TweakXL, ArchiveXL, RedHotTools, Mod Settings) from their GitHub releases, with the user's OK on each download. Record versions in HANDOFF §3.
  - Note (2026-10-25): install the versions pinned in `docs/DEPENDENCIES.md` and check each release's SHA256 where one is published.
  - Note (2026-10-25): Mod Settings is now optional and Audioware becomes required from Phase 3 (decisions log). Install Audioware now too so it is in place.
- [ ] Install dev tools: red-cli, redscript CLI, VS Code Redscript IDE extension; set `REDCLI_GAME`; confirm `red-cli install` deploys to the game.
  - Note (2026-10-25): `red.config.json` has `"src\redscript\PreemWeaponsmith"`. In JSON, `\r` is a carriage return, so fix the path (forward slashes or doubled backslashes) before testing `red-cli install`.
- [ ] Install the debugger: redscript-dap. Confirm a breakpoint in a small scratch script is hit from VS Code, or record why not in HANDOFF §5. (needs: Install dev tools)
- [ ] Install WolvenKit 9.1 stable (and its .NET runtime). Open `wolvenkit/PreemWeaponsmith.cpmodproj`, set the game path, and confirm it packs `PreemWeaponsmith.archive` into `wolvenkit/packed/` without errors. Record any project-format upgrade WolvenKit does.
- [ ] Install the optional and test dependencies: EnhancedCraft (current 2.5 build, for compatibility checks; kept disabled except in compat tasks) and RedTest (git submodule under `dev/`, pinned commit).
- [ ] Dependency script: `tools/install-deps.ps1` installs or updates the frameworks into the game folder from the versions pinned in `docs/DEPENDENCIES.md` (downloads from GitHub releases, checks hashes, prints installed versions), so the next game patch is one command plus a version bump. It never runs while the game is open.
- [ ] Decompile the pre-2.5 snapshot and the 2.5 vanilla bundle into a separate `game-scripts` git repo, one commit each, so `git diff` shows what 2.5 changed.
- [ ] Offline compile check: one command that compiles `src/` plus Codeware/ModSettings/TweakXL scripts against the 2.5 vanilla bundle. Put it in CLAUDE.md and save the first error list to `notes/2.5-compile-errors.md` (errors are expected).
- [ ] Boot check: `tools/boot-check.ps1` launches the game with the mod uninstalled, waits for the main-menu log marker, collects the redscript/RED4ext/TweakXL/Codeware logs into `logs/` (gitignored) and closes the game. Confirm a clean framework-only boot.
- [ ] Dependency check in the boot check: it reads the RED4ext/redscript/CET logs and fails if a framework did not load or its version differs from `docs/DEPENDENCIES.md`.
- [ ] Dev module: `dev/redscript/PreemDev` with a `PreemPing` exec (CET console) and a RedTest harness with one trivial test, plus the dev install command. Find out whether `ScriptableSystem` attaches at the main menu or needs a loaded save, and record the answer in HANDOFF §5.

**Done when:** every dependency in `docs/DEPENDENCIES.md` is installed at its pinned version and verified by the boot check, and a fresh session can run the compile check, the boot check and `PreemPing` using only CLAUDE.md.
**🧑 Gate:** you launch the game yourself once with the dev setup: frameworks load, the CET console answers `PreemPing`, and the CLAUDE.md commands work for you.

### Phase 1 — Runs on patch 2.5
**Goal:** 2.2.5 behaviour works on 2.5. It compiles, loads, crafts with Preem mods and the weapons behave, with automated checks guarding it.
**Spec:** SPEC.md §2, §4, §5, §7
- [ ] Prefactor: delete the commented-out vendored `Codeware/` folder and commented-out dead hooks. Behaviour unchanged, compile error list unchanged apart from the removed files.
- [ ] Make the weapon and melee adapters compile on 2.5 (`PreemWeaponAdapter`, `ItemDataAdapter`), explaining each changed game method.
- [ ] Make the crafting system and inventory adapters compile on 2.5 (`PreemCraftingSystemAdapter`, `PreemInventoryAdapter`, `CraftingSystem/*`).
- [ ] Make the crafting UI compile on 2.5 (`PreemMainUI/*`, Codeware API changes since 2023).
- [ ] Make the tweaks compile and apply on 2.5 (`Tweaking/*`). The boot check must show no TweakXL errors.
  - Note (2026-10-25): `AttachmentSlots.PreemTriggerMod02` sets `entitySlotName` to `PreemTriggerMod01` (`PreemWeaponAlteration.reds`), probably a copy-paste slip. Fix it if it is wrong; old-save compatibility is out of scope (decisions log).
- [ ] Self-check in `PreemDev`: for every Preem mod record, attachment slot and evolution variant, check it exists and its base and stat records resolve. Write one pass/fail line each to the log, run it from the boot check, and fix every failure.
- [ ] Hook review: for each wrapped method in `docs/HOOKS.md`, diff the vanilla 2.2.5-era vs 2.5 version in `game-scripts` and record behaviour changes in `notes/2.5-hook-review.md`. Add a task below for each change that needs code.
- [ ] RedTest: slot rules (`CanInstallPreemModInSlot`: slot class, incompatible styles, required evolution) and unlock tiers (`PreemModUnlocker` lists), expected values from 2.2.5.
- [ ] Debug commands: `PreemDev` exec functions to give a test weapon, apply a set of Preem mods through `PreemCraftingSystem.ApplyMods`, and dump the result (record ID, evolution, trigger mode, installed mods).
- [ ] Crafting end-to-end via debug commands: craft a weapon with one mod from each ranged slot class and one melee one, then confirm the dumped state.
- [ ] Mod Settings on 2.5: confirm settings appear and apply; if Mod Settings is still broken, add a fallback so the mod loads with defaults (`@if(ModuleExists(...))`).
  - Note (2026-10-25): approach changed (decisions log): Mod Settings becomes optional. This task is now: boot and craft **without** Mod Settings installed and confirm the defaults apply. The code has no hard reference to it today, only `@runtimeProperty` annotations. Then do the same with it installed.
- [ ] Settings store (prefactor): a per-save `PreemSettings` `ScriptableSystem` with persistent fields for unlock mode, limit mode and slot layout, replacing every `new PreemModSettings()` call site. Defaults unchanged; confirm values survive save/load.
- [ ] Settings panel: a settings button on the Preem slot frame opens a Codeware popup to change the three settings for the current save; changes apply immediately in the crafting screen.
- [ ] Mod Settings as optional defaults: when Mod Settings is installed, its page sets the defaults a new save starts with; without it, built-in defaults. Boot check passes both ways.
- [ ] Dual-wield check: equip two Preem-modded weapons with the 2.5 dual-wield perk; trigger mode and attack hooks must apply per weapon. Fix or record findings.
- [ ] EnhancedCraft compatibility: boot and craft with EnhancedCraft installed; evolution variants and `ecraftVariants` still work.
- [ ] Release candidate 2.3.0: bump the version, add a CHANGELOG entry, run `red-cli pack` with the archive, and check the zip layout against the 2.2.5 zip.
  - Note (2026-10-25): the CHANGELOG and Nexus notes must say that 2.3.0 targets patch 2.5, that saves using earlier versions are not supported, and that a new save is recommended.

**Done when:** the compile check is clean, the boot check shows no errors and an all-pass self-check, RedTest passes, and the crafting end-to-end debug run gives the expected state.
**🧑 Gate:** in a real save on 2.5, does the crafting screen with Preem slots look right, and do the crafted weapons (fire modes, barrels, melee mods, dual-wielding) behave as they did in 2.2.5?

### Phase 2 — Tweak data to TweakXL YAML
Move the fixed mod records in `PreemModCreation` to `tweaks/*.yaml`, keeping the generated weapon variants in `ScriptableTweak`; prove it by diffing a full Preem record dump before and after.

### Phase 3 — Fire-mode sounds via Audioware
Replace the full `cooked_metadata.audio_metadata` override with Audioware (decided 2026-10-25). Map each fire-mode change to the sound events it needs and add them through Audioware (it can add events, not only replace them), drop the `.archive` from the release, and check vanilla weapon audio is unchanged. The silencer rework (`notes/silencer-ideas.md`) builds on this.

### Phase 4 — Release & upkeep
Patch-upgrade runbook in `docs/` (bump pins in `docs/DEPENDENCIES.md` → `tools/install-deps.ps1` → compile check → boot check), CHANGELOG backfilled from Nexus, Nexus page refresh with its requirements list matching `docs/DEPENDENCIES.md`, publish 2.3.0.

---

## 4. Parked ideas (no tasks yet)
- **Preem mods on the weapon upgrade screen** (and so on iconic weapons): after the 2.5 conversion. Thinking and open questions in `notes/upgrade-screen-ideas.md`.
- **A better Integral Silencer** that works on every gun, not just ones with muzzle support: after the conversion, after Phase 3 (Audioware sounds). Thinking in `notes/silencer-ideas.md`.
- Build the crafting UI from a WolvenKit `.inkwidget` instead of code: only worth it if the UI is redesigned.
- Re-enable the Sight slot class and the Technical Ability limit mode (removed in 2.2.5): needs a design decision first.
- Revisit Codeware helpers that could replace some UI hooks: after Phase 1, once it's clear what broke.

---

## 5. Run Log
<!-- Append-only. Newest at the bottom. -->
### 2026-10-25 — Workflow set up | blockers: game not yet updated to 2.5 (Steam update pending)
- Repo created with full release history; pre-2.5 scripts and TweakDB snapshotted; workflow docs written. Next: 🧑 update the game to 2.5, then Phase 0 cleanup and framework install.
### 2026-10-25 — Game on 2.5, folder cleaned | blockers: none
- Done: 🧑 game updated to 2.5 (build 26161058); game folder cleaned (old files moved to a backup folder); vanilla 2.5 bundle snapshotted. Then: dependency manifest `docs/DEPENDENCIES.md` written. Next: install the 2.5 frameworks (needs the user's OK per download).

---

## 6. Decisions log
<!-- Append-only. -->
### 2026-10-25 — Stay on redscript + Codeware; move fixed tweak data to TweakXL YAML
- Considered CET (Lua), RED4ext (C++) and REDmod. redscript remains the only one with robust method wrapping and native ink UI. Fixed records move to YAML in Phase 2; generated weapon variants stay in `ScriptableTweak`. SPEC §3 updated.
### 2026-10-25 — PC/Nexus only
- Patch 2.5 adds console mods through mod.io, but they can't run scripts, which is all of this mod. SPEC §1 non-goals updated.
### 2026-10-25 — Repo history: Blueprints variant on main, Sandbox builds as tags
- 2.0.1–2.2.4 shipped as two zips that differ only in the default unlock mode. Main follows Blueprints (the 2.2.5 default); Sandbox builds are tagged `vX.Y.Z-sandbox`.
### 2026-10-25 — Phase 0 expanded with dependency and tooling tasks
- At the user's request: dependency manifest, debugger, WolvenKit, optional/test deps, an install script and a boot-time version check. Inserted before any Phase 0 work started; existing tasks unchanged apart from a note.
### 2026-10-25 — Sounds move to Audioware
- Options: keep re-exporting the full `cooked_metadata.audio_metadata` every patch, or add the fire-mode sound events through Audioware. Chose Audioware: no base-game file override, no per-patch rebuild, no clash with other audio mods. Cost: a new required dependency (RED4ext plugin). The WolvenKit project and `.archive` are retired once Phase 3 lands. SPEC §3, §6 updated.
### 2026-10-25 — Mod Settings becomes optional; own settings panel, saved per playthrough
- Goal: the mod must keep working when Mod Settings lags behind a game patch. Options: own crafting-screen panel only; own panel + Mod Settings as optional defaults; hand-edited config file. Chose own panel + optional Mod Settings. Settings are stored per save (a Sandbox run and a Blueprints run can coexist); Mod Settings, when present, only sets the defaults for new saves. The current code has no hard reference to Mod Settings (just `@runtimeProperty` annotations), so it already loads without it, using defaults. SPEC §5, §7 updated.
### 2026-10-25 — No compatibility with pre-2.5 saves or earlier mod versions
- 2.5 may have overhauled the game code, and players expect big patches to need a new save. The 2.5 version may freely rename or restructure Preem TweakDB IDs, slots and stored state, with no migration code. The release notes must recommend a new save. Compatibility rules start again from 2.3.0. SPEC §1 non-goals updated.
