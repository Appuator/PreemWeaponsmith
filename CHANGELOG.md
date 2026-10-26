# Changelog

Releases before 2.3.0 are in the git tags (`v1.0.0` to `v2.2.5`) and on the Nexus page; they get backfilled here in Phase 4.

## 2.3.0 (release candidate, not published)

**For Cyberpunk 2077 patch 2.5.** Requirements and versions: `docs/DEPENDENCIES.md`.

**Saves:** saves that used an earlier version of Preem Weaponsmith (or an earlier game patch) are not supported. Start a new save with 2.3.0.

### Changed
- Runs on game patch 2.5 with current frameworks (RED4ext 1.31, redscript 0.5.32, Codeware 1.21, TweakXL 1.12, ArchiveXL 1.28).
- Mod Settings is now optional. Without it the mod uses its built-in defaults (unlock = Weapon Blueprints, limit = Sandbox, slots on the weapon). With it, its page sets the defaults a new save starts with.
- Settings are stored per save: each playthrough keeps its own unlock mode, limit mode and slot layout.
- The crafting screen's Preem frame also reacts to touch input (tap), like the rest of the 2.5 crafting screen.
- The fixed mod, stat, slot and blueprint records are now TweakXL YAML files in `r6/tweaks/PreemWeaponsmith/` instead of script code. Record IDs and values are unchanged. When updating by hand, copy both `r6/scripts/PreemWeaponsmith` and `r6/tweaks/PreemWeaponsmith`.

### Fixed
- Crafting a weapon with a Smart, Tech or Power barrel no longer fails when that weapon has no matching evolution variant; it is crafted as it is.
- Some NPC-only weapons (for example Adam Smasher's launcher) no longer get stray evolution variants created at random.
- The second trigger slot (`AttachmentSlots.PreemTriggerMod02`) pointed at the first slot's entity slot name.

### Removed
- The bundled, commented-out copy of Codeware. Codeware itself is a required dependency.

### Breaking (save-visible)
- `AttachmentSlots.PreemTriggerMod02.entitySlotName` changed from `PreemTriggerMod01` to `PreemTriggerMod02`.

### Known issues (release blockers for this candidate)
- The sound archive (`archive/pc/mod/PreemWeaponsmith.archive`) replaces the game's whole `cooked_metadata.audio_metadata` with a copy from patch 2.12. On 2.5 that removes 32 vanilla audio entries and reverts 446 changed ones. Decide before publishing: ship without it (`pwsh tools/pack-release.ps1 -NoArchive`), rebuild it on 2.5's file, or wait for the Audioware move (Phase 3).
- (Resolved in Phase 1: crafting end to end, the settings store across save/load and the settings panel were run in a loaded game.)
