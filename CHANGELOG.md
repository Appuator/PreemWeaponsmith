# Changelog

Newest first. Every release has a git tag `vX.Y.Z`; from 2.0.1 to 2.2.4 the Sandbox build is tagged `vX.Y.Z-sandbox` and differs only in the default unlock mode. Entries before 2.3.0 were written in 2026 from the Nexus changelog (2.2.0 to 2.2.4, quoted there) and from the code differences between tags (everything else), so they describe what changed, not always why.

## Unreleased

### Changed
- The Integral Silencer now goes in a barrel slot like the other barrel mods, instead of the muzzle slot. A hidden part fills the muzzle slot while it is installed, so guns still play their suppressed shot. Weapons crafted with 2.4.x keep their Silencer; it moves to a barrel slot the next time you apply mods to them. A muzzle brake stays on the gun with the Silencer, and you can still change it on the weapon mod screen (with the Silencer on, the gun keeps the brake's stats and plays its suppressed shot). A vanilla silencer also stays. On guns that have no muzzle in the base game, the vanilla weapon mod screen and tooltips no longer show the muzzle slot.

### Fixed
- The Grad (and Panam's Grad) with the Integral Silencer made no shot sound. It now plays the Grad's suppressed shot.
- Every other gun that went silent with the Integral Silencer (Kenshin, Burya, Shingen, Sidewinder, Nekomata, Carnage, Testera, Ticon, Achilles and more) now plays a suppressed shot: its own where the game has one, otherwise the one the mod used up to 2.2.5.

## 2.4.1 (release candidate, not published)

**For Cyberpunk 2077 patch 2.5**, same requirements as 2.3.0 (`docs/DEPENDENCIES.md`). Saves from 2.3.0 and 2.4.0 keep working: no Preem record was renamed or removed. Replace both `r6/scripts/PreemWeaponsmith` and `r6/tweaks/PreemWeaponsmith` (new file `evolution-stats.yaml`).

### Changed
- Balance: a weapon converted by a Smart, Tech or Power barrel now has the DPS and headshot damage of a real weapon of its new type, not its old one. The game lowers DPS by 20% on Smart weapons and 10% on Tech weapons and gives Smart weapons lower headshot damage; converted weapons used to keep their original type's values (a Power pistol turned Smart did full damage, a Smart gun turned Power kept -20% and the Smart headshot penalty). Every other stat stays as on the original weapon. Weapons already crafted change on the next load.
- A Tech weapon converted by a Smart or Power barrel keeps its Charge fire mode (it charges at its own charge time; Turbocharger, Omega Charge and the Charge triggers still need the Tech barrel). Converted Tech weapons used to lose it.
- Balance: Smart Barrel shots hit like most vanilla Smart guns: every shot with Smartlink and 70% without it (was 80% and 60%, the Sidewinder's), and they fire the same smart bullet as most Smart guns (the Sidewinder's before). They also fly at the usual Smart gun speed, 60 with Smartlink and 40 without (was 50 and 30).
- Balance: the Xtra Barrel now doubles damage per shot. Its extra projectiles used to split the same damage (each one did half), so it only added recoil; now every projectile does full damage.

## 2.4.0 (release candidate, not published)

**For Cyberpunk 2077 patch 2.5**, same requirements as 2.3.0 (`docs/DEPENDENCIES.md`). Saves from 2.3.0 keep working; only `r6/scripts/PreemWeaponsmith` changed.

### Added
- Preem mods on the crafting screen's Upgrades tab. The same slots appear as a row under the comparison panels and show the mods the selected weapon already has. Add, swap or remove mods there; removed or replaced mods are deleted, not refunded (mods cost nothing).
- Iconic weapons can take Preem mods (every mod but the evolution barrels, trigger mods included). Upgrading an iconic installs the chosen mods together with the upgrade.
- The Upgrades tab also lists every other weapon you own and fully upgraded iconics (the game lists only iconics it can still upgrade). For those the button reads APPLY: it installs the chosen mods at no cost and does not upgrade the weapon.
- With the Weapon Blueprints unlock and limit systems, the Upgrades tab uses the rarity after the upgrade; the button is blocked when the chosen mods exceed the limit or don't go together.

### Changed
- Evolution barrels (Smart, Tech, Power) stay crafting-only: on the Upgrades tab they show disabled, because an owned weapon can't change its type.
- The slot frame and its popups are one component shared by both tabs (no visible change on the Crafting tab). The Upgrades tab has no SETTINGS button; use the one on the Crafting tab.

### Fixed
- Clicking an item on the Upgrades tab no longer runs the Crafting tab's Preem selection code (both tabs share the click handler the mod wraps).

## 2.3.0 (Nexus, 2026-10-26)

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

## 2.2.6 (Nexus, 2024-04-27)
For game patch 2.12. Nexus: "updated for 2.12". Tagged `v2.2.6` in 2026 on commit `7933489` ("Rebuild sound archive", whose message still says "unreleased"): 2.2.5's scripts with the sound archive rebuilt from the 2.12 sound data.

## 2.2.5 (2023-11-11)
- One build for both progression styles: the unlock mode and mod limit are Mod Settings options (default limit Sandbox). The separate Sandbox and Blueprints downloads end here.
- Removed the "Technical Ability" mod limit mode and its "Limit Increase Per Technical Ability Level" setting.

## 2.2.4 (2023-11-03)
From the Nexus changelog:
- Fixed the sound of burst fire on silenced Tech weapons.
- Fixed the Crit Chance and Crit Damage blade mods, now 25% and 50% (the numbers apply but don't show on the weapon).
- Smart weapons aim at heads again when switching to ADS.

## 2.2.3 (2023-10-11)
From the Nexus changelog:
- Fixed the Compensator Barrel and Vented Barrel.
- Weapons crafted with the Tech barrel have a reticle again.
- Compensator Barrel: 40% recoil reduction, stacking additively up to 80% (was 60%).

## 2.2.2 (2023-10-08)
From the Nexus changelog:
- Tech weapons no longer switch to the wrong fire mode.

## 2.2.1 (2023-10-08)
From the Nexus changelog: fixed a merge problem that left the Blueprints build un-updated. Nexus also lists a 2.2.0 (no zip or tag exists for it), which added the Turbocharger, Omega Charge, Velocity Booster and Corkscrew Rifling barrels, the Quick Mag magazine, the Deflector Frame blade and the Lightweight Handle. In the code, those mods first appear in 2.1.2; in 2.2.1:
- High Caliber is renamed Velocity Booster (+25% headshot, +50% weak-spot damage) and Accelerator becomes Corkscrew Rifling (wider ricochet angles and path correction).
- Rebalanced: Turbocharger 25% faster charge (was 75%), Quick Mag 30% faster reload (was 50%), Deflector Frame 40% less blocking stamina (was 90%), Lightweight Handle 20% less stamina (was 50%). Omega Charge no longer removes the penetration damage penalty.

## 2.1.2 (2023-10-07)
- New mods: Turbocharger and Omega Charge (Tech barrels), High Caliber and Accelerator (Power barrels), Quick Mag (magazine), Deflector Frame (blade).
- Smart-Link RAM also locks on 50% faster. Lightweight Handle 50% less stamina (was 20%).

## 2.1.1 (2023-10-01)
- Chemical rounds and the Chem blade deal Chemical damage; bleed rounds' values fixed. Sound archive updated.

## 2.1.0 (2023-09-30)
- The Tech barrel takes its stats from the Achilles (2.0 Tech stats) instead of the pre-2.0 records; the Charge trigger's old charge-time bonus is gone.
- The sound archive is back, rebuilt for 2.0.

## 2.0.1 (2023-09-28)
- Stat records cloned from records that game patch 2.0 changed now use stable bases; the Smart barrel takes the game's own Smart weapon stats. First release with separate Sandbox and Blueprints builds.

## 2.0.0 (2023-09-27)
For game patch 2.0.
- Mod unlocks reworked for the 2.0 perk tree: the per-tier perk settings are gone; the mod limit can grow with Technical Ability level instead of Crafting level.
- The sound archive is left out of this release.

## 1.9.0 (2023-09-19)
- New unlock mode "Weapon Blueprints", the new default: which mods a weapon can take depends on its blueprint's rarity (Common to Legendary). The other modes are Sandbox and Crafting Perks.
- Rebalanced: Xtra Barrel doubles recoil instead of cutting fire rate; Turbo Barrel +20% fire rate (was 30%); Smart-Link GPU -75% targeting area (was 50%); elemental rounds 15% and elemental blades 20% status chance (were 25%).

## 1.8.0 (2023-09-04)
- First sound archive (`PreemWeaponsmith.archive`): fire-mode sounds for weapons that lack them.
- The Integral Silencer goes in the muzzle slot.

## 1.7.1 (2023-09-04)
- New Mod Settings option "Preem Mod Slot Layout": where the mod slots sit on the crafting screen.
- The Power barrel makes a `_PreemPower` variant of a weapon that isn't Power already, like the Smart and Tech barrels.

## 1.7.0 (2023-04-29)
- Uses the Codeware mod (`import Codeware.UI.*`) instead of a bundled copy of its UI code.

## 1.6.1 (2023-03-24)
- Perk-based unlocks follow the tier settings instead of fixed lists.

## 1.6.0 (2023-03-22)
- Progression: Mod Settings options for how mods unlock (perks per tier) and how many a weapon takes (limit grows with Crafting level). Locked mods show what unlocks them.

## 1.5.2 (2022-11-16)
- The Semi-Auto trigger clears the weapon's burst shot count.

## 1.5.1 (2022-11-16)
- New melee handles: Tyger Grip (leap to targets) and Booster Handle (sprint attack becomes a long dash).

## 1.4.1 (2022-11-13)
- Preem slots count as dedicated attachment slots in the inventory again.

## 1.4.0 (2022-11-13)
- New mods: Power Barrel, Integral Silencer, Smart-Link RAM and Smart-Link GPU (Smart barrels), Carbon-Fiber Blade (crit chance), Serrated Edge (crit damage), Lightweight Handle (stamina).

## 1.3.0 (2022-11-11)
- Mods have descriptions and flavour text in the crafting screen.

## 1.2.2 (2022-11-07)
- Crafting screen: mod slots rebuilt correctly when switching weapons.

## 1.2.1 (2022-11-07)
- Crafting screen fixes; debug logging removed.

## 1.2.0 (2022-11-06)
- Melee mods: Chem, Shock, Thermal and Sharp blades, Rubberized Grip.

## 1.1.0 (2022-11-06)
- New triggers: Tech Full-Auto, Insta-Burst, Ultra-Action. Mods can require a weapon evolution.

## 1.0.4 (2022-11-05)
- Trigger changes apply only to the player's weapons (NPC weapons were affected).
- Mods picked on the crafting screen are cleared when it closes.

## 1.0.3 (2022-11-05)
- Tech Barrel renamed Atomizer Barrel. Unused bundled Codeware code removed.

## 1.0.0 (2022-11-01)
First release. Barrels: Xtra, Compensator, Smart, Tech, Vented, Turbo. Triggers: Full-Auto, Semi-Auto, Burst, Tech. Magazines: Thermal, Shock, Chemical and Shredder rounds, Extended Mag. The release zip had no version number.
