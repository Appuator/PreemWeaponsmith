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

## Likely cause
On 2.5, `playerSilenced` is `None` for 58 weapon groups, and the 2.5 sound fills don't fill it the way the 2.2.5 archive did. A weapon from those groups with the Silencer barrel attached switches to "silenced", finds no silenced set, and plays no fire sound. That covers most Tech, Smart, sniper, shotgun and iconic-only groups, and both Grads.

## Proposed follow-up tasks (not added; the user decides)
1. **Fill empty `playerSilenced` at load**, beside the existing fills (same Codeware `Resource/Ready` service; within ADR 0001's "fill only empty fields" rule). A table of group → donor silenced set in `PreemSoundSets`. The 2.2.5 archive's 42 donors as the start, plus a donor for the 16 groups it left empty that a player can silence (e.g. Grad Panam, Unity Dex). Test seam: `PreemSoundSets.Patch` (or a sibling) with RedTest red first. Live check: this spike's run turned into a committed `dev/cet` script, every "nothing" row hearing its donor's suppressed event.
2. **Fire-mode fills for the donor sets**: a silenced weapon with a trigger mod plays the donor's auto or burst events, which the existing `_suppressor` fills may or may not cover. Check with the sound sweep's silencer rows (`sound-sweep.py` adds a silencer row per group).
3. **Grad diagnosis** (next roadmap task): this is very likely its cause; it can be closed by task 1 with Panam's Grad and the default Grad as its live check.
4. Decide whether a built-in suppressor (Panam's Grad) should take the Silencer barrel at all; with task 1 it would switch from its own suppressed set to the donor's.
