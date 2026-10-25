# Preem Weaponsmith — Handoff

The project as it actually is: what a fresh session needs that the code doesn't say plainly.
Update at the end of every phase and after any bug fix. Read alongside `CLAUDE.md` (rules), `ROADMAP.md` (tasks + Run Log), `SPEC.md` (design).

| Section | Kind |
|---|---|
| §1–§3, §5 | Reference: keep current, edit in place |
| §4 Bugs & fixes | Log: append only |
| §6 Current state | Snapshot: **overwrite** at each phase end |

## 1. Architecture map
All paths are under `src/redscript/PreemWeaponsmith/`. Modules are `PreemCrafting.*`.

| Area | Classes / modules | Notes |
|---|---|---|
| Core data | `PreemMod`, `PreemSlot`, `PreemStats` (`Core/BaseItems.reds`); `PreemModStyleType`, `PreemModClassType` etc. (`Core/BaseEnums.reds`) | Style enum values are grouped by hundreds per slot class (Barrel 0–19, Trigger 100+, Mag 200+, Sight 300+, Blade 400+, Handle 500+). Code relies on those ranges. |
| Settings | `PreemModSettings` (`Core/PreemModSettings.reds`) | `@runtimeProperty("ModSettings.*")` fields. `GetInstance()` returns a **new** object each call, and Mod Settings fills it at construction. Defaults: unlock = WeaponBlueprints, limit = Sandbox. |
| Mod catalogue | `PreemModMaker` (`CraftingSystem/PreemModMaker.reds`) | Static factory: style type → `PreemMod` with requirements, incompatibilities and description text. All mod text lives here. |
| Mod ↔ game item mapping | `PreemModMapper` | Maps a `PreemMod` to its TweakDB item (`Items.Preem…`) and attachment slot(s) (`AttachmentSlots.Preem…01/02`). |
| Slot rules | `PreemModSlotManager` | `CanInstallPreemModInSlot`: slot class, incompatible styles, required evolution. Also tracks the selected and hovered slot for the UI. |
| Progression | `PreemModUnlocker` | Sandbox vs Blueprints. Static per-rarity unlock lists (Common … Legendary++) and the mod-amount limit. |
| Crafting system | `PreemCraftingSystem` (`ScriptableSystem`) | Holds the mods chosen for the current craft. `ApplyMods` installs them on the crafted `gameItemData`. Reached via `GetInstance(gameInstance)`. |
| Game hooks: crafting | `PreemCraftingSystemAdapter` | Wraps `CraftingSystem.CraftItem` (swaps to the evolution variant record and installs mods), `CanItemBeCrafted`, `EnoughIngredientsForCrafting`. Adds `InstallPreemMod`. |
| Game hooks: inventory | `PreemInventoryAdapter` | Wraps `InventoryDataManagerV2` / `UIInventoryItemModsStaticData` slot queries so Preem slots show or hide correctly in the inventory UI. |
| Game hooks: weapon | `PreemWeaponAdapter`, `ItemDataAdapter` | `WeaponObject.OnGameAttached` sets the trigger mode from installed mods; `WeaponTransition` wraps choose the attack record and trigger mode; melee wraps add blade/handle effects. `gameItemData.DoesItemHave*` helpers. Large commented-out blocks are dead code. |
| Crafting UI | `PreemWeaponPreviewContainer.reds` (adds members to `CraftingMainGameController`), `PreemUI/*`, `PreemUIBase/*` | Builds the slot frame (ranged or melee) in code with Codeware `inkCustomController`. The `PreemModSelectorPopup` (Codeware `CustomPopup`) lists mods. `MaterialTooltip.SetData` wrap adds mod descriptions. |
| TweakDB | `PreemModCreation`, `PreemWeaponAlteration` (`ScriptableTweak`, `Tweaking/`) | ModCreation: about 370 clone/set calls creating fixed mod item and stat records (moves to YAML in Phase 2). Alteration: loops over every weapon, adds Preem slots and creates `_Preem<Evo>` evolution variants (plus EnhancedCraft variants when present). |
| Vendored Codeware | `Codeware/` | Entirely commented out. Real Codeware is a runtime dependency. Removed in Phase 1. |
| Sound archive | `archive/PreemWeaponsmith.archive`, built from `wolvenkit/` | Full replacement of `base\sound\metadata\cooked_metadata.audio_metadata` adding auto-fire events. Event list: `docs/weapon-sound-events.txt`. |

## 2. Build & run
- Commands: see `CLAUDE.md`.
- Game: `S:\SteamLibrary\steamapps\common\Cyberpunk 2077` (Steam app 1091500). Steam manifest: `S:\SteamLibrary\steamapps\appmanifest_1091500.acf`.
- Game script/TweakDB snapshots: `S:\source\CyberpunkModding\game-snapshots\` (pre-2.5 = build 19999047).
- Decompiled game scripts: `S:\source\CyberpunkModding\game-scripts\` (local git repo; don't publish). One commit per patch under `scripts/`, tags `pre-2.5` and `2.5`. Compare a hooked class with `git diff pre-2.5 2.5 -- <file>`; find its file with `git grep -l "class <Name> "`. Its README has the steps to add a patch.
- Dev tools: `S:\source\CyberpunkModding\tools\bin\` (on the user PATH): `red-cli.exe` 0.5.1, `redscript-cli.exe` 0.5.32. `REDCLI_GAME` is set as a user environment variable. VS Code: `jac3km4.redscript-ide-vscode` 0.3.4, with `redscript.gameDir` set in the user settings. Downloaded zips are kept in `S:\source\CyberpunkModding\downloads\`.
- WolvenKit 9.1.0: GUI `S:\source\CyberpunkModding\tools\WolvenKit\WolvenKit.exe`, CLI `S:\source\CyberpunkModding\tools\WolvenKit.Console\WolvenKit.CLI.exe` (not on PATH). Pack the sound archive: `WolvenKit.CLI build <repo>\wolvenkit` writes `wolvenkit\packed\archive\pc\mod\PreemWeaponsmith.archive` (gitignored); then copy it to `archive\`. Rebuilds are content-identical to the shipped archive; only the header bytes differ, so compare with `WolvenKit.CLI extract` plus file hashes, never the whole-file hash.
- Frameworks: `pwsh tools/install-deps.ps1` (`-DryRun` to preview, `-Only <names>`, `-Force`). It installs the pins from the JSON block in `docs/DEPENDENCIES.md`, using the download cache `S:\source\CyberpunkModding\downloads\deps-cache\`. Needs `REDCLI_GAME` in the environment; a shell started before that variable was set won't have it. To be added to CLAUDE.md "Build & test" at the phase-0 gate.
- `red-cli install` copies only `.reds` files (no LICENSE files) into `r6\scripts\PreemWeaponsmith\`. Remove that folder again before a framework-only boot check.
- Legacy workspace (read-only reference; don't edit): `S:\Games\CyberPunk\` (old mods, media in `EditedModFiles\`, release zips in `Mods\PreemWeaponsmith\ArchivedVersions\`).
- Game folder cleaned 2026-10-25 (Phase 0). Everything was **moved**, not deleted, to `S:\source\CyberpunkModding\game-folder-backup\2026-10-25_pre-2.5-cleanup\` with its game-relative path:
  - CyberCMD: `bin\x64\plugins\cybercmd.asi`, `r6\config\cybercmd\` (correction: `r6\config\cybercmd\scc.toml` belongs to redscript, and the redscript 0.5.32 install puts a fresh copy back)
  - ASI loader: `bin\x64\version.dll`, `bin\x64\global.ini` (correction: CET uses it too, and CET 1.38.0 ships a fresh copy, version.dll 6.0.0)
  - Missed by the cleanup: `bin\x64\winmm.dll` (the 2024 RED4ext loader). Overwritten by the RED4ext 1.31.0 install, so no backup of it exists.
  - Stale modded bundles: `r6\cache\final.redscripts.modded`, `final.redscripts.ts`
  - 2.12-era frameworks: `red4ext\` (RED4ext + ArchiveXL/Codeware/TweakXL plugins and logs), `bin\x64\plugins\cyber_engine_tweaks*` (CET, incl. its settings and mods), `bin\x64\plugins\address_library\`, `r6\scripts\{ArchiveXL,Codeware,TweakXL}`
  - The mod itself: `r6\scripts\PreemWeaponsmith\`, `archive\pc\mod\PreemWeaponsmith.archive` (reinstall with `red-cli install`)
  - Left in place: `engine\config\platform\pc\{platformgameplay,rendering}.ini` (2024 edits of unknown origin, harmless to mods; ask the user before removing), `mods\.stub` (REDmod placeholder), base `r6\config` files.
- Vanilla 2.5 `final.redscripts`, `tweakdb.bin`, `tweakdb_ep1.bin` copied to `game-snapshots\2.5_build26161058\` before redscript ever ran on 2.5.
- Entry points / debug commands: {{TODO: PreemDev exec functions — Phase 0/1}}

## 3. Hard facts
| Fact | Value | Source / how to re-check |
|---|---|---|
| Game build before upgrade | Steam build 19999047 (exe 2025-09-17), update pending | `appmanifest_1091500.acf` `buildid` |
| Game build after 2.5 update | Steam build 26161058 (updated 2026-10-25) | `appmanifest_1091500.acf` `buildid` |
| Last known working setup | Patch 2.12, ArchiveXL 1.12.2 (2024-04-28) | `red4ext/logs` in the game folder |
| Framework versions for 2.5 (latest on 2026-10-25) | RED4ext 1.31.0, redscript 0.5.32, CET 1.38.0, Codeware 1.21.0, TweakXL 1.12.0, ArchiveXL 1.28.0, RedHotTools 1.3.0-rc.3, Mod Settings 0.2.22 (first 2.5 build, 2026-10-25), Audioware 1.9.9 | Pins and sources: `docs/DEPENDENCIES.md` |
| Installed frameworks (2026-10-25, from hash-checked GitHub release zips) | RED4ext 1.31.0 (`winmm.dll`, `RED4ext.dll`), redscript 0.5.32 (`engine\tools\scc.exe`), CET 1.38.0, Codeware 1.21.0, TweakXL 1.12.0, ArchiveXL 1.28.0, Mod Settings 0.2.22. Boot on 2026-10-25: RED4ext loaded ArchiveXL, Codeware, Mod Settings and TweakXL, and redscript compiled. CET not yet checked. **Disabled because they crash 2.5 on load:** RedHotTools 1.3.0-rc.3, Audioware 1.9.9, redscript-dap 0.0.8 (HANDOFF §4), moved to `S:\source\CyberpunkModding\game-folder-backup\disabled\` | DLL file versions (PowerShell `(Get-Item <dll>).VersionInfo`). `scc.exe` and `audioware.dll` have no version resource. Zips kept in `S:\source\CyberpunkModding\downloads\2026-10-25_frameworks-2.5\` |
| Where redscript 0.5.32 writes its output | `r6\cache\final.redscripts.modded` (plus `.ts`). `final.redscripts` stays vanilla. This contradicts the older CLAUDE.md gotcha; propose the update at phase end | `r6\logs\redscript_rCURRENT.log`, last line |
| redscript-cli exit code | `redscript-cli compile` exits **0 even when the build fails**. Failure shows only as `ERROR` lines and a final `ERROR [redscript_cli] Build failed`; `tools/compile-check.ps1` parses those. Diagnostics may carry a code (`[UNRESOLVED_METHOD]`, `[TYPE_ERR]`), and one run reports every kind of error together | Tested 2026-10-25 with scratch files (Phase 0 compile check task) |
| RED4ext plugin load order | Alphabetical by plugin folder or DLL name. The last log line before a crash names the plugin that was loading | `red4ext\logs\red4ext-*.log` |
| Live game hooks | 19 `@wrapMethod`, 0 `@replaceMethod` | `docs/HOOKS.md` |
| Source size | about 8.4k lines across 28 non-vendored `.reds` files | `git ls-files` |

## 4. Bugs & fixes (chronological)
*Format: YYYY-MM-DD: **Symptom** → root cause → fix (commit). End with the rule it teaches, if any; rules that apply every session are proposed for CLAUDE.md Gotchas (or an automated check) at phase end and added once approved at the gate.*

- 2026-10-25: **Game crashes about 2 s after launch, before the main menu (access violation 0xc0000005, Windows Application log event 1000)** → three RED4ext plugins with no 2.5 build crash the game while RED4ext loads them: Audioware 1.9.9, RedHotTools 1.3.0-rc.3 and redscript-dap 0.0.8. Each was isolated by the last `Loading plugin from ...` line in `red4ext\logs` before the crash. Mod Settings 0.2.22 was cleared as the cause: TweakXL loads fine right after it → fix: moved the three to `game-folder-backup\disabled\` (no commit; game folder only). Rule: a plugin released before a game patch is guilty until a boot shows it loading. Re-enable each one only after it publishes a build for the patch. (The boot check's dependency check should catch this automatically.)

## 5. Verification notes
- redscript compiles all mods at game start; errors go to `r6/logs/redscript_rCURRENT.log`. If compilation fails the game shows a popup and runs **without any script mods**.
- RedTest runs when its `ScriptableSystem` attaches. {{TODO: whether that happens at the main menu or needs a loaded save — Phase 0}}
- Debugger: redscript-dap 0.0.8 (latest, 2025-08) crashes 2.5 on load, so there are no breakpoints for now. Re-test when it publishes a 2.5 build: put the DLL in `red4ext\plugins\`, put a scratch `@wrapMethod(SettingsMainGameController) OnInitialize` hook in `r6\scripts\` (it fires when Settings opens from the main menu, no save needed, and compiled cleanly on 2.5), run VS Code `Redscript: Attach to Cyberpunk 2077`, set the breakpoint on a line with a function call, then open Settings. Until then: `FTLog` / `ModLog` logging. Hot reload is also unavailable, because `red-cli watch` needs RedHotTools, which is disabled for the same reason.
- Not automatable: judging how the UI looks and how weapons feel in combat. Those are human gates.

## 6. Current state & next steps
*Overwrite this section at each phase end; don't append. History lives in the ROADMAP Run Log.*

**Where we are (2026-10-25):** Phase 0 in progress. Repo, history and docs done. No tests yet. Branch `main`.

**Next:** 🧑 update the game to patch 2.5 in Steam, then clean the game folder and install the 2.5 frameworks.

**To confirm at the gate:** the main line follows the Blueprints variant. Sandbox-only differences are kept in `-sandbox` tags.

**What exists today:**
- Mod source for 2.2.5 plus an unreleased 2024 archive rebuild, matching what is installed.
- red-cli and Redscript IDE configs (unverified until the tools are installed).
- Docs: toolchain workflow, hook list, Nexus description.

**Not built yet:** compile check, boot check, `PreemDev` module, tests; any 2.5 fixes.

**Settled; don't reopen without the user:** redscript + Codeware core; PC/Nexus only; EnhancedCraft compatibility kept; Audioware for sounds; Mod Settings optional, with our own per-save settings panel; no compatibility with pre-2.5 saves or earlier mod versions.

**Watch / known quirks:** Mod Settings published its 2.5 build (0.2.22) on 2026-10-25. It is still being made optional (the code already loads without it, using defaults). The sound archive overrides a whole base-game file until Phase 3 moves sounds to Audioware.

**Quick start:** {{TODO: once Phase 0 is done: compile check → red-cli install → boot check}}
