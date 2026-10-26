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
