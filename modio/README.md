# modio/

Inputs for the mod.io (console / cross-platform) build that only the mod.io build needs. The build itself is generated from the PC source (`src/redscript/PreemWeaponsmith/`, `tweaks/`) and never edited by hand ([ADR 0003](../docs/adr/0003-modio-build-derived-from-pc-source.md)). Features and fixes go into the PC source, not here.

- `manifest.json`: every `.reds` file under `src/redscript/PreemWeaponsmith/` (path relative to it), with an action:
  - `convert`: goes into the mod.io build;
  - `pc-only`: left out (Codeware UI, records made at load, Mod Settings).

  A new source file needs an entry, or `tools/modio-compile-check.ps1` stops.
- Planned in Phase 9: `overrides/` (small console stand-ins for PC-only code, each naming the PC file it follows) and `tweaks/` (records baked from a PC run's record dump).

The build goes to `stage/modio/`, which is generated and ignored by git. Check it with `pwsh tools/modio-compile-check.ps1`, which compiles it with CDPR's official compiler (`<game>\tools\redmod\bin\scc.exe`). Background: `notes/modio-port.md`.
