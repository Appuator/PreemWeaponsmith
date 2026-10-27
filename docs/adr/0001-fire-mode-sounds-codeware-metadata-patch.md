# ADR 0001: Fire-mode sounds come from a Codeware patch of the game's weapon sound settings, not Audioware

- Status: accepted (2026-10-26, Phase 3)
- Replaces: decisions log 2026-10-25 "Sounds move to Audioware"

## Context
Trigger mods give weapons fire modes they never had, and those weapons need auto-fire loop, stop
and burst/charge sounds. Up to 2.2.5 the mod shipped a full copy of the game's
`cooked_metadata.audio_metadata` (`.archive`). That copy has to be rebuilt every patch, rolls back
other vanilla audio entries and clashes with other audio mods. Phase 3 was planned around
Audioware.

The Phase 3 spike (`notes/audioware-sounds.md`) found that:
- Audioware plays only audio files (Kira) and never a game Wwise event;
- every sound the mod needs already exists in the 2.5 Wwise banks;
- the `.archive` only fills empty `autoFireSound`/`autoFireStop`/`burstFireSound`/`chargeStartSound`
  (and a few charge) fields of 70 `audioPlayerWeaponSettings` entries with other weapons' events;
- the game's weapon audio then plays loop, stop and single shots by itself.

Codeware exposes `audioCookedMetadataResource.entries` and every `audioPlayerWeaponSettings` field
to redscript, along with resource-load callbacks.

## Decision
A Preem script fills only those empty fields of the player weapon sound settings in the game's
loaded metadata, from a table the mod owns. It ships no metadata file. Audioware is not used for
fire-mode sounds.

## Consequences
- Patch-safe: only named fields change, and everything else stays the patch's own data. A
  field that vanilla has filled in the meantime can be left alone.
- No clash with other audio mods that don't touch the same fields. NPC settings (`wea_npc_*`) are
  untouched.
- Like the old archive, it works per sound set, not per installed trigger mod. A semi-auto weapon
  whose set gains an auto loop can play the loop when it fires very fast, which is the 2.2.5
  behaviour.
- Unproven until the first slice. The patch must land before the weapon audio reads the
  settings, or the audio system must read them at use time. If neither works, the decision goes
  back to the user. The fallbacks were "script posts Wwise events + Audioware mute", extracted
  files through Audioware, and a slim metadata archive.
- The CLAUDE.md locked line "Sounds go through Audioware, not a base-game `audio_metadata`
  override" needs rewording at the phase end. Whether Audioware stays a dependency at all is
  open; the silencer idea may still want it.
