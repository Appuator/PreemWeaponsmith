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
| RED4ext | Loads the native plugins below (Codeware, TweakXL). | https://github.com/WopsS/RED4ext | 1.31.0 | 1.31.0 |
| redscript | Compiles our `.reds` hooks (`@wrapMethod`, `@addMethod`, `@addField`) into the game's script bundle at startup. | https://github.com/jac3km4/redscript | 0.5.32 | 0.5.32 |
| Codeware | Crafting UI built in code: `inkCustomController`, `CustomPopup` (`import Codeware.UI.*`), plus the script API extensions the adapters use. | https://github.com/psiberx/cp2077-codeware | 1.21.0 | 1.21.0 |
| TweakXL | `ScriptableTweak` and `TweakDBManager`, which create the Preem mod/slot records and the `_Preem<Evolution>` weapon variants (`Tweaking/`). Also loads `tweaks/*.yaml` after Phase 2. | https://github.com/psiberx/cp2077-tweak-xl | 1.12.0 | 1.12.0 |

## Runtime: optional
The mod works without these. When present, they add something.

| Dependency | Used for | Source | Minimum | Pinned |
|---|---|---|---|---|
| Mod Settings | Sets the defaults that a **new** save starts with (`@runtimeProperty("ModSettings.*")` in `Core/PreemModSettings.reds`). The per-save settings panel is our own; never required. | https://github.com/jackhumbert/mod_settings | 0.2.22 (first 2.5 build) | 0.2.22 |
| EnhancedCraft | Compatibility only: when present (`@if(ModuleExists("EnhancedCraft.Common"))`), we also create Preem variants of its weapon presets. Kept disabled except in compat tasks. | https://www.nexusmods.com/cyberpunk2077/mods/2592 | ⚠ first 2.5 build | Nexus download of 2026-10-25 (version not stated in the files). Compiles offline against 2.5; not yet booted. Kept in `S:\source\CyberpunkModding\downloads\2026-10-25_EnhancedCraft\`, not in the game folder. Needs Codeware, ArchiveXL and TweakXL |

Mod Settings itself needs RED4ext 1.31.0+, ArchiveXL 1.28.0+ and redscript 0.5.32+ (v0.2.22 release notes). So ArchiveXL becomes a runtime need for players who install Mod Settings.

## Dev runtime
Installed in the dev game folder only. Players never need these.

| Dependency | Used for | Source | Minimum | Pinned |
|---|---|---|---|---|
| Cyber Engine Tweaks (CET) | In-game console for `PreemDev` exec commands (verification layer 3). | https://github.com/maximegmd/CyberEngineTweaks | 1.38.0 | 1.38.0 |
| ArchiveXL | Needed by Mod Settings and RedHotTools. | https://github.com/psiberx/cp2077-archive-xl | 1.28.0 | 1.28.0 |
| RedHotTools | Hot reload of scripts and tweaks for `red-cli watch`, plus the ink/world inspector. | https://github.com/psiberx/cp2077-red-hot-tools | first 2.5 build | 1.3.0-rc.3 ❌ crashes 2.5 on load (2026-10-25); disabled, so `red-cli watch` is unavailable |
| RedTest | Unit-test harness for the pure rules (test seams in `CLAUDE.md`). Git submodule at `dev/redscript/RedTest`, pinned by commit. Needs Codeware. | https://github.com/rayshader/cp2077-red-test | — | `10a3c279` (2026-05-02). Compiles offline with redscript 0.5.32 against 2.5 (2026-10-25); in-game run not yet tested |
| Audioware | Debugging only (user, Phase 3 gate): `dev/redscript/PreemDev/PreemSoundListener.reds` counts the weapon sound events through its callbacks. The release doesn't use it (fire-mode sounds are set at load, ADR 0001); the release zip booted without it (2026-10-26). Players don't need it: never list it as a requirement of the release. `boot-check -Without` can't remove it (empty `versionFile`, and its scripts in `r6\scripts\Audioware` stay). | https://github.com/cyb3rpsych0s1s/audioware | 1.10.0 (first 2.5 build, 2026-10-26) | 1.10.1 (2026-10-26; 1.9.9 crashed 2.5 on load) |

## Dev tools
Run on the dev machine, outside the game.

| Tool | Used for | Source | Minimum | Pinned |
|---|---|---|---|---|
| red-cli | `install` / `watch` / `pack` from `red.config.json`. | https://github.com/rayshader/cp2077-red-cli | 0.5.1 | 0.5.1 |
| redscript CLI (`redscript-cli`) | Offline compile check against the vanilla 2.5 bundle; decompiling bundles. Ships with redscript. | https://github.com/jac3km4/redscript | 0.5.32 | 0.5.32 |
| redscript-ide (language server) | Live diagnostics, go-to-definition into game scripts, formatter. Config: `.redscript`. | https://github.com/jac3km4/redscript-ide | 0.2.25 | 0.2.25 |
| VS Code + Redscript IDE extension | Editor front end for redscript-ide (`jac3km4.redscript-ide-vscode`). | https://marketplace.visualstudio.com/items?itemName=jac3km4.redscript-ide-vscode | — | latest from the marketplace (it bundles redscript-ide) |
| redscript-dap | Breakpoint debugger, used through the IDE extension. | https://github.com/jac3km4/redscript-dap | first 2.5 build | 0.0.8 ❌ crashes 2.5 on load (2026-10-25); disabled |
| WolvenKit | Tweak Browser for TweakDB lookups. No longer packs anything: the `.archive` was retired in Phase 3 (fire-mode sounds are set at load, ADR 0001). | https://github.com/WolvenKit/WolvenKit | 9.1.0 | 9.1.0 (stable) |
| WolvenKit.Console (`WolvenKit.CLI.exe`) | `unbundle` and `convert serialize` for reading game files (how the sound event map was made). Its `build` of `wolvenkit/` is retired with the `.archive`. Needs only the .NET 10 base runtime. | https://github.com/WolvenKit/WolvenKit | 9.1.0 | 9.1.0 |
| .NET Desktop Runtime | Needed by the WolvenKit 9.1 GUI (WPF). | https://dotnet.microsoft.com/download/dotnet/10.0 | 10.0 | latest 10.0.x (10.0.14 installed 2026-10-25) |

## Game-folder pins (machine-readable)
`tools/install-deps.ps1` reads the JSON block below, and nothing else in this file. Keep it in step with the tables above.
- `sha256` is the release asset's digest as GitHub publishes it. The script refuses any file that doesn't match.
- `versionFile` + `version`: a file in the game folder whose Windows file version must start with `version`. Leave both empty when the file has no version resource.
- `bootLog`: where `tools/boot-check.ps1` sees the dependency load and reads its version. `red4ext`: the RED4ext log's own start line. `red4ext-plugin`: the RED4ext log line "<name> (version: X, ...) has been loaded"; add `logName` if the plugin calls itself something other than `name`, and `logVersion` if the pinned release logs a version other than `version` (Audioware 1.10.1 logs `1.10.1-rc.0`; check the DLL is the pinned zip's before adding one). `cet`: the "CET version" line in CET's log. `redscript`: "Compilation complete" in the redscript log. redscript logs no version, so the check compares `engine\tools\scc.exe` and `scc_lib.dll` with the pinned zip in the download cache. Not-loaded or version-mismatch fails the boot check; a disabled pin that loads fails it too.
- `enabled: false` keeps a pin listed but not installed. Say why in `note`.
- Not managed here: EnhancedCraft (Nexus only, copied in by compat tasks), RedTest (git submodule), and the dev tools outside the game folder.

<!-- install-deps:begin -->
```json
[
  { "name": "RED4ext",       "repo": "WopsS/RED4ext",                  "tag": "v1.31.0",      "asset": "red4ext-1.31.0.zip",            "sha256": "b9ae4351f547f90af58dfbf7445d45c55cd5ba24fbee27fb16fb5d91e9df621e", "versionFile": "red4ext/RED4ext.dll",                         "version": "1.31.0", "bootLog": "red4ext",        "enabled": true },
  { "name": "redscript",     "repo": "jac3km4/redscript",              "tag": "v0.5.32",      "asset": "redscript-v0.5.32-windows.zip", "sha256": "882c57a80b07e453bc8a34cd8430f460aceed789581de8743638e19dcfb7936f", "versionFile": "",                                            "version": "0.5.32", "bootLog": "redscript",      "enabled": true },
  { "name": "CET",           "repo": "maximegmd/CyberEngineTweaks",    "tag": "v1.38.0",      "asset": "cet_1_38_0.zip",                "sha256": "6da2e91b07d5ea9dd4aa32145b2c2920a976abee481854976e2ae82169b612e1", "versionFile": "bin/x64/plugins/cyber_engine_tweaks.asi",     "version": "1.38.0", "bootLog": "cet",            "enabled": true },
  { "name": "Codeware",      "repo": "psiberx/cp2077-codeware",        "tag": "v1.21.0",      "asset": "Codeware-1.21.0.zip",           "sha256": "a907110a0c6ac32f095f5178660b56799527cef710f7a88ae6c846e5f00bc8a8", "versionFile": "red4ext/plugins/Codeware/Codeware.dll",       "version": "1.21.0", "bootLog": "red4ext-plugin", "enabled": true },
  { "name": "TweakXL",       "repo": "psiberx/cp2077-tweak-xl",        "tag": "v1.12.0",      "asset": "TweakXL-1.12.0.zip",            "sha256": "a7c39b769e6c51d9f27412a101fb87e6a1fb8452f0e37ee0d1d1f3f44e656fa8", "versionFile": "red4ext/plugins/TweakXL/TweakXL.dll",         "version": "1.12.0", "bootLog": "red4ext-plugin", "enabled": true },
  { "name": "ArchiveXL",     "repo": "psiberx/cp2077-archive-xl",      "tag": "v1.28.0",      "asset": "ArchiveXL-1.28.0.zip",          "sha256": "a4f02416a5f1547f2529de3b2b4a23eddde0f40d511b009fc93635ba2db6e8e1", "versionFile": "red4ext/plugins/ArchiveXL/ArchiveXL.dll",     "version": "1.28.0", "bootLog": "red4ext-plugin", "enabled": true },
  { "name": "Mod Settings",  "repo": "jackhumbert/mod_settings",        "tag": "v0.2.22",      "asset": "mod_settings_v0.2.22.zip",      "sha256": "34b2ac460788c02f09ca43aff0c88721692258f4155bf09eb69cc6e5a172dd4f", "versionFile": "red4ext/plugins/mod_settings/mod_settings.dll", "version": "0.2.22", "bootLog": "red4ext-plugin", "enabled": true },
  { "name": "RedHotTools",   "repo": "psiberx/cp2077-red-hot-tools",   "tag": "v1.3.0-rc.3",  "asset": "RedHotTools-1.3.0.zip",         "sha256": "310f36ab45f9c5c8c637586cf319d07c72c812a614825652a6fd8fd9ba80a5a4", "versionFile": "red4ext/plugins/RedHotTools/RedHotTools.dll", "version": "1.3.0",  "bootLog": "red4ext-plugin", "enabled": false, "note": "crashes 2.5 on load (2026-10-25)" },
  { "name": "Audioware",     "repo": "cyb3rpsych0s1s/audioware",       "tag": "v1.10.1",      "asset": "Audioware-windows-v1.10.1.zip", "sha256": "7b0d42ca4d706780aa9b44530c007c17310adbfb822b056e098391b65662fb93", "versionFile": "",                                            "version": "1.10.1", "bootLog": "red4ext-plugin", "enabled": true, "logVersion": "1.10.1-rc.0", "note": "the release DLL tells RED4ext 1.10.1-rc.0 (its build.rs encodes a release as pre-release type 3)" },
  { "name": "redscript-dap", "repo": "jac3km4/redscript-dap",          "tag": "v0.0.8",       "asset": "redscript_dap.dll",             "sha256": "02630282d6090bc1380c6d7ecc01e6f111b0cd4a726376fab5784db2afc7dcf2", "versionFile": "",                                            "version": "0.0.8",  "bootLog": "red4ext-plugin", "enabled": false, "note": "crashes 2.5 on load (2026-10-25)", "target": "red4ext/plugins/redscript_dap.dll" }
]
```
<!-- install-deps:end -->

## Updating for a new game patch
1. Check each runtime and dev-runtime project for a build that names the new patch. Mod Settings, Audioware, EnhancedCraft and RedTest have historically lagged behind the others.
2. Update the **Pinned** (and, if the patch forces it, **Minimum**) columns here, with the date. Update the JSON pin block too: `tag`, `asset`, `sha256` (from the release page or `https://api.github.com/repos/<repo>/releases/tags/<tag>`, field `digest`) and `version`. Set `enabled` back to `true` for a ❌ pin once a build for the patch ships.
3. Run `tools/install-deps.ps1` (add `-DryRun` first to see the plan), then the boot check. Record the installed versions in `HANDOFF.md` §3.
