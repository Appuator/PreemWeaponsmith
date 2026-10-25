# Preem Weaponsmith — Modding Toolchain & Maintenance Workflow

Researched 2026-10-25. Game patch **2.5** ("Edgerunners 2 Update") shipped 2026-10-22, and the core frameworks were updated for it between 2026-10-22 and 2026-10-25.

---

## 1. What you have today (audit of `S:\Games\CyberPunk`)

| Thing | Where | State |
|---|---|---|
| Mod source (redscript, ~8.4k lines) | `Mods\PreemWeaponsmith\r6\scripts\PreemWeaponsmith\` | Identical to the **2.2.5** release zip, and to what is installed in the game. This is your real source of truth. |
| Older working copy | `Mods\PreemWeaponsmithTest\` and `EditedModFiles\test\` | Older than 2.2.5 (Sept 2023). Safe to retire. |
| Release history | `Mods\PreemWeaponsmith\ArchivedVersions\*.zip` | 1.0 → 2.2.5, plus Sandbox and Blueprints variants. This is your only version history. |
| `.archive` (540 KB) | `Mods\WolvenKitPreemWeaponsmith\` (old WolvenKit project) | Project `source` contains only a modified **`base\sound\metadata\cooked_metadata.audio_metadata`** (and the `ep1` copy), meaning it replaces the whole game sound metadata file to add weapon fire-mode sounds. |
| Media / Nexus images | `EditedModFiles\*.png`, `GimpEdits\*.xcf`, showcase mp4 | Fine; keep outside git or in a separate `media/` folder. |
| Game script reference | `ModTools\Decompiler\cyberpunkDecompiled` and `GameCode\` | Decompiled in **2022 (patch 1.6)**. Obsolete. |
| Obsolete tools | `ModTools\CyberCMD`, `ModTools\CyberTweaks`; in-game `bin\x64\plugins\cybercmd.asi`, `version.dll`, `global.ini` | CyberCMD and CyberTweaks are dead (replaced by redscript's own loader and TweakXL). Remove them from the game. |
| Game install | `S:\SteamLibrary\steamapps\common\Cyberpunk 2077` | Frameworks last ran on **patch 2.12** (RED4ext log, April 2024); exe dated Sept 2025. No version control anywhere. |

**Runtime dependencies the code actually uses**

- **redscript**: everything.
- **Codeware**: `import Codeware.UI.*`. The vendored `Codeware/` folder inside the mod is fully commented out and can be deleted.
- **TweakXL**: `TweakDBManager` / `TweakDB` record creation in `Tweaking/*.reds`.
- **Mod Settings** (jackhumbert): `@runtimeProperty("ModSettings.*")` in `Core/PreemModSettings.reds`.
- **EnhancedCraft**: optional, behind `@if(ModuleExists("EnhancedCraft.Common"))`.
- **ArchiveXL**: only needed if the `.archive` moves to an ArchiveXL-style approach.

**Game hooks to re-verify every patch:** 19 live `@wrapMethod` hooks and no live `@replaceMethod` (full list in `docs/HOOKS.md`; earlier counts included commented-out code). The highest-risk ones for 2.5, which added dual-wielding, are on `WeaponObject`, `WeaponTransition`, `MeleeAttackGenericEvents` and `MeleeSprintAttackEvents`, followed by the crafting hooks (`CraftingSystem`, `CraftingMainGameController`/`CraftingMainLogicController`) and the inventory ones (`InventoryDataManagerV2`, `UIInventoryItemModsStaticData`).

---

## 2. Current toolchain (latest versions as of 2026-10-25)

### Runtime frameworks (install into the game, ideally through a mod manager)
| Tool | Latest | Notes |
|---|---|---|
| [RED4ext](https://github.com/WopsS/RED4ext) | 1.31.0 (10-24) | Minimum game version is now 2.5. Adds support for the new in-game mod menu with redscript mods. |
| [redscript](https://github.com/jac3km4/redscript) | 0.5.32 (10-22) | "support script bundles from game patch 2.5". Replaces CyberCMD entirely. |
| [Cyber Engine Tweaks](https://github.com/maximegmd/CyberEngineTweaks) | 1.38.0 (10-22) | Console and Lua, for in-game testing. |
| [Codeware](https://github.com/psiberx/cp2077-codeware) | 1.21.0 (10-25) | |
| [TweakXL](https://github.com/psiberx/cp2077-tweak-xl) | 1.12.0 (10-25) | |
| [ArchiveXL](https://github.com/psiberx/cp2077-archive-xl) | 1.28.0 (10-25) | |
| [Mod Settings](https://github.com/jackhumbert/mod_settings) | 0.2.21 (2025-07, "Update for 2.3") | **Risk:** not yet updated for 2.5. Watch it, or plan a fallback (see §5). |
| [Audioware](https://github.com/cyb3rpsych0s1s/audioware) | 1.9.9 (2026-08) | A RED4ext plugin for adding or overriding sounds without replacing `cooked_metadata`. |

### Developer tools
| Tool | Latest | Replaces / why |
|---|---|---|
| **VS Code + [Redscript IDE](https://marketplace.visualstudio.com/items?itemName=jac3km4.redscript-ide-vscode)** (`jac3km4.redscript-ide-vscode`) | redscript-ide 0.2.25 | Live compile errors, autocomplete, hover and go-to-definition **into the game's own scripts**, plus a formatter. This replaces browsing an old decompile dump. Configured per folder with a `.redscript` TOML file. |
| [redscript-dap](https://github.com/jac3km4/redscript-dap) | 0.0.8 | Breakpoint debugger for redscript, used through the IDE extension. |
| [red-cli](https://github.com/rayshader/cp2077-red-cli) | 0.5.1 (10-25, badge says v2.5) | **The build tool for this repo.** `red-cli install` copies scripts into the game, `red-cli watch` hot-reloads on save, `red-cli pack` bundles one file per module and zips a release. Configured with `red.config.json`. |
| [RedHotTools](https://github.com/psiberx/cp2077-red-hot-tools) | 1.3.0-rc.3 | Hot reload of scripts, tweaks and archives in-game, plus world/ink inspector. `red-cli watch` relies on it. |
| [WolvenKit](https://github.com/WolvenKit/WolvenKit) | 9.1.0 (10-10) | For the `.archive` (sounds, icons). Includes the Tweak Browser for looking up TweakDB records and IDs. Install the stable build. |
| redscript CLI (in the redscript release) | 0.5.32 | Compiles outside the game for CI-style checks, and **decompiles** the game's `final.redscripts` for patch diffs (§4). |
| [NativeDB](https://nativedb.red4ext.com) | web | Reference for native classes and functions that have no script source. |
| Mod manager: **Vortex** or **MO2 2.5+** | — | Install the frameworks and other mods. **Don't** install your own mod through it during development; red-cli owns that folder. |

### REDmod / mod.io (new in 2.5)
Patch 2.5 adds an in-game, curated mod browser built on mod.io that also covers consoles. Console builds cannot run RED4ext or redscript, so Preem stays a **PC/Nexus** mod. REDmod is only worth using for the archive part. The `tools\redmod` folder in your install is fine to leave alone.

---

## 3. Proposed project layout (`S:\source\CyberpunkModding\PreemWeaponsmith`, git repo)

```
PreemWeaponsmith/
├─ .git/  .gitignore                 # ignore stage/, dist/, *.zip, wolvenkit/packed, wolvenkit/raw caches
├─ red.config.json                   # red-cli config (game path via REDCLI_GAME env var, not committed)
├─ .redscript                        # IDE: source_roots = ["src/redscript"]
├─ src/
│  └─ redscript/PreemWeaponsmith/    # moved from Mods\PreemWeaponsmith\r6\scripts\PreemWeaponsmith
│     ├─ Adapters/ Core/ CraftingSystem/ PreemMainUI/ Tweaking/
├─ wolvenkit/                        # WolvenKit 9 project (only if the .archive survives, see §5)
├─ docs/
│  ├─ CHANGELOG.md                   # rebuilt from ArchivedVersions history
│  ├─ HOOKS.md                       # every @wrapMethod/@replaceMethod target + why (patch checklist)
│  └─ nexus-description.bbcode       # from descripsPreemWeaponsmith.txt
├─ media/                            # (optional, or keep outside repo / Git LFS) screenshots, .xcf
└─ LICENSE
```

`red.config.json` (sketch):
```json
{
  "name": "PreemWeaponsmith",
  "version": "2.3.0",
  "license": true,
  "stage": "stage\\",
  "scripts": {
    "redscript": { "src": "src\\redscript\\PreemWeaponsmith", "debounceTime": 2000 }
  }
}
```
Set `REDCLI_GAME=S:\SteamLibrary\steamapps\common\Cyberpunk 2077` as a user environment variable. The redscript IDE also needs `game_dir` pointed at the same path in VS Code settings.

**Bootstrapping history:** import each `ArchivedVersions\PreemWeaponsmith<ver>.zip` in version order as its own commit, tagged `v1.0.3` … `v2.2.5`. That gives you real `git diff`/`git blame` across the mod's whole life. Sandbox and Blueprints variants go on their own tags, or get dropped if 2.x merged them through the settings menu.

---

## 4. Workflows

### A. One-time machine setup
1. **Clean the game install** (after doing the snapshot copy in step 4): delete `bin\x64\plugins\cybercmd.asi`, `bin\x64\version.dll`, `bin\x64\global.ini` (CyberTweaks), the old `red4ext\`, `r6\scripts\*` and `r6\cache` mod leftovers, then **Verify integrity** in Steam so you're on a clean 2.5.
2. Install the frameworks from §2 through Vortex/MO2: RED4ext, redscript, CET, Codeware, TweakXL, ArchiveXL, RedHotTools, and Mod Settings once it supports 2.5. Launch once and check `red4ext\logs` and `r6\logs\redscript_rCURRENT.log` for errors.
3. Install VS Code extension `jac3km4.redscript-ide-vscode`, red-cli (on PATH), and WolvenKit 9.1 (stable).
4. **Snapshot game scripts for diffing:** decompile `r6\cache\final.redscripts` (or the `.bk` backup that redscript leaves) with the redscript CLI into a separate local git repo (`S:\source\CyberpunkModding\game-scripts`). Commit one snapshot per patch. Your exe is dated Sept 2025 (probably 2.3x), so if Steam hasn't updated yet, **copy `r6\cache\final.redscripts` now, before updating**. That gives you a pre-2.5 baseline to diff against.

### B. Inner dev loop
```
code in VS Code (live diagnostics) → red-cli watch → RedHotTools hot-reloads → test in game (CET console)
```
For changes hot reload can't handle (new classes or fields, `@addField`), use `red-cli install` and restart the game.

### C. Upgrading after a game patch (this is your 2.5 job right now)
1. Wait for RED4ext, redscript, Codeware, TweakXL, ArchiveXL and Mod Settings to publish patch builds, then update them.
2. Snapshot and decompile the new game scripts, then `git diff` the snapshots, filtered to the classes listed in `docs/HOOKS.md`.
3. Open the repo in VS Code. Compile errors flag renamed or removed methods and changed signatures. Fix each `@wrapMethod` to match.
4. Check behaviour for wrapped methods whose signatures still compile but whose logic changed (2.5: dual-wield touches weapon, shooting and melee classes).
5. Check TweakDB IDs used in `Tweaking/` with WolvenKit's Tweak Browser, because records get renamed or added.
6. Playtest checklist (keep it in `docs/`): crafting screen opens, mod slots render in both layouts, install and remove mods, fire-mode changes, melee mods, Sandbox vs Blueprints unlock settings, save and reload.
7. Bump the version, update CHANGELOG, `red-cli pack`, tag `vX.Y.Z`, upload the zip to Nexus by hand.

### D. Release
`red-cli pack` creates `dist/PreemWeaponsmith-<ver>.zip` containing the bundled `r6/scripts/PreemWeaponsmith/*.reds` (one file per module) and LICENSE. Add the `.archive` (or Audioware files) into the zip if the mod still ships them. Nexus upload stays manual.

---

## 5. Issues to decide during the upgrade

1. **(Decided 2026-10-25: Audioware.)** **The sound `.archive` replaces a whole base-game file.** It overrides all of `cooked_metadata.audio_metadata`, so after 2.5 it may roll back CDPR's own sound changes, including any new dual-wield sounds, and conflict with every other audio mod. Options: **(a)** redo the fire-mode sounds through **Audioware** (preferred: no base-file override), or **(b)** re-export the 2.5 metadata in WolvenKit 9 and reapply your edits every patch.
2. **(Decided 2026-10-25: Mod Settings becomes optional, with our own per-save settings panel. See ROADMAP decisions log.)** **Mod Settings hasn't been updated for 2.5.** If it stays broken, either wait or add a fallback using `@if(ModuleExists("ModSettingsModule"))` so the mod still loads with defaults.
3. **Old working copy and dead code:** delete `PreemWeaponsmithTest`, `EditedModFiles\test`, the commented-out `Codeware/` folder, and the 2022 decompile once the repo exists.
4. **Sandbox and Blueprints variants:** confirm whether 2.x replaced them with the settings toggle. If so, you only need one release artifact.

---

### Sources
- Tool versions: GitHub releases for each repo linked above, queried 2026-10-25.
- [redscript wiki: setup](https://wiki.redmodding.org/redscript/getting-started/setup), [redscript-ide README](https://github.com/jac3km4/redscript-ide), [red-cli README](https://github.com/rayshader/cp2077-red-cli), [WolvenKit wiki: download](https://wiki.redmodding.org/wolvenkit/getting-started/download)
- Patch 2.5: [GameRant patch notes](https://gamerant.com/cyberpunk-2077-update-2-5-patch-notes/), [heise: mods on consoles](https://www.heise.de/en/news/Cyberpunk-2077-Update-2-5-brings-mods-to-PlayStation-5-and-Xbox-11496543.html), [DigitalCitizen: curated mods](https://www.digitalcitizen.life/cyberpunk-2077-update-2-5-console-mods-curated-modded-saves/)
