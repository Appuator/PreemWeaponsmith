# Preem Weaponsmith

Cyberpunk 2077 mod that adds a weapon-mod crafting system (barrels, triggers, magazines, blades, handles) to the crafting screen.
Nexus: https://www.nexusmods.com/cyberpunk2077/mods/9692

## Layout

| Path | Contents |
|---|---|
| `src/redscript/PreemWeaponsmith/` | redscript source, installed to `r6/scripts/PreemWeaponsmith/` |
| `tweaks/` | TweakXL records, installed to `r6/tweaks/PreemWeaponsmith/` |
| `archive/`, `wolvenkit/` | retired sound archive (up to 2.2.5) and its WolvenKit project; not shipped since 2.3.0, kept as the source of the fire-mode sound table (`notes/audioware-sounds.md`) |
| `docs/` | toolchain/workflow notes, game hook list, Nexus description |
| `red.config.json` | [red-cli](https://github.com/rayshader/cp2077-red-cli) config (`install`, `watch`, `pack`) |
| `.redscript` | Redscript IDE language-server config |

## Requirements (runtime)

Required: RED4ext, redscript, Codeware, TweakXL. Audioware is a dev-only dependency (sound debugging); players don't need it. Optional: Mod Settings, EnhancedCraft. Versions, sources and dev tools are listed in [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md).

## Dev setup

1. Set the user environment variable `REDCLI_GAME` to the game folder, e.g. `S:\SteamLibrary\steamapps\common\Cyberpunk 2077`.
2. Open this folder in VS Code and install the recommended Redscript IDE extension; point its game directory setting at the same folder.
3. `pwsh tools/install.ps1` to deploy (scripts via `red-cli install`, plus the TweakXL YAML), `red-cli watch` for hot reload (needs RedHotTools, which crashes patch 2.5, so not available for now), `pwsh tools/pack-release.ps1` to build the release zip `dist/PreemWeaponsmith-<version>.zip`. Never ship a `red-cli pack` zip: red-cli 0.5.1 leaves the mod code out.

## New game patch

Follow [docs/PATCH-UPGRADE.md](docs/PATCH-UPGRADE.md): bump the pins, snapshot and diff the game scripts, then compile, boot, record dump, marker comparison and sound sweep, with the numbers to expect.

## History

Releases 1.0.0 to 2.2.5 were imported from the original release zips; each is tagged `vX.Y.Z`. 2.2.6 (Nexus, for patch 2.12) is the commit "Rebuild sound archive", tagged `v2.2.6`. In 2.0.1 to 2.2.4 the mod shipped as two variants that differ only in the default unlock mode: the main line uses the Blueprints variant (the 2.2.5 default), and the Sandbox builds are tagged `vX.Y.Z-sandbox`.
