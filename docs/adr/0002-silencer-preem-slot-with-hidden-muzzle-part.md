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

## Addendum (2026-10-28, Phase 7 gate feedback): muzzle brakes stay
The user reported that the hidden part blocks a muzzle brake on guns that have a muzzle slot. A live spike (`notes/silencer-sounds.md` "Can a muzzle brake count as a silencer?") showed that `IsSilenced()` reads the `Silenced` tag of the part in `PowerModule`, not its item type: a brake cloned with that tag counts and plays the suppressed shot.

Decision (user, 2026-10-28): each player muzzle brake gets a **brake twin**, `Items.PreemSilenced_<brake>` in `tweaks/barrels.yaml`. It is the brake's record (`$base`, same stats, look and item type) with the tags `itemPart, WeaponMod, Muzzle_Brake, Silenced`, without the loot tags. While the Silencer is on, the muzzle holds the twin instead of the brake; without the Silencer the twin goes back to the plain brake. The empty or other muzzle still gets the hidden part, and a vanilla silencer the player installed now stays (it already silences).

Consequences:
- The muzzle rule (`PreemCraftingSystem.PlanMuzzlePart`) now returns the record the muzzle should hold; `PreemMuzzleParts` holds the twin list.
- Two wraps on `ItemModificationSystem` (`InstallItemPart`, `RemoveItemPart`) cover the vanilla mod screen and every other vanilla part change: a brake installed on a Silencer gun goes in as its twin; a twin that comes off becomes its plain brake; the hidden part that comes off is deleted. A twin or hidden part left in the inventory by another vanilla path (a weapon used as a crafting ingredient) is taken back when the crafting screen opens.
- A patch that adds a muzzle brake fails the self-check until the brake is added to `PreemMuzzleParts.BrakeNames` and `tweaks/barrels.yaml`. Until then such a brake is replaced by the hidden part and goes back to the inventory.
- On a weapon with a vanilla muzzle the hidden part is still listed on the vanilla mod screen. `DummyPart` would hide it, but the screen then hides the whole muzzle slot, so a brake couldn't be added there.
- On a weapon with no vanilla muzzle (no muzzle part list in its record's `slotPartList`, so the vanilla screen never offers it a part), the vanilla mod screen and tooltips leave the muzzle slot out (gate feedback 2026-10-28; wraps of the three attachment-list builders, `PreemMuzzleParts.HidesMuzzleSlot`). The hidden part stays in the slot for the sound.
