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
- Legacy workspace (read-only reference; don't edit): `S:\Games\CyberPunk\` (old mods, media in `EditedModFiles\`, release zips in `Mods\PreemWeaponsmith\ArchivedVersions\`).
- Obsolete items to remove from the game folder in Phase 0: `bin\x64\plugins\cybercmd.asi`, `bin\x64\version.dll` + `global.ini` (CyberTweaks), `r6\cache\final.redscripts.modded`/`.ts`. {{TODO: list what was actually removed}}
- Entry points / debug commands: {{TODO: PreemDev exec functions — Phase 0/1}}

## 3. Hard facts
| Fact | Value | Source / how to re-check |
|---|---|---|
| Game build before upgrade | Steam build 19999047 (exe 2025-09-17), update pending | `appmanifest_1091500.acf` `buildid` |
| Game build after 2.5 update | Steam build 26161058 (updated 2026-10-25) | `appmanifest_1091500.acf` `buildid` |
| Last known working setup | Patch 2.12, ArchiveXL 1.12.2 (2024-04-28) | `red4ext/logs` in the game folder |
| Framework versions for 2.5 (latest on 2026-10-25) | RED4ext 1.31.0, redscript 0.5.32, CET 1.38.0, Codeware 1.21.0, TweakXL 1.12.0, ArchiveXL 1.28.0, RedHotTools 1.3.0-rc.3, Mod Settings 0.2.21 (for 2.3) | GitHub releases; {{TODO: record installed versions}} |
| Live game hooks | 19 `@wrapMethod`, 0 `@replaceMethod` | `docs/HOOKS.md` |
| Source size | about 8.4k lines across 28 non-vendored `.reds` files | `git ls-files` |

## 4. Bugs & fixes (chronological)
*Format: YYYY-MM-DD: **Symptom** → root cause → fix (commit). End with the rule it teaches, if any; rules that apply every session are proposed for CLAUDE.md Gotchas (or an automated check) at phase end and added once approved at the gate.*

- (none yet)

## 5. Verification notes
- redscript compiles all mods at game start; errors go to `r6/logs/redscript_rCURRENT.log`. If compilation fails the game shows a popup and runs **without any script mods**.
- RedTest runs when its `ScriptableSystem` attaches. {{TODO: whether that happens at the main menu or needs a loaded save — Phase 0}}
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

**Watch / known quirks:** Mod Settings has no 2.5 build yet. It is being made optional (the code already loads without it, using defaults). The sound archive overrides a whole base-game file until Phase 3 moves sounds to Audioware.

**Quick start:** {{TODO: once Phase 0 is done: compile check → red-cli install → boot check}}
