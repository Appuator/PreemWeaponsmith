# ADR 0002: The Integral Silencer sits in a Preem barrel slot, with a hidden muzzle part for the sound

- Status: accepted (2026-10-27, Phase 7)

## Context
On 2.5 a weapon counts as silenced in two separate ways (`notes/silencer-ideas.md`, `notes/silencer-sounds.md`):
- **Behaviour** (no gunshot stimulus, `SilencedShoot` FX, stealth damage) reads the `CanSilentKill` stat. A part gives it from any slot.
- **Sound**: native `WeaponObject.IsSilenced()` picks the group's silenced sound set. It is true only when a part sits in the muzzle slot `AttachmentSlots.PowerModule`. A live run moved the same silencer part, with its `Silenced` tag, into `AttachmentSlots.PreemBarrelMod01`: `IsSilenced()` was false and the gun played its plain, loud shot. Script can't wrap a native method, so no hook can change this.

Up to 2.4.x, `PreemCraftingSystem.PlanModSlots` special-cased the Silencer into `PowerModule`. It still used up a Preem barrel slot, and replaced whatever muzzle the weapon had. The alternatives were:
- keep that muzzle install;
- move it to a Preem slot and accept the loud shot;
- extend muzzle sockets per weapon (mesh work every patch).

## Decision
(user, 2026-10-27) The Silencer becomes a normal Preem barrel mod in `PreemBarrelMod01`/`02`, and carries the stats. While a weapon holds it, crafting and the upgrade screen also install a hidden helper part in `PowerModule`. The helper has no stats and exists only so the engine treats the gun as silenced. It is removed and deleted together with the Silencer. Sound groups that have no silenced set get a donor set at load (ADR 0001 style fills).

## Consequences
- Same slot rules as every other barrel mod; the `PowerModule` special case in `PlanModSlots` goes away.
- Two parts must stay in step on craft, upgrade, removal and swap. The rule deciding the helper is pure, so RedTest can check it.
- The helper occupies the muzzle. A vanilla muzzle the player installed would be replaced, as before. The vanilla mod screen may let the player remove the helper, which leaves a quiet-behaving but loud-sounding gun until the next upgrade.
- Weapons crafted with 2.4.x hold the old Silencer in `PowerModule`. Their read-back has to keep working, so a migration path is needed (build task).
- Sound still depends on each weapon group having a silenced set, so the donor table has to be kept up when a patch adds weapons.
