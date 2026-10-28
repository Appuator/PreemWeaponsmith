# Silencer sounds on 2.5 (spike, 2026-10-27)

Why some weapons with the Integral Silencer (`Barrel_Silencer`) make no fire sound. Notes only; the silenced state itself is in `notes/silencer-ideas.md` ("What makes a weapon silenced on 2.5").

## The path from a silenced weapon to its sound
1. A weapon record's TweakDB flat `audioName` names an `audioWeaponSettingsGroup` in `cooked_metadata.audio_metadata` (e.g. `Items.Preset_Grad_Default.audioName = n"wea_set_grad"`). Every variant shares its base's `audioName`, so Preem evolution variants sound like their base.
2. The group has `playerSettings` (plain set, e.g. `wea_pla_grad`) and `playerSilenced` (silenced set, e.g. `wea_pla_ajax_suppressor` for `wea_set_ajax`), plus the NPC pair.
3. The game uses `playerSilenced` when the weapon has a silencer attached: native `WeaponObject.IsSilenced()`, true with `Barrel_Silencer` in `AttachmentSlots.PowerModule`. It doesn't follow the `CanSilentKill` stat: Panam's Grad has the stat but isn't "silenced", and plays its group's plain set, which is already `wea_pla_grad_suppressor`.
4. The chosen `audioPlayerWeaponSettings` entry names the events per fire mode (`fireSound`, `autoFireSound`/`autoFireStop`, `burstFireSound`, charge fields).
5. **When `playerSilenced` is `None`, a silenced weapon plays no fire event at all.** It does not fall back to the plain set (run below).

## How our sound fills interact
- `PreemSoundSets.Patch` (ADR 0001) fills only empty event fields of `audioPlayerWeaponSettings` entries, on 78 sets (222 fields), `_suppressor` sets among them. It never looks at `audioWeaponSettingsGroup`, so it never sets `playerSilenced`.
- The 2.2.5 `.archive` (a full copy of the metadata) did: in its packed copy, 42 groups have a borrowed silenced set (Grad → `wea_pla_grad_suppressor`, Burya → Nue's, Achilles → Kyubi's, Chao → Masamune's, and so on). Moving to fills on 2.5 lost those links. So the silent weapons are a regression from 2.2.5, not a vanilla 2.5 change, as far as the data shows. The `wolvenkit/source/raw` export shows a third mapping, so it isn't a reliable reference.
- Vanilla 2.5: 17 of 76 `wea_set_*` groups have a silenced set (Ajax, Copperhead, Defender, Guillotine, Kyubi, Lexington, Liberty, Liberty Dex, Masamune, Nova, Nue, Overture, Pulsar, Saratoga, Umbra, Unity, Toygun via Lexington). 58 have `None`; `wea_set_ticon` names `wea_pla_ticon_suppressor`, which doesn't exist (effectively none). The full per-group list with the 2.2.5 donors is in `notes/silencer-ideas.md`.

## Which weapons go silent (live, `logs/boot-2026-10-27_22-39-54`)
A scratch Lua (not committed; same steps as `dev/cet/sound-check.lua`) crafted, equipped and drew each weapon, then fired 8 shots through `AIWeapon.Fire`. Each weapon ran once without and once with `Barrel_Silencer`. The listener (`PreemSoundListener`, Audioware) watched 41 events: every single, auto and burst event of each weapon's plain and silenced sets (vanilla + our fills), plus the Liberty, Nue and Kyubi suppressed shots as fallback candidates. Save `AutoSave-1`. RedTest 342/342, self-check 4136/0.

| Weapon (class) | Group has a silenced set | Without silencer | With `Barrel_Silencer` |
|---|---|---|---|
| Liberty (pistol) | yes | `liberty_fire_single` ×8 | `liberty_fire_suppressor` ×8 |
| Overture (revolver) | yes | `overture_fire_single` ×8 | `overture_fire_suppressor` ×8 |
| Saratoga (SMG) | yes | `saratoga_fire_single` + `_auto` | `saratoga_fire_suppressor_single` + `_auto` |
| Ajax (rifle) | yes | `ajax_fire_single` + `_auto` | `ajax_fire_suppressor_single` + `_auto` |
| Defender (LMG) | yes | `defender_fire_single` + `_auto` | `defender_fire_suppressor_single` + `_auto` |
| Kenshin (Tech pistol) | no | `kenshin_fire_burst` ×8 | **nothing** |
| Burya (Tech revolver) | no | `burya_fire` ×8 | **nothing** |
| Shingen (Smart SMG) | no | `shingen_fire` ×8 | **nothing** |
| Sidewinder (Smart rifle) | no | `sidewinder_fire_single` + `_auto` | **nothing** |
| Grad (sniper) | no | `grad_fire` ×8 | **nothing** |
| Panam's Grad (sniper, built-in suppressor) | no (plain set is suppressed) | `grad_fire_suppressor` ×8 | **nothing** |
| Nekomata (Tech sniper) | no | `nekomata_fire` ×8 | **nothing** |
| Carnage (shotgun) | no | `carnage_fire_single` ×8 | **nothing** |
| Testera (shotgun) | no | `testera_fire` ×8 | **nothing** |

Result: 5 of 5 weapons whose group has a silenced set play their suppressed events with the barrel. 9 of 9 whose group has none play none of the watched events, not even their own plain shot. That matches the Grad bug (HANDOFF §4) and the user's report. Limit: the listener only sees watched names, so "nothing" means nothing from either of the weapon's sets or the three candidates. An ear check in play would close it.

## Does a silencer in a Preem slot count? (live, `logs/boot-2026-10-27_23-25-20`)
No. `IsSilenced()` looks only at the muzzle slot `AttachmentSlots.PowerModule`; a `Silenced` part anywhere else doesn't count (and in that slot the part's `Silenced` tag decides, see "Can a muzzle brake count as a silencer?" below). A scratch Lua (not committed) crafted each weapon with `Barrel_Silencer`, and before equipping moved the part from `PowerModule` to `AttachmentSlots.PreemBarrelMod01`. It used `TransactionSystem.RemovePart`/`AddPart`, and for the run only added the Preem barrel slots to the item's `placementSlots` (without that, `AddPart` refuses). Then it equipped, drew and fired 8 shots.

| Weapon | Silencer in | `IsSilenced()` | Heard |
|---|---|---|---|
| Ajax | `PowerModule` | true | `ajax_fire_suppressor_single` + `_auto` |
| Ajax | `PreemBarrelMod01` | false | `ajax_fire_single` + `_auto` (plain) |
| Kenshin | `PreemBarrelMod01` | false | `kenshin_fire_burst` ×8 (plain) |
| Liberty | `PreemBarrelMod01` | false | `liberty_fire_single` ×8 (plain) |

`IsSilenced()` also updates live: removing the part from `PowerModule` on the equipped weapon turned it false at once (earlier run, `logs/boot-2026-10-27_23-13-29`). Changing parts on an equipped weapon unequips it, though, so the item has to be equipped again afterwards.

So a Preem mod in a Preem slot can't make the game play the silenced set by itself. The ways to get the silenced sound from a Preem mod are: something sits in `PowerModule` (today's install, or a hidden helper part installed alongside a Preem-slot mod), or a non-metadata route (Audioware playing the suppressed event while the metadata plays nothing, which needs the plain shot muted too). The `CanSilentKill` behaviour comes from the part's stats in any slot (not measured here).

## Can a muzzle brake count as a silencer? (live, `logs/boot-2026-10-28_07-41-56`)
Yes, with the `Silenced` tag. Gate feedback: the hidden part takes the muzzle slot, so a gun can't carry the Preem Silencer and a vanilla muzzle brake together. Spike `dev/cet/brake-twin-spike.lua`: fresh Ajaxes, the part put in `PowerModule` before equipping, 3 semi-auto shots each.

| Muzzle part | `IsSilenced()` | Heard |
|---|---|---|
| `Items.Handgun_MuzzleBrakeBase` (plain brake) | false | `ajax_fire_single` |
| clone of that brake, `Silenced` added to its tags (CET `CloneRecord` + `SetFlat`) | true | `ajax_fire_suppressor_single` |
| `Items.PreemSilencerMuzzle` (hidden part) | true | `ajax_fire_suppressor_single` |
| clone of the hidden part with the brake's stats, appearance, name and icon | true | `ajax_fire_suppressor_single` |

So `IsSilenced()` reads the `Silenced` tag of the part in `PowerModule`, not its item type: a brake clone (type `Prt_HandgunMuzzle`) counts. Only the first shot of each case logged an event (the listener's usual pattern on fast semi-auto calls; same in every case).

The 35 records that fit `PowerModule` (2.5): silencers have type `Prt_Muzzle` and tag `Silenced`; brakes have `Prt_RifleMuzzle` or `Prt_HandgunMuzzle` and tag `Muzzle_Brake`. Player brakes: `Items.w_muzzle_brake_01`, `_02`, `_03`, `_05`, `_06` (rifle), `_07`, `_08`, `_09`, `_10`, `_11` (handgun), plus `_01_Craftable`, `_09_Craftable` and the `_legendary` ones (`01`, `03`, `09`, `10`). Bases (`MuzzleBrakeBase`, `Rifle_SMG_MuzzleBrakeBase`, `Handgun_MuzzleBrakeBase`) and `w_att_power_street_126xx_mzl` (type `Gen_Misc`, appearance parts) aren't player items. `Items.Rook_Silencer` carries `DummyPart HideInUI HideAtVendor`: a vanilla precedent for a part the UI hides, which may keep the hidden part off the vanilla mod screen (not tested).

Built (2026-10-28, ROADMAP gate-feedback task): 16 twins in `tweaks/barrels.yaml`; `silencer-e2e` (`logs/boot-2026-10-28_08-13-20`) shows the twin keeps the brake's stats exactly (`HasMuzzleBrake` 1, `RecoilKickMin` 0.555, `RecoilKickMax` 0.8325, `RecoilKickReduction` 7.5, `CritChance` -3 on the plain brake and on its twin). Still not seen: how the vanilla mod screen draws a twin (an in-game look at the gate).

## Donors (built 2026-10-27)
`PreemSoundSets.Fills` links 48 groups' `playerSilenced` to a donor set at load (237 fields in base, 33 in ep1 with the other fills).
- **2.2.5 archive's donors** (43 groups; the Grad's from the earlier fix): Nue's for Ashura, Burya, Carnage, Crusher, Grit, Igla, Omaha, Osprey, Palica, Pozhar, Quasar, Rasetsu, Satara, Silverhand, Tactician, Testera, Zhuo; Masamune's for Chao, Kenshin, Kenshin Chaos, Senkoh, Shingen, Ticon, Ticon Reed; Ajax's for Borg4a, Dian, Hercules, HMG, Kolac, Metel, Senkoh Prototype, Sidewinder, Yukimura, Yukimura preset; Kyubi's for Achilles and SOR-22; Lexington's for Chao Voodoo, Kappa, Slaught-o-Matic; Defender's for M-76e (`ma70`); the Grad's for Grad and Nekomata; Warden's own for Warden.
- **Claude's picks where 2.2.5 left a player weapon's group empty (confirm at the gate):** Panam's Grad, Nova Hitman (`wea_set_nova_suppressor`), Unity Dex and Warden Boris (`wea_set_warden_suppressor`) keep the suppressed set they already play unsilenced, so the barrel changes nothing; the Chopper HMG (`wea_set_special_flak_cannon`) borrows the Defender LMG's, the nearest class with one.
- **Left without:** groups no `Items.Preset_*` uses (flamethrower, vehicle and missile weapons, smart shotguns, Smasher's guns, Nobunaga, Delamain launcher, plasma cutter).
- **Grad's suppressed auto loop (gate feedback 2026-10-28):** 2.2.5's fill was Overture's suppressed loop and stop. On a Nekomata with the Silencer and Full-Auto the loop kept playing after release (user), although the listener saw the stop event posted on release (`logs/boot-2026-10-28_10-01-18`, real trigger); the plain Nekomata with Pozhar's pair stops. Vanilla never fires an Overture full-auto, so that pair is likely never used. The set now takes Ajax's suppressed loop and stop, which vanilla full-auto Ajaxes play; posted on press and release on the Nekomata and Carnage (`logs/boot-2026-10-28_10-15-18`). Whether it stops is an ear check. The Grad itself fires single shots even in Full-Auto, so it never reached the loop.
- **Ticon:** vanilla links `wea_set_ticon` to `wea_pla_ticon_suppressor`, a set that doesn't exist in either metadata file, so it played nothing too. `PreemSoundSets.IsEmptyLink` counts that link as empty.
- Live (`logs/boot-2026-10-27_23-51-35`, `dev/cet/silencer-check.lua`, report 17/17): Kenshin and Ticon play Masamune's suppressed burst (both burst weapons); Burya, Carnage, Testera Nue's; Shingen Masamune's; Sidewinder Ajax's auto; both Grads and Nekomata the Grad's; Achilles Kyubi's; Kappa Lexington's; M-76e and the Chopper HMG Defender's auto; Nova Hitman, Unity Agent and Warden Boris their own.

## Likely cause
On 2.5, `playerSilenced` is `None` for 58 weapon groups, and the 2.5 sound fills don't fill it the way the 2.2.5 archive did. A weapon from those groups with the Silencer barrel attached switches to "silenced", finds no silenced set, and plays no fire sound. That covers most Tech, Smart, sniper, shotgun and iconic-only groups, and both Grads.

## Proposed follow-up tasks (not added; the user decides)
1. **Fill empty `playerSilenced` at load**, beside the existing fills (same Codeware `Resource/Ready` service; within ADR 0001's "fill only empty fields" rule). A table of group → donor silenced set in `PreemSoundSets`. The 2.2.5 archive's 42 donors as the start, plus a donor for the 16 groups it left empty that a player can silence (e.g. Grad Panam, Unity Dex). Test seam: `PreemSoundSets.Patch` (or a sibling) with RedTest red first. Live check: this spike's run turned into a committed `dev/cet` script, every "nothing" row hearing its donor's suppressed event.
2. **Fire-mode fills for the donor sets**: a silenced weapon with a trigger mod plays the donor's auto or burst events, which the existing `_suppressor` fills may or may not cover. Check with the sound sweep's silencer rows (`sound-sweep.py` adds a silencer row per group).
3. **Grad diagnosis** (next roadmap task): this is very likely its cause; it can be closed by task 1 with Panam's Grad and the default Grad as its live check.
4. Decide whether a built-in suppressor (Panam's Grad) should take the Silencer barrel at all; with task 1 it would switch from its own suppressed set to the donor's.
