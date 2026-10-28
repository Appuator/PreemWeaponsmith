# ADR 0004: Add-ons extend the catalogue through `PreemAddons` hook points

- Status: accepted (2026-10-28, planning Phase 10)

## Context
The user is making an add-on for the Cyberpunk Modathon 2026: hacker barrels on their own Nexus page, needing Preem Weaponsmith (`notes/hacker-barrel-ideas.md`). The catalogue is closed today: `PreemModMaker` (the mods of a slot class, each style's definition), `PreemModMapper` (style to item) and the `PreemModUnlocker` tier lists are switches and fixed lists on `PreemModStyleType`. An add-on can't add to them except by wrapping those internal methods. redscript can't add enum values from another mod either. The options were:
- **The add-on wraps the internal methods** (`GetModsFromClassType`, `GetModFromModStyleType`, the mapper, each tier list). Works today with no core change, but ties the add-on to their exact shape: any core refactor breaks it, and players then have a broken pair of mods.
- **A registry** an add-on fills at load. Cleaner for many add-ons, but core would need its own load-order handling and storage, more than one add-on needs.
- **Hook points:** empty public static methods that core calls at each catalogue step, for add-ons to `@wrapMethod`.

## Decision
(user, 2026-10-28) Core gets `PreemAddons`: an API version and empty static hook points for listing a slot class's mods, defining a style, mapping a style to its item, and building each unlock tier list. Each add-on style has a named value in `PreemModStyleType` that core doesn't offer itself (`Barrel_Hacker`, `Barrel_Cripple`). Released in 2.6.0, before the add-on.

## Consequences
- The hook points are a public API. Renaming or reshaping one breaks add-ons, so a change bumps the API version and goes in the CHANGELOG; `docs/ADDONS.md` says what stays stable.
- Every new add-on style needs a core release for its enum value. Accepted while there is one add-on; reserving a block later is possible.
- Read-back (`GetInstalledMods`) goes through the list and the mapper, so add-on mods show on the Upgrades tab and count toward the mod limit with no extra hook.
- Several add-ons can wrap the same hook point; each must call `wrappedMethod` and only add its own styles.
