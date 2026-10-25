# Dependencies

Every dependency of Preem Weaponsmith, what it is for and which version we pin.
`tools/install-deps.ps1` (Phase 0) installs the **Pinned** column, and the boot check fails when an installed version differs from it. To move to a new game patch, bump the pins here first, then run the script.

- **Minimum**: the oldest version the mod is known to work with. For frameworks tied to a game patch, that is their first build for patch 2.5.
- **Pinned**: the version we develop and test against. Versions marked ⚠ are not yet confirmed on 2.5. Versions marked ❌ were tried and crash 2.5, so they stay out of the game folder (in `game-folder-backup\disabled\`) until a new build ships.
- Versions checked 2026-10-25 against each project's GitHub releases (Nexus for EnhancedCraft). Game: patch 2.5, Steam build 26161058.

## Runtime: required
Players need all of these. They go on the Nexus page as requirements.

| Dependency | Used for | Source | Minimum | Pinned |
|---|---|---|---|---|
| RED4ext | Loads the native plugins below (Codeware, TweakXL, Audioware). | https://github.com/WopsS/RED4ext | 1.31.0 | 1.31.0 |
| redscript | Compiles our `.reds` hooks (`@wrapMethod`, `@addMethod`, `@addField`) into the game's script bundle at startup. | https://github.com/jac3km4/redscript | 0.5.32 | 0.5.32 |
| Codeware | Crafting UI built in code: `inkCustomController`, `CustomPopup` (`import Codeware.UI.*`), plus the script API extensions the adapters use. | https://github.com/psiberx/cp2077-codeware | 1.21.0 | 1.21.0 |
| TweakXL | `ScriptableTweak` and `TweakDBManager`, which create the Preem mod/slot records and the `_Preem<Evolution>` weapon variants (`Tweaking/`). Also loads `tweaks/*.yaml` after Phase 2. | https://github.com/psiberx/cp2077-tweak-xl | 1.12.0 | 1.12.0 |
| Audioware *(from Phase 3)* | Adds the fire-mode sound events without overriding the base game's `audio_metadata` (SPEC §6). Not needed by the current build. | https://github.com/cyb3rpsych0s1s/audioware | first 2.5 build | 1.9.9 ❌ crashes 2.5 on load (2026-10-25); disabled until a 2.5 build ships |

## Runtime: optional
The mod works without these. When present, they add something.

| Dependency | Used for | Source | Minimum | Pinned |
|---|---|---|---|---|
| Mod Settings | Sets the defaults that a **new** save starts with (`@runtimeProperty("ModSettings.*")` in `Core/PreemModSettings.reds`). The per-save settings panel is our own; never required. | https://github.com/jackhumbert/mod_settings | 0.2.22 (first 2.5 build) | 0.2.22 |
| EnhancedCraft | Compatibility only: when present (`@if(ModuleExists("EnhancedCraft.Common"))`), we also create Preem variants of its weapon presets. Kept disabled except in compat tasks. | https://www.nexusmods.com/cyberpunk2077/mods/2592 | ⚠ first 2.5 build | 4.0.4 ⚠ (last known, 2024-12; 2.5 build unconfirmed) |

Mod Settings itself needs RED4ext 1.31.0+, ArchiveXL 1.28.0+ and redscript 0.5.32+ (v0.2.22 release notes). So ArchiveXL becomes a runtime need for players who install Mod Settings.

## Dev runtime
Installed in the dev game folder only. Players never need these.

| Dependency | Used for | Source | Minimum | Pinned |
|---|---|---|---|---|
| Cyber Engine Tweaks (CET) | In-game console for `PreemDev` exec commands (verification layer 3). | https://github.com/maximegmd/CyberEngineTweaks | 1.38.0 | 1.38.0 |
| ArchiveXL | Needed by Mod Settings and RedHotTools. Our `.archive` doesn't need it. | https://github.com/psiberx/cp2077-archive-xl | 1.28.0 | 1.28.0 |
| RedHotTools | Hot reload of scripts and tweaks for `red-cli watch`, plus the ink/world inspector. | https://github.com/psiberx/cp2077-red-hot-tools | first 2.5 build | 1.3.0-rc.3 ❌ crashes 2.5 on load (2026-10-25); disabled, so `red-cli watch` is unavailable |
| RedTest | Unit-test harness for the pure rules (test seams in `CLAUDE.md`). A git submodule under `dev/`, pinned by commit. | https://github.com/rayshader/cp2077-red-test | — | `10a3c279` (2026-05-02, "support redscript v0.5.31") ⚠ predates redscript 0.5.32 / 2.5 |

## Dev tools
Run on the dev machine, outside the game.

| Tool | Used for | Source | Minimum | Pinned |
|---|---|---|---|---|
| red-cli | `install` / `watch` / `pack` from `red.config.json`. | https://github.com/rayshader/cp2077-red-cli | 0.5.1 | 0.5.1 |
| redscript CLI (`redscript-cli`) | Offline compile check against the vanilla 2.5 bundle; decompiling bundles. Ships with redscript. | https://github.com/jac3km4/redscript | 0.5.32 | 0.5.32 |
| redscript-ide (language server) | Live diagnostics, go-to-definition into game scripts, formatter. Config: `.redscript`. | https://github.com/jac3km4/redscript-ide | 0.2.25 | 0.2.25 |
| VS Code + Redscript IDE extension | Editor front end for redscript-ide (`jac3km4.redscript-ide-vscode`). | https://marketplace.visualstudio.com/items?itemName=jac3km4.redscript-ide-vscode | — | latest from the marketplace (it bundles redscript-ide) |
| redscript-dap | Breakpoint debugger, used through the IDE extension. | https://github.com/jac3km4/redscript-dap | first 2.5 build | 0.0.8 ❌ crashes 2.5 on load (2026-10-25); disabled |
| WolvenKit | Packs `wolvenkit/` into `PreemWeaponsmith.archive`; Tweak Browser for TweakDB lookups. Retired for packing once Phase 3 lands. | https://github.com/WolvenKit/WolvenKit | 9.1.0 | 9.1.0 (stable) |
| .NET Desktop Runtime | Needed by WolvenKit 9.1. | https://dotnet.microsoft.com/download/dotnet/10.0 | 10.0 | latest 10.0.x |

## Updating for a new game patch
1. Check each runtime and dev-runtime project for a build that names the new patch. Mod Settings, Audioware, EnhancedCraft and RedTest have historically lagged behind the others.
2. Update the **Pinned** (and, if the patch forces it, **Minimum**) columns here, with the date.
3. Run `tools/install-deps.ps1`, then the boot check. Record the installed versions in `HANDOFF.md` §3.
