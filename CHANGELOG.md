# Changelog

Releases before 2.3.0 are in the git tags (`v1.0.0` to `v2.2.5`) and on the Nexus page; they get backfilled here in Phase 4.

## 2.3.0 (release candidate, not published)

**For Cyberpunk 2077 patch 2.5.** Requirements and versions: `docs/DEPENDENCIES.md`.

**Saves:** saves that used an earlier version of Preem Weaponsmith (or an earlier game patch) are not supported. Start a new save with 2.3.0.

### Changed
- Runs on game patch 2.5 with current frameworks (RED4ext 1.31, redscript 0.5.32, Codeware 1.21, TweakXL 1.12, ArchiveXL 1.28).
- Mod Settings is now optional. Without it the mod uses its built-in defaults (unlock = Weapon Blueprints, limit = Sandbox, slots on the weapon). With it, its page sets the defaults a new save starts with.
- Settings are stored per save: each playthrough keeps its own unlock mode, limit mode and slot layout.
- Balance: Turbocharger now halves a Tech weapon's charge time and Omega Charge doubles it, the same on every weapon. Before, both scaled with the weapon's own charge time, so the effect differed from weapon to weapon (on long-charging weapons Turbocharger could cut it to nothing).
- The crafting screen's Preem frame also reacts to touch input (tap), like the rest of the 2.5 crafting screen.
- The fixed mod, stat, slot and blueprint records are now TweakXL YAML files in `r6/tweaks/PreemWeaponsmith/` instead of script code. Record IDs and values are unchanged. When updating by hand, copy both `r6/scripts/PreemWeaponsmith` and `r6/tweaks/PreemWeaponsmith`.
- Fire-mode sounds (auto-fire loop and stop, burst, charge, and their suppressed versions) now come from the game's own 2.5 sound data: at load the mod fills only the sound fields a weapon leaves empty, with existing sounds of other weapons, the same choices as 2.2.5. Every other weapon sound stays as the game ships it.
- Weapons that had no auto-fire sound in 2.2.5 now get one with the Full-Auto trigger: Achilles, Chao (also Voodoo), Crusher, Kenshin (also Royce's), Masamune (also suppressed), Senkoh (also the prototype), Shingen, Malorian Arms 3516, Ticon (also Reed's). The Toygun gets burst and charge sounds, and the Borg4a a charge sound. Each borrows an existing sound of a similar weapon.
- Tech weapons that aren't pistols (Achilles, Senkoh, Nekomata, Rasetsu, Satara) use the Pozhar's auto-fire sound with the Full-Auto trigger. In 2.2.5, Nekomata, Rasetsu and Satara used the Quasar's.

### Fixed
- Crafting a weapon with a Smart, Tech or Power barrel no longer fails when that weapon has no matching evolution variant; it is crafted as it is.
- Some NPC-only weapons (for example Adam Smasher's launcher) no longer get stray evolution variants created at random.
- The second trigger slot (`AttachmentSlots.PreemTriggerMod02`) pointed at the first slot's entity slot name.

### Removed
- The bundled, commented-out copy of Codeware. Codeware itself is a required dependency.
- The sound archive `archive/pc/mod/PreemWeaponsmith.archive`, which replaced the game's whole weapon sound data with a copy from patch 2.12. When updating, delete that file from the game folder, or it keeps overriding the 2.5 sounds.

### Breaking (save-visible)
- `AttachmentSlots.PreemTriggerMod02.entitySlotName` changed from `PreemTriggerMod01` to `PreemTriggerMod02`.

### Known issues (release blockers for this candidate)
- (Resolved in Phase 1: crafting end to end, the settings store across save/load and the settings panel were run in a loaded game.)
