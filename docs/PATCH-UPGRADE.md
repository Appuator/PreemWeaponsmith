# Patch upgrade runbook

What to do when Cyberpunk 2077 gets a new patch (or a framework gets a new build). Each step says what it proves and what "unchanged" looks like on today's build (patch 2.5, Steam build 26161058, pins of 2026-10-25/26). A number that moves is something to explain before shipping.

Never run an install step or a boot while the game is running or the user is playing. Commands run from the repo root in `pwsh`. Game boots and long log reads go to a subagent that reports only success or the first real error (CLAUDE.md).

## Expected numbers on today's build
| Check | Command | Unchanged result |
|---|---|---|
| Pins | `tools/install-deps.ps1 -DryRun` | every enabled pin "up to date"; RedHotTools and redscript-dap "disabled" |
| Tooling tests | `Invoke-Pester tools/tests` | 42 passed |
| Compile | `tools/compile-check.ps1` | 0 errors, 4 warnings (also `-WithEnhancedCraft`) |
| Boot + self-check + RedTest | `tools/tweak-dump.ps1` (boots through `boot-check.ps1`) | dependency check OK, self-check 4136/0, RedTest 113/113, no record-dump differences |
| Sound fills at load | same boot, `[PreemWeaponsmith] sound sets:` lines | 199 fields in `base`, 23 in `ep1` |
| EnhancedCraft | `tools/boot-check.ps1 -WithEnhancedCraft` | self-check 11411/0, RedTest 113/113 |
| Vanilla markers | `tools/variant-markers.ps1` | 1340 `Items.Preset_*` variants; `statModifierGroups` 1007 keep / 565 lack, `slotPartList` 562, `rangedAttacks` 218, `OnAttach` 212, `statPools` 113, `audioSwitchName`/`Value` 98, `primaryTriggerMode` 82, `placementSlots` 20, prices 13, `attacks` 12 |
| Crafting end to end | `tools/boot-check.ps1 -LoadSave -Run dev/cet/craft-e2e.lua -HoldSec 50` | 3/3 `e2e: PASS` |
| Sound sweep | `tools/boot-check.ps1 -LoadSave -Run dev/cet/sound-sweep.lua -HoldSec 965` | 105/105 rows play their expected event on the player's weapon (last full pass 2026-10-26 14:23). Open: on the 2026-10-26 walk, row 3 (Ashura, Full-Auto, `w_gun_smg_smart_sidewinder_fire_auto`) played nothing in 3 runs (104/105); Testera Full-Auto missed once in 2 runs |

Update this table whenever a phase changes one of these numbers.

## 1. Before the patch lands
1. Stop Steam from updating the game on its own (game Properties → Updates → "Only update this game when I launch it"), so the patch comes when you are ready for it.
2. Check that today's build still passes: run the table above, or at least the boot row. A failure that is already there is not the patch's.
3. Watch the frameworks' release pages (`docs/DEPENDENCIES.md` "Source" column). RED4ext, redscript, Codeware and TweakXL all need a build for the new patch before the mod can load; Mod Settings, ArchiveXL, CET and Audioware too for the dev setup.

## 2. Update the game and snapshot it
1. Update the game in Steam. Note the new build: `"buildid"` in `S:\SteamLibrary\steamapps\appmanifest_1091500.acf`.
2. Copy the vanilla `r6\cache\final.redscripts`, `r6\cache\tweakdb.bin` and `r6\cache\tweakdb_ep1.bin` to `S:\source\CyberpunkModding\game-snapshots\<patch>_build<n>\`. redscript 0.5.32 writes the modded bundle to `final.redscripts.modded` and leaves `final.redscripts` vanilla, but copy before the first modded launch anyway (an older redscript overwrites it).
3. Add the patch to `S:\source\CyberpunkModding\game-scripts` (local only, never publish): the steps are in its README ("Adding a patch"); tag it with the patch name.

## 3. Diff the hooked classes
1. List every class in `docs/HOOKS.md` (wrapped methods first: their logic can change while the signature still compiles).
2. In `game-scripts`, find each class's file and diff it against the previous tag:
   ```
   git grep -l "class CraftingSystem " <new-tag> -- scripts
   git diff <old-tag> <new-tag> -- <path after the "<new-tag>:" prefix>
   ```
   Example (2.5): `git grep` prints `2.5:scripts/core/systems/craftingSystem.script`; `git diff pre-2.5 2.5 -- scripts/core/systems/craftingSystem.script` prints nothing, so 2.5 didn't change `CraftingSystem`.
   Or the whole patch at once: `git diff --stat <old-tag> <new-tag>`.
3. For each changed wrapped method, read what changed and decide whether our wrapper still does the right thing. Note anything that needs a fix as a task.
4. Check the TweakDB records `Tweaking/` and `tweaks/*.yaml` refer to (base weapons, stat groups, `AttachmentSlots.*`) with WolvenKit's Tweak Browser, or let the self-check and record dump in step 6 find them.

## 4. Bump the pins
1. In `docs/DEPENDENCIES.md`, update the tables and the JSON block for every framework with a new build: `version`, the release asset, its `sha256` from GitHub, `versionFile`/`logVersion` if they changed. Re-enable a pin that was `enabled: false` once its new build is out (RedHotTools, redscript-dap), and test it.
2. `pwsh tools/install-deps.ps1 -DryRun` lists what will change; then `pwsh tools/install-deps.ps1` (`-Only <names>` for some).
3. `pwsh -c "Invoke-Pester tools/tests"`.

## 5. Compile
1. `pwsh tools/compile-check.ps1`, then `pwsh tools/compile-check.ps1 -WithEnhancedCraft`. Errors here are renamed or removed game methods and changed signatures: fix each hook against the diff from step 3.
2. Dev code too: in a `pwsh` session, `& ./tools/compile-check.ps1 -Extra @('dev/redscript/PreemDev','dev/redscript/RedTest','<game>\r6\scripts\Audioware')`.

## 6. Boot, self-check, record dump
1. `pwsh tools/install.ps1`, then `pwsh tools/dev-install.ps1`.
2. `pwsh tools/tweak-dump.ps1`: boots to the main menu, checks the dependency pins, runs the self-check and RedTest, and compares every `Items.Preem*`/`AttachmentSlots.Preem*` flat with `dev/baseline/tweak-dump.txt`. Look for the sound load lines in its output. Never re-save the baseline to make a difference go away.
3. `pwsh tools/boot-check.ps1 -WithEnhancedCraft`.
4. `pwsh tools/variant-markers.ps1` and compare its counts with the table. New kinds or bigger counts mean the patch changed the vanilla weapons the variants copy.

## 7. In a loaded save
These take keyboard focus (the boot check presses Space on the loading screen) and load the newest save. The game autosaves during these runs (the 2026-10-26 walk made `AutoSave-12` to `-15`), so the next `-LoadSave` loads that autosave, not the test save: the player's state drifts from run to run. Compare against a run from the same save when a row fails.
1. `pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/craft-e2e.lua -HoldSec 50`.
2. Sound sweep, about 19 minutes, so run it in the background: `pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/sound-sweep.lua -HoldSec 965`. Count `[PreemDev] sound: <event> on player's weapon <record>` lines against each row's `expect`. If the load lines in step 6 showed fewer than 199 + 23 fields, the patch filled some sound fields itself: rebuild the event map (`notes/audioware-sounds.md`) before the sweep.

## 8. Human check and release
1. 🧑 Play: crafting screen opens and looks right, mods install and remove, fire modes and their sounds, melee mods, save and reload.
2. Bump the version, add a CHANGELOG entry (the new patch and new pins), then `pwsh tools/pack-release.ps1` (never `red-cli pack`, HANDOFF §4). Install only the zip and boot once without dev code (`tools/dev-install.ps1 -Uninstall`). Tag `vX.Y.Z`; push and upload only with the user's yes.
3. Update the "Expected numbers" table, `docs/DEPENDENCIES.md`'s "Versions checked" line, HANDOFF §3 (versions) and `game-scripts`' README table.
