# Preem mods on the weapon upgrade screen (idea, not decided)

Raised by the user on 2026-10-25. Start this after the 2.5 conversion (Phases 0–4).

## Want
- Players can add Preem mods when **upgrading** a weapon, not only when crafting one.
- This opens Preem mods to **iconic weapons**. Iconics can't be crafted from a blueprint, only upgraded, so today they can never get Preem mods.

## How it works today (2.2.5)
- Everything hangs off the crafting tab. `PreemWeaponPreviewContainer.reds` adds fields and methods to `CraftingMainGameController` and wraps `OnInitialize` / `OnCraftingComplete` / `CraftingMainLogicController.OnPressSelectedItem`.
- Mods are applied at craft time. `PreemCraftingSystemAdapter` wraps `CraftingSystem.CraftItem`, which creates the item from the **evolution variant** record (`<weapon>_Preem<Evo>`) when an evolution barrel is chosen, then `PreemCraftingSystem.ApplyMods` installs each mod into its Preem slot.
- The Sandbox 2.2.4 build has a commented-out `upgradePanel` lookup in `PreemWeaponPreviewContainer`, an earlier attempt at the same idea.

## What changes on the upgrade path
| Concern | Crafting today | Upgrade screen |
|---|---|---|
| Item | Brand new item, made from a record we pick | Existing item the player owns (`ItemID` already fixed) |
| Evolution barrels | Pick the `_Preem<Evo>` variant record at creation | Can't change an existing item's record. Either replace the item (new `ItemID`: loses quest flags, iconic identity, the weapon's level and equipped state) or disable evolution barrels on upgrade |
| Already-installed Preem mods | None | Must be shown in the slots, counted toward the mod limit, and replaceable or removable (refund?) |
| Mod limit / unlocks | Based on the crafted weapon's rarity | Rarity after the upgrade, or before it? |
| Iconics | n/a | Iconics have their own attacks, trigger modes and sometimes scripted effects. Trigger/attack hooks in `PreemWeaponAdapter` may override iconic behaviour |
| Hooks | `CraftingSystem.CraftItem` | 2.5 upgrade flow (`CraftingSystem` upgrade request / upgrade screen controller). Find in `game-scripts` |

## Open questions
- Which 2.5 classes drive the upgrade tab, and does it share `CraftingMainGameController` with crafting? (Check `game-scripts` after Phase 0.)
- Evolution barrels on upgrade: disallow, or do a controlled item swap? Iconics should probably never change evolution.
- Removing a Preem mod from an owned weapon: allowed? Cost?
- Should the Preem slot frame look the same on both screens? Ideally it's one shared UI component that both screens host.

## Likely shape (to confirm)
1. Prefactor: pull the slot frame and popup wiring out of `CraftingMainGameController` into a host-agnostic component that crafting and upgrade both use.
2. Install mods onto an existing `gameItemData` through the same `PreemCraftingSystem.ApplyMods` path (the test seam), with "already installed" read back from the item's Preem slots.
3. Upgrade-screen host plus hooks.
4. Iconic rules (no evolution change; check trigger/attack hooks respect iconic behaviour).
