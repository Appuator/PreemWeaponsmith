# A better Integral Silencer (idea, not decided)

Raised by the user on 2026-10-25. Start this after the 2.5 conversion (Phases 0–4). Fits with Phase 3 (sounds) because silenced fire sounds are part of the problem.

## How it works today (2.2.5)
- `Barrel_Silencer` is a Barrel-class Preem mod, but it is **not** installed into a Preem barrel slot. `PreemCraftingSystem.ApplyMods` special-cases it and installs it into the vanilla muzzle slot `AttachmentSlots.PowerModule`.
- Its item `Items.PreemBarrelModSilencer` is a clone of the vanilla `Items.SilencerBase`, with stat records cloned from `w_silencer_01_inline0/1` and `SilencerBase_inline0/1` (`PreemModCreation.reds`).
- `PreemWeaponAlteration` adds a third barrel slot element (`PreemBarrelSlot03Element`) pointing at `PowerModule`, so weapons whose blueprint lacked a muzzle slot get one.
- `gameItemData.DoesItemHaveSilencer()` looks for the silencer in the **Preem barrel slots**, where it is never installed, so it can never return true. It is also unused.
- The user's experience: it only really works on guns that already supported a silencer.

## Why it is limited (hypotheses, to check in `game-scripts` on 2.5)
1. **Being "silenced" is tied to the muzzle attachment.** The game probably decides it from the item in the muzzle slot or a stat that attachment carries, not from a weapon-level flag. Weapons without muzzle support may not read it.
2. **Visuals need a muzzle socket.** The attachment mesh only appears on weapon meshes that have the socket. Others get no visible silencer at best.
3. **Audio needs suppressed sound events.** Silenced shots use `*_fire_suppressor*` events that exist only for weapons that support silencers (see `docs/weapon-sound-events.txt`, which already lists added suppressor-auto events).
4. **Stealth/noise logic** (NPC hearing, stealth bonuses) checks silenced state through its own path, which may skip weapons that "can't" be silenced.

## What makes a weapon silenced on 2.5 (findings, 2026-10-27)
From `game-scripts` (tag `2.5`; nothing here changed from `pre-2.5` except enum and struct positions), the vanilla 2.5 sound metadata (serialized from `audio_1_general.archive` and `ep1_2_gamedata.archive`), and one live run.

There are **two separate switches**, and they disagree on built-in suppressors:

1. **Behaviour = the `CanSilentKill` stat** (any value above 0 on the weapon). Every script path reads this stat, never the attachment:
   - Player shot (`WeaponTransition` shoot, `weaponTransitions.script` ~2148): stimulus `SilencedGunshot` (radius 10; snipers also a `Gunshot` at 10) instead of `Gunshot` at 25 m indoors / `GetGunshotRange()` outdoors, plus the `IllegalAction` stim, and the FX action `SilencedShoot` instead of `Shoot` / `MuzzleBrakeShoot`. It also skips the `player_fired_a_weapon` fact and the Dogtown alert path.
   - NPC shot (`AIWeapon.Fire`, `weapon.script` ~1676): the same switch.
   - On-hit noise (`executorStimOnHit`): silent weapons make an impact stim of radius 5 for snipers only (3 with the gag perk), else none.
   - Stealth damage: `DamageManager` adds hit flag `SilentKillModifier`, and `DamageSystem` (~1735) applies the out-of-combat stealth-hit bonus (`StealthHitDamageBonus`/`Multiplier`, player + weapon) only when `CanSilentKill > 0`.
   - Damage preview in stealth (`DefaultTransition.CanWeaponSilentKill`).
   - The vanilla silencer item gives it: `Items.SilencerBase_inline1` is `CanSilentKill` +1 (our `PreemBarrelModSilencer_inline4`). The other three copied modifiers are `WeaponNoise` −10, `StealthHitDamageMultiplier` +2 and `DamagePerHit` ×0.8.
   - No script reads `WeaponNoise` (it is only in the stat enum). It may be read natively; unknown.
2. **Sound = native `WeaponObject.IsSilenced()`**, which follows the silencer **attachment**, not the stat. Live (2026-10-27, `logs/boot-2026-10-27_22-28-05`): Panam's Grad has `CanSilentKill` 1 and `IsSilenced()` false; the default Grad and the Ajax with `Barrel_Silencer` (in `PowerModule`) have 1 and true; the plain Ajax has 0 and false. Script only calls it for telemetry. The UI's silencer icons are a third, separate check: an item in `AttachmentSlots.PowerModule` (`InventoryItemData`, tooltips).
   - Which sound set plays: a weapon record's `audioName` names an `audioWeaponSettingsGroup` (`wea_set_*`) with `playerSettings` (plain) and `playerSilenced`. A weapon with a silencer attached plays from `playerSilenced`, the `_suppressor` set (confirmed for Liberty, Kyubi and Ajax in the Phase 3 sweep). Panam's Grad isn't "silenced": its group's **plain** set is already `wea_pla_grad_suppressor`.
   - **Vanilla 2.5 gives only 17 of the 76 `wea_set_*` groups a silenced player set**: Ajax, Copperhead, Defender, Guillotine, Kyubi, Lexington, Liberty, Liberty Dex, Masamune, Nova, Nue, Overture, Pulsar, Saratoga, Umbra, Unity, plus Toygun borrowing Lexington's. `wea_set_ticon` names `wea_pla_ticon_suppressor`, which doesn't exist. **58 groups have `playerSilenced = None`**, among them Achilles, Ashura, Borg4a, Burya, Carnage, Chao, Crusher, Dian, both Grads, Grit, Hercules, Igla, Kappa, Kenshin, Kolac, M-76e (`ma70`), Metel, Nekomata, Omaha, Osprey, Palica, Pozhar, Quasar, Satara, Senkoh, Shingen, Sidewinder, SOR-22, Tactician, Testera, Ticon, Warden, Yukimura and Zhuo.
   - **The 2.2.5 `.archive` filled most of those**: in the mod's packed metadata (`wolvenkit/source/archive`), 42 groups have a borrowed silenced set (e.g. Grad → `wea_pla_grad_suppressor`, Burya → Nue's, Achilles → Kyubi's, Chao → Masamune's). ADR 0001 replaced the archive with fills of empty fields inside `audioPlayerWeaponSettings` entries (`PreemSoundSets`), which never touch a group's `playerSilenced`. So on 2.5 a weapon from one of those groups with the Silencer barrel most likely has no fire sound set at all. That fits the Grad bug (HANDOFF §4: none of the watched events, not even its own shot) and the user's report that some weapons with the Integral Silencer are silent. The silencer-sound spike and the Grad diagnosis should confirm it with the listener; the fix would be filling `playerSilenced` the same way (ADR 0001 style), not shipping metadata.
   - The pre-2.5 export in `wolvenkit/source/raw` shows yet another mapping (40 borrowed, e.g. Grad → Liberty's), so it isn't vanilla 2.5. Don't use it as a reference for groups.

**Hypotheses above, answered:** (1) Partly: behaviour is stat-driven (`CanSilentKill`), not tied to the muzzle; sound is tied to the attachment (`IsSilenced`). (3) Yes, and it's per settings group: 58 groups have no silenced set on 2.5. (4) No separate path: noise and stealth all read `CanSilentKill`. (2) Not checked (meshes are out of script reach).

**For the directions below:** option A works for behaviour. A Preem mod in any slot that carries `CanSilentKill` +1 (plus the noise and stealth stats) gives silent shots, `SilencedShoot` FX and stealth damage on every gun, with no `PowerModule` special case. Sound needs either the attachment (for `IsSilenced`) plus a filled `playerSilenced` for that weapon's group, or a hook. `IsSilenced` is native, so option B can't wrap it for sound; it isn't needed for behaviour either.

## Directions to evaluate
| Option | Idea | Pros | Cons |
|---|---|---|---|
| A. Stat/flag based | Make the Preem silencer a normal Preem barrel mod (in a Preem slot) that sets whatever weapon-level silenced stat or flag the game reads; wrap the silenced check to also consider it | Works on every gun; no mesh or socket needed; no special-case slot code | Needs the right check(s) found; no visible silencer |
| B. Hook the silenced check | `@wrapMethod` the method(s) that answer "is this weapon silenced" (weapon, noise and stealth paths) to return true when the Preem silencer is installed | Precise; small | Several call sites possible; one hook per path to maintain |
| C. Keep the attachment, extend support | Add muzzle slot + socket support to more weapons (TweakXL + ArchiveXL appearance edits) | Visible silencer | Per-weapon mesh work; heavy upkeep every patch |
| Audio (with A or B) | Play suppressed fire sounds through Audioware instead of the full metadata override | Fixes the "sounds wrong" part on every gun | Builds on Phase 3 (Audioware decided 2026-10-25) |

The likely answer is A or B for behaviour, plus Audioware for sound, and no visible attachment on guns that never had one. Option C only if a visible silencer matters enough.

## Open questions
- ~~What exactly makes a weapon count as silenced in 2.5 (stat, attachment query, or both)?~~ Both, for different things: the `CanSilentKill` stat for noise, FX and stealth damage; the attachment (native `IsSilenced`) for which sound set plays (findings above, 2026-10-27).
- Open: is it really "no sound" on the 58 groups without a silenced set, and does `IsSilenced` look at `PowerModule` or at a part tag (`Silenced`)? Listener check in the silencer-sound spike.
- Is a visible silencer required, or is behaviour plus sound enough?
- ~~Keep save compatibility for existing silenced Preem weapons?~~ No: pre-2.5 saves are out of scope (decided 2026-10-25). Moving the silencer out of `PowerModule` is fine. After 2.3.0 ships, check this against weapons crafted with 2.3.x.
