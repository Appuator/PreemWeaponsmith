# Audioware and the fire-mode sounds (Phase 3 spike, 2026-10-26)

Question (ROADMAP Phase 3 spike): how can Audioware supply the `*_fire_auto`, `*_fire_auto_stop`
and suppressed events? (1) Can a manifest point a new event at an existing game sound, or does it
need audio files? (2) Do a weapon's own fire events, posted natively by its weapon audio, reach
Audioware's interception?

## Short answers
1. **Audio files only.** An Audioware manifest (`sfx`, `onos`, `voices`, `music`) maps an ID to an
   audio file (`.wav`/`.ogg`/`.mp3`/`.flac`). Audioware plays through its own engine (Kira) next to
   Wwise and "does not make any use of" Wwise, so an entry can't point at a game Wwise event or
   `.wem`. Its `AudioSystem.Play/Stop/Switch` hooks only redirect Audioware IDs; they never make a
   Wwise event play. (Docs: CONCEPT, MANIFEST/SECTIONS, AUDIO_SYSTEM, NATIVE_INTEGRATION pages of
   cyb3rpsych0s1s.github.io/audioware, read 2026-10-26.)
2. **Yes.** In a loaded save, Audioware's `AudioEventCallbackSystem` saw the weapon's fire events
   as `PlayEvent`s on the player's weapon entity, both from the game's own shot path
   (`AIWeapon.Fire`) and from the player's real trigger (injected left mouse button). No script
   posts these events, so the native weapon audio goes through the path Audioware hooks.
   Callbacks only **listen**. `AudioEventManager.Mute(name)` can silence an event, but only by
   name for every emitter, not for one weapon.

## What the old `.archive` actually does
(Found while preparing the test. This changes the picture SPEC §6 assumed.)
- Every Wwise event in `docs/weapon-sound-events.txt` **already exists in the 2.5 sound banks**
  (all 31 event names are in `base\sound\event\eventsmetadata.json` from `audio_1_general.archive`).
  The six `wea_pla_*_suppressor` lines in that file are weapon-settings names, not events.
- The `.archive` adds no sounds. It edits the `audioPlayerWeaponSettings` entries (one per weapon
  sound set, e.g. `wea_pla_liberty`) in `base\` and `ep1\sound\metadata\cooked_metadata.audio_metadata`
  and points empty fields at **other weapons' existing events**: Liberty, Nova and Unity get
  Lexington's `fire_auto`/`fire_auto_stop`; Kyubi, Nue, Kolac, SOR-22 get Ajax's; Grad, Burya,
  Omaha, Nekomata, Satara get Quasar's; and so on.
- Against vanilla 2.5 it changes 70 settings entries: `autoFireSound`/`autoFireStop` 30 each,
  `burstFireSound` 60, `chargeStartSound` 61, `chargeReadySound` 1, the perfect-charge perk trio 3.
  Lexington, Ajax, Quasar, Sidewinder and Pozhar have their own auto events in vanilla already.
- The repo's `wolvenkit/source/raw/` JSON is an unmodified (pre-2.5) export, not the shipped data;
  compare against `wolvenkit/source/archive/` (the packed files) instead.
- A weapon record picks its sound set through its TweakDB flat `audioName` (e.g.
  `Items.Preset_Liberty_Default.audioName = n"wea_set_liberty"`), which the metadata maps to
  the `wea_pla_*` / suppressor settings.

## The test (2026-10-26)
Files: `dev/spike/audioware/PreemAudioSpike.reds` (exec functions, registers callbacks on 12
Lexington event names), `dev/spike/audioware/spike.lua` (CET driver), not installed by
`dev-install.ps1`. The `.reds` went into `r6\scripts\PreemSpike` for this one run and was removed
afterwards. A helper outside the game held the left mouse button when the Lua wrote
`trigger-now.txt`.

    pwsh tools/compile-check.ps1 -Extra dev/spike/audioware,<game>\r6\scripts\Audioware   # 0 errors
    pwsh tools/boot-check.ps1 -LoadSave -Run dev/spike/audioware/spike.lua -HoldSec 40     # exit 0

Boot: all pins OK (Audioware `1.10.1-rc.0`), self-check 4136/0, RedTest 47/47, Audioware log has
no errors. Logs: `logs/boot-2026-10-26_12-18-07/`. Results (from `[PreemSpike]` game-log lines):

| Step | What reached the callback |
|---|---|
| Control: `AudioSystem.Play(mag_tap)` and `GameObject.PlaySoundEvent(player, mag_out)` from script | both, as `PlayEvent` |
| 8 shots through `AIWeapon.Fire` (4 semi, 4 full-auto requested), 0.4 s apart | `fire_single` (1st shot), `fire_auto` (2nd shot), then `fire_auto_stop` about 3 s later, all on the player's weapon |
| Real trigger: 3 clicks then a 2 s hold | `fire_single` ×3, `fire_auto`, `fire_auto_stop`, each on the player's weapon and also on a second dynamic entity |
| Equip and draw | none of the watched equip/grab names (likely other event names; not needed) |

Counts: `fire_single` 9, `fire_auto` 3, `fire_auto_stop` 3. Also seen: `AddContainerStreamingPrefetch`
and `RemoveContainerStreamingPrefetch` for `fire_single` when the Lexington was given.

Reading the results: the native weapon audio chooses between `fireSound` and the
`autoFireSound` loop by itself, from how fast shots follow each other (the Lexington is
semi-auto in vanilla and still played its auto loop for fast shots), and ends the loop with
`autoFireStop`. So a weapon whose settings have an `autoFireSound` gets the loop when it fires in
full auto, whatever the trigger mode. A weapon whose settings leave it empty (Liberty in vanilla
2.5) presumably plays `fireSound` every shot; not tested.

## What this means for the next tasks
Audioware can't make the game's own sounds play for a Preem auto weapon on its own. The
borrowed events are Wwise events, and Audioware only plays files. Routes that use the game's
sounds, for the "Decide how the Preem fire-mode sounds are sourced" task (options only; the user
decides):
- **A. Script plays the Wwise events.** A Preem hook posts the borrowed event on the weapon with
  vanilla `GameObject.PlaySoundEvent(weapon, n"..._fire_auto")` and the stop on release. The
  native `fire_single` per shot would still play; muting it needs Audioware's `Mute`, which is by
  name for every weapon of that kind (NPCs too). Audioware would only be the interceptor.
- **B. TweakXL `audioName`.** Point Preem variants' `audioName` at a sound set that has auto
  events. Simple and patch-safe, but swaps every sound of that weapon (shots, reload, equip) to
  the other weapon's, applies per record rather than per installed trigger mod, and only works
  where such a set exists.
- **C. Extract the game's sounds into files and play them through Audioware.** Fits the
  Audioware decision, but ships game audio (size, redistribution) and needs the loop and stop
  timing done in script.
- **D. A partial metadata edit.** Only the changed settings entries, not the whole file. Ruled out
  today by "Sounds go through Audioware, not a base-game `audio_metadata` override" unless the
  user reopens it. Note that the `.archive` itself only wires existing events.

Open for the event map task: which Preem weapons' 2.5 settings lack auto, burst or charge events.
The comparison script `dev/spike/audioware/compare-weapon-audio.py` gives it. Serialize both
metadata files with `WolvenKit.CLI convert serialize`, then compare `wolvenkit/source/archive/...`
with the vanilla files from `audio_1_general.archive` (`base`) and `ep1_2_gamedata.archive` (`ep1`).

## Event map (2026-10-26)
Made with `dev/spike/audioware/event-map.py` (usage in its header): vanilla 2.5 metadata
(`base` + `ep1`) against the packed `.archive` files, joined to weapons through the settings
groups (`wea_set_*` → player and silenced settings) and each `Items.Preset_*` record's `audioName`
(weapon dump of 2026-10-26 09:39; Preem variants excluded, they share their base's `audioName`).

**What the archive does, field by field:** 191 fills of fields that are empty in 2.5, 0 overwrites,
0 cleared fields, on 70 sound sets (52 plain, 18 `_suppressor`); every one of the 70 is used by
at least one weapon. So the patch table is exactly "set this empty field to this existing event".

| Field | Trigger mods that need it | Plain sets | Suppressor sets |
|---|---|---|---|
| `autoFireSound` + `autoFireStop` | Full-Auto Fire, Tech Full-Auto | 23 | 7 |
| `burstFireSound` | Burst Fire, Insta-Burst | 44 | 16 |
| `chargeStartSound` (+ `chargeReadySound` on Grit) | Tech Trigger (Charge) | 43 (+1) | 18 |
| perfect-charge perk trio | Tech Trigger with the perk | 2 sets (6 fields) | 1 set (3 fields) |

Semi-Auto Fire and Ultra-Action use `fireSound`, which every set has. Slot rules don't limit
triggers by weapon (`CanInstallPreemModInSlot` checks only slot class and required mods), so every
fill can be reached in play. Charge needs the Tech Barrel, so it plays on `_PreemTech` variants,
which keep their base weapon's `audioName`.

Per sound set (`v` = vanilla 2.5 already has it, `+x` = the archive borrows weapon x's event,
`(sup)` = x's suppressed event, `-` = empty in both):

| Sound set | Weapons | Auto loop + stop | Burst | Charge start | Perfect-charge perk |
|---|---|---|---|---|---|
| `wea_pla_achilles` | 10 | - | v | v | v |
| `wea_pla_ajax` | 16 | v | +masamune | +quasar | - |
| `wea_pla_ajax_suppressor` | 16 | v | +masamune (sup) | +quasar | - |
| `wea_pla_ashura` | 8 | +sidewinder | +senkoh | +achilles | - |
| `wea_pla_borg4a` | 6 | v | +ticon | - | - |
| `wea_pla_burya` | 19 | +quasar | +masamune | v | v |
| `wea_pla_carnage` | 14 | +pozhar | +masamune | +quasar | - |
| `wea_pla_chao` | 13 | - | v | +quasar | - |
| `wea_pla_chao_voodoo` | 1 | - | v | +quasar | - |
| `wea_pla_copperhead` | 16 | v | +masamune | +quasar | - |
| `wea_pla_copperhead_suppressor` | 16 | v | +masamune (sup) | +quasar | - |
| `wea_pla_crusher` | 19 | - | +masamune | +achilles | - |
| `wea_pla_defender` | 11 | v | +masamune | +achilles | +achilles |
| `wea_pla_defender_suppressor` | 11 | v | +masamune (sup) | +quasar | +achilles |
| `wea_pla_dian` | 10 | v | +shingen | +quasar | - |
| `wea_pla_grad` | 10 | +quasar | +masamune | +achilles | - |
| `wea_pla_grad_suppressor` | 3 | +ajax (sup), was +overture (sup) until 2026-10-28 | +senkoh | +achilles | - |
| `wea_pla_grit` | 8 | +quasar | +ticon | v | - |
| `wea_pla_guillotine` | 10 | v | +masamune | +quasar | - |
| `wea_pla_guillotine_suppressor` | 10 | v | +masamune (sup) | +quasar | - |
| `wea_pla_hercules` | 6 | v | +ticon | +quasar | - |
| `wea_pla_hmg_militech` | 8 | v | +masamune | +achilles | - |
| `wea_pla_igla` | 11 | +pozhar | v | +satara | - |
| `wea_pla_kappa` | 16 | v | +chao | +quasar | - |
| `wea_pla_kenshin` | 18 | - | v | v | v |
| `wea_pla_kenshin_chaos` | 3 | - | v | v | v |
| `wea_pla_kolac` | 3 | +ajax | +masamune | +quasar | - |
| `wea_pla_kyubi` | 11 | +ajax | +masamune | +achilles | - |
| `wea_pla_kyubi_suppressor` | 11 | +ajax (sup) | +masamune (sup) | +achilles | - |
| `wea_pla_lexington` | 32 | v | +chao | +quasar | - |
| `wea_pla_lexington_suppressor` | 34 | v | +masamune (sup) | +quasar | - |
| `wea_pla_liberty` | 19 | +lexington | +chao | +quasar | - |
| `wea_pla_liberty_dex` | 3 | +lexington | +chao | +quasar | - |
| `wea_pla_liberty_dex_suppressor` | 3 | +lexington (sup) | +chao | +quasar | - |
| `wea_pla_liberty_suppressor` | 19 | +lexington (sup) | +masamune (sup) | +quasar | - |
| `wea_pla_ma70` | 6 | v | +masamune | +achilles | - |
| `wea_pla_masamune` | 14 | - | v | +achilles | - |
| `wea_pla_masamune_suppressor` | 14 | - | v | +kenshin | - |
| `wea_pla_metel` | 7 | +ajax | +ticon | +achilles | - |
| `wea_pla_nekomata` | 18 | +quasar | +masamune | v | v |
| `wea_pla_nova` | 22 | +lexington | +masamune | +quasar | - |
| `wea_pla_nova_suppressor` | 23 | +lexington (sup) | +masamune (sup) | +quasar | - |
| `wea_pla_nue` | 32 | +ajax | +masamune | +quasar | - |
| `wea_pla_nue_suppressor` | 32 | +ajax (sup) | +masamune (sup) | +quasar | +quasar |
| `wea_pla_omaha` | 25 | +quasar | +shingen | v | v |
| `wea_pla_osprey` | 6 | v | v | +satara | - |
| `wea_pla_overture` | 35 | v | +shingen | +achilles | - |
| `wea_pla_overture_suppressor` | 35 | v | +senkoh | +achilles | - |
| `wea_pla_palica` | 4 | +pozhar | +shingen | +satara | - |
| `wea_pla_pozhar` | 6 | v | +shingen | +satara | - |
| `wea_pla_pulsar` | 12 | v | +senkoh | +quasar | - |
| `wea_pla_pulsar_suppressor` | 12 | v | +masamune (sup) | +quasar | - |
| `wea_pla_quasar` | 18 | v | +shingen | v | v |
| `wea_pla_rasetsu` | 2 | +quasar | +ticon | v | v |
| `wea_pla_saratoga` | 23 | v | +masamune | +quasar | - |
| `wea_pla_saratoga_suppressor` | 23 | v | +masamune (sup) | +quasar | - |
| `wea_pla_satara` | 10 | +quasar | +shingen | v | v |
| `wea_pla_senkoh` | 5 | - | v | v | v |
| `wea_pla_senkoh_prototype` | 1 | - | v | v | v |
| `wea_pla_shingen` | 6 | - | v | +quasar | - |
| `wea_pla_sidewinder` | 7 | v | +shingen | +quasar | - |
| `wea_pla_silverhand` | 1 | - | +shingen | v | - |
| `wea_pla_slaught-o-matic` | 2 | v | +chao | +quasar | - |
| `wea_pla_sor22` | 11 | +ajax | +shingen | +achilles | - |
| `wea_pla_tactician` | 15 | +pozhar | +shingen | +achilles | - |
| `wea_pla_testera` | 5 | +pozhar | +shingen | +achilles | - |
| `wea_pla_ticon` | 6 | - | v | v | - |
| `wea_pla_ticon_reed` | 1 | - | v | v | - |
| `wea_pla_toygun` | 2 | v | - | - | - |
| `wea_pla_umbra` | 7 | v | +masamune | +quasar | - |
| `wea_pla_umbra_suppressor` | 7 | v | +masamune (sup) | +quasar | - |
| `wea_pla_unity` | 20 | +lexington | +chao | +quasar | - |
| `wea_pla_unity_suppressor` | 21 | +lexington (sup) | +masamune (sup) | +quasar | - |
| `wea_pla_warden` | 7 | v | +shingen | +achilles | - |
| `wea_pla_warden_suppressor` | 2 | v | v | +achilles | - |
| `wea_pla_yukimura` | 18 | v | v | +quasar | - |
| `wea_pla_yukimura_preset` | 2 | v | v | +quasar | - |
| `wea_pla_zhuo` | 6 | +pozhar | +shingen | +satara | - |

**Gaps the 2.2.5 archive also had** (a used set whose field stays empty): auto loop on Achilles,
Chao (+ Voodoo), Crusher, Kenshin (+ chaos), Masamune (+ suppressor), Senkoh (+ prototype),
Shingen, Silverhand, Ticon (+ Reed); charge on Borg4a; burst and charge on the Toygun. These
weapons play their single shot for every round in those modes, as in 2.2.5. Filling them is new
work, not parity; a question for the gate.

**Proposed split for the tasks below** (the patcher is generic once the first slice works, so
the rest is data plus a listener check on one weapon per group):
1. First slice: `wea_pla_liberty` auto loop + stop (borrows Lexington). Builds the patcher and
   the table format, and proves the route.
2. Remaining auto loop + stop on the 22 other plain sets. The existing "remaining auto-fire
   events" task; check one weapon per borrowed source (Lexington, Ajax, Quasar, Pozhar,
   Sidewinder).
3. Burst on the 44 plain sets. **Not in the roadmap yet.**
4. Charge start (+ Grit's ready) and the perfect-charge perk trio on the plain sets. **Not in the
   roadmap yet.**
5. Suppressed variants: all four kinds on the 18 `_suppressor` sets. The existing task;
   check with the Silencer barrel.

## Gap fills (2026-10-26, Phase 3 gate feedback)

The user asked for every missing fire-mode sound, not only 2.2.5's. A gap is a field a trigger
mod can reach that stays empty after the 191 fills, on a player sound set some `Items.Preset_*`
weapon uses. `event-map.py` already walks every vanilla player set (not only the archive's 70),
so the gaps are its `empty` rows for `autoFireSound`, `autoFireStop`, `burstFireSound` and
`chargeStartSound` on sets with at least one weapon: **31 fields on 16 sets** (the task text
says 17 sets: a miscount of the same list). Sets no weapon uses (vehicle,
missile, plasma cutter) stay out. Charge-ready and the perk trio are not gaps: vanilla Tech
weapons leave them empty too.

Donor rule: an existing 2.5 event of the same weapon type, then the same evolution (the record's
`itemType` and `evolution`; the `manufacturer` flat only says Street or Corporation, so it can't
pick a brand). Handguns and revolvers count as one pistol class. A suppressed set takes a
suppressed donor. Loop and stop always come from the same donor set. Only real loops: Dian,
Yukimura and Slaughtomatic put a single shot in `autoFireSound`, so they are never donors.

**Tech override (user, Phase 3 gate, 2026-10-26):** every Tech weapon that isn't a pistol takes
Pozhar's auto loop and stop, whatever its type: Achilles, Senkoh and Senkoh Prototype here, and
also 2.2.5's own Quasar picks on Nekomata, Rasetsu (sniper rifles) and Satara (shotgun) in the
event map. So `PreemSoundSets.Fills()` differs from the archive on those three sets (6 fields);
the event map table above still shows the archive's choice. Tech pistols keep Quasar.

| Set (weapons) | Type, evolution | Field(s) | Donor event(s) | Why |
|---|---|---|---|---|
| `wea_pla_achilles` (10) | precision rifle, Tech | auto + stop | `w_gun_rifle_power_pozhar_fire_auto` / `_stop` | Tech, not a pistol: Pozhar (user, Phase 3 gate; was Copperhead) |
| `wea_pla_chao` (13), `wea_pla_chao_voodoo` (1) | handgun, Smart | auto + stop | `w_gun_pistol_smart_kappa_fire_auto` / `_stop` | Kappa: handgun, Smart |
| `wea_pla_crusher` (19) | shotgun, Power | auto + stop | `w_gun_rifle_power_pozhar_fire_auto` / `_stop` | Pozhar: shotgun, Power (Carnage borrows it too) |
| `wea_pla_kenshin` (18), `wea_pla_kenshin_chaos` (3) | handgun, Tech | auto + stop | `w_gun_revol_tech_quasar_fire_auto` / `_stop` | no Tech handgun has a loop; Quasar is a Tech revolver (pistol class; Burya borrows it too) |
| `wea_pla_masamune` (14) | rifle, Power | auto + stop | `w_gun_rifle_power_ajax_fire_auto` / `_stop` | Ajax: rifle, Power |
| `wea_pla_masamune_suppressor` (14) | rifle, Power, suppressed | auto + stop | `w_gun_rifle_power_ajax_fire_suppressor_auto` / `_stop` | the same, suppressed |
| `wea_pla_senkoh` (5), `wea_pla_senkoh_prototype` (1) | SMG, Tech | auto + stop | `w_gun_rifle_power_pozhar_fire_auto` / `_stop` | Tech, not a pistol: Pozhar (user, Phase 3 gate; was Pulsar) |
| `wea_pla_shingen` (6) | SMG, Smart | auto + stop | `w_gun_warden_fire_auto` / `_stop` | Warden: SMG, Smart |
| `wea_pla_silverhand` (1) | handgun, Power | auto + stop | `w_gun_revol_power_overture_fire_auto` / `_stop` | Malorian is a heavy pistol: Overture (pistol class, Power, heavy) over the light Lexington |
| `wea_pla_ticon` (6) | handgun, Tech | auto + stop | `w_gun_revol_tech_quasar_fire_auto` / `_stop` | as Kenshin |
| `wea_pla_ticon_reed` (1) | handgun, Tech, suppressed (its own shots are `_suppressor`) | auto + stop | `w_gun_pistol_power_lexington_fire_suppressor_auto` / `_stop` | no Tech pistol has a suppressed loop; Lexington is the suppressed handgun loop |
| `wea_pla_borg4a` (6) | SMG, Power | charge start | `w_gun_smg_tech_senkoh_charge` | Senkoh: the only SMG with a charge (2.2.5 gave other SMGs Quasar's) |
| `wea_pla_toygun` (2) | handgun, Power (a Lexington) | burst; charge start | `w_gun_pistol_smart_chao_fire_burst`; `w_gun_revol_tech_quasar_charge` | follows its base: the Lexington's own burst and charge fills |

Count: auto loop + stop on 14 sets (Achilles, Chao, Chao Voodoo, Crusher, Kenshin, Kenshin Royce,
Masamune, Masamune suppressed, Senkoh, Senkoh Prototype, Shingen, Silverhand, Ticon, Ticon Reed)
= 28 fields, plus Borg4a's charge and the Toygun's burst and charge = **31**. Borg4a, Ticon and
Ticon Reed are `ep1` sets (5 fields); the other 26 are `base`. So the load lines go from 173 + 18
to **199 + 23** (222 fields).
