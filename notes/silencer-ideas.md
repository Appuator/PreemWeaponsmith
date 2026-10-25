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

## Directions to evaluate
| Option | Idea | Pros | Cons |
|---|---|---|---|
| A. Stat/flag based | Make the Preem silencer a normal Preem barrel mod (in a Preem slot) that sets whatever weapon-level silenced stat or flag the game reads; wrap the silenced check to also consider it | Works on every gun; no mesh or socket needed; no special-case slot code | Needs the right check(s) found; no visible silencer |
| B. Hook the silenced check | `@wrapMethod` the method(s) that answer "is this weapon silenced" (weapon, noise and stealth paths) to return true when the Preem silencer is installed | Precise; small | Several call sites possible; one hook per path to maintain |
| C. Keep the attachment, extend support | Add muzzle slot + socket support to more weapons (TweakXL + ArchiveXL appearance edits) | Visible silencer | Per-weapon mesh work; heavy upkeep every patch |
| Audio (with A or B) | Play suppressed fire sounds through Audioware instead of the full metadata override | Fixes the "sounds wrong" part on every gun | Needs Phase 3's Audioware decision |

The likely answer is A or B for behaviour, plus Audioware for sound, and no visible attachment on guns that never had one. Option C only if a visible silencer matters enough.

## Open questions
- What exactly makes a weapon count as silenced in 2.5 (stat, attachment query, or both)? Answer from `game-scripts`.
- Is a visible silencer required, or is behaviour plus sound enough?
- Keep save compatibility for existing silenced Preem weapons (the item sits in `PowerModule` today)?
