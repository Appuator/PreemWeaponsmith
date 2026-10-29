# Writing an add-on for Preem Weaponsmith

An add-on is a separate mod that adds its own Preem mods to Preem Weaponsmith's catalogue. Its mods are offered in the crafting screen's slot frame, unlocked by blueprint quality, crafted, shown on the Upgrades tab, counted toward the mod limit and read back from a weapon exactly like core's own. Add-on API version: **1** (core 2.6.0). Background: SPEC §9, [ADR 0005](adr/0005-addon-subclasses.md).

## What an add-on brings
1. **A mod style value.** redscript can't add values to another mod's enum, so every add-on mod uses a named `PreemModStyleType` value that core reserves but doesn't offer itself. Reserved today: `Barrel_Hacker` (6) and `Barrel_Cripple` (20), for the hacker barrels add-on. A new add-on mod needs its value added in a core release first; ask for it.
2. **An item record** per mod (TweakXL YAML in the add-on's own `r6/tweaks/<AddOn>/` folder). Base it on `Items.SimpleWeaponMod01`, and set `placementSlots` to both Preem slots of its slot class:

   | Slot class | `placementSlots` |
   |---|---|
   | Barrel | `AttachmentSlots.PreemBarrelMod01`, `AttachmentSlots.PreemBarrelMod02` |
   | Trigger | `AttachmentSlots.PreemTriggerMod01`, `AttachmentSlots.PreemTriggerMod02` |
   | Mag | `AttachmentSlots.PreemMagazineMod01`, `AttachmentSlots.PreemMagazineMod02` |
   | Blade | `AttachmentSlots.PreemBladeMod01`, `AttachmentSlots.PreemBladeMod02` |
   | Handle | `AttachmentSlots.PreemHandleMod01`, `AttachmentSlots.PreemHandleMod02` |

   Stat changes go in `statModifiers`, as in core's `tweaks/barrels.yaml`. The record's ID is save-visible: once released, don't rename it.
3. **One `PreemAddon` subclass** (below): which styles it adds, their definitions, items and unlock quality.
4. **Any behaviour of its own**, as the add-on's own hooks on game classes (`@wrapMethod` on a game class, which works; see "Limits"). To find out whether a weapon carries the add-on's mod, check the weapon's item data for a part with the add-on's record in one of the slots above (`gameItemData.HasPartInSlot` / `GetItemPart`).

Core needs nothing else: no edits to its files, no load order.

## The `PreemAddon` class
Module `PreemCrafting.Addons`. Extend it once and override what you need; every method has a default that does nothing. Core finds every non-abstract subclass itself (Codeware's `Reflection.GetDerivedClasses`), makes one instance of it for the game session, and logs `[PreemWeaponsmith] add-on <YourModule.YourClass>` to CET's game log the first time it builds the catalogue.

| Method | Core calls it | Return |
|---|---|---|
| `RequiredApiVersion() -> Int32` | once, when it finds the class | The `PreemAddons.ApiVersion()` you wrote against (default 1). If core's is older, your add-on is skipped and core logs `skipped: needs add-on API <n>, this version has <m>`. |
| `GetStyles(classType: PreemModClassType) -> array<PreemModStyleType>` | every time it lists a slot class's mods | Your styles in that class, offered after core's own. |
| `DefineMod(styleType, mod: ref<PreemMod>) -> Bool` | for a style core has no definition for | For your own style: fill in `mod` and return true. Otherwise false. |
| `MapItem(styleType) -> TweakDBID` | for a style core has no item for | Your style's item record, or `TDBID.None()`. |
| `GetUnlockQuality(styleType) -> gamedataQuality` | for each style `GetStyles` lists, when it builds the unlock tiers | The blueprint quality that unlocks it under Weapon Blueprints (Sandbox unlocks everything). The default, `gamedataQuality.Invalid`, keeps it locked under Weapon Blueprints. |

In `DefineMod`, set at least:
- `mod.preemClassType` (the slot class);
- `mod.SetModName(n"...")` (the name shown on the mod);
- `mod.SetDescription("...")` (what it does) and `mod.SetAdditionalDescription("...")` (flavour text), both shown in the slot frame. Without them, the mod shows core's placeholder text.

Optionally:
- `mod.AddRequiredMod(style)` (needs that mod slotted first);
- `mod.AddIncompatMod(style)` (can't be on one weapon with it);
- `mod.SetRequiredEvolution(gamedataWeaponEvolution.Smart)` (only for that evolution).

Don't set `modStyleType`: core does. These strings are what players read, so the add-on writes its own.

Core asks add-ons only where it has no answer of its own. An add-on can't change or remove a core mod, and if two add-ons claim the same style, the first one core found wins.

## Example
The test add-on core's own tests use (`dev/redscript/PreemDev/PreemTestAddon.reds`) is a complete working add-on. It turns itself off unless a test switches it on, which a real add-on doesn't need. Stripped down to that, an add-on with one barrel looks like this:

```swift
module MyAddon
import PreemCrafting.Addons.*
import PreemCrafting.Core.*

public class MyAddon extends PreemAddon {
  public func GetStyles(classType: PreemModClassType) -> array<PreemModStyleType> {
    let styles: array<PreemModStyleType>;
    if Equals(classType, PreemModClassType.Barrel) {
      ArrayPush(styles, PreemModStyleType.Barrel_Hacker);
    }
    return styles;
  }

  public func DefineMod(styleType: PreemModStyleType, mod: ref<PreemMod>) -> Bool {
    if NotEquals(styleType, PreemModStyleType.Barrel_Hacker) {
      return false;
    }
    mod.preemClassType = PreemModClassType.Barrel;
    mod.SetModName(n"<name>");
    mod.SetDescription("<what it does>");
    mod.SetAdditionalDescription("<flavour text>");
    return true;
  }

  public func MapItem(styleType: PreemModStyleType) -> TweakDBID {
    if Equals(styleType, PreemModStyleType.Barrel_Hacker) {
      return t"Items.MyAddonBarrel";
    }
    return TDBID.None();
  }

  public func GetUnlockQuality(styleType: PreemModStyleType) -> gamedataQuality {
    if Equals(styleType, PreemModStyleType.Barrel_Hacker) {
      return gamedataQuality.Rare;
    }
    return gamedataQuality.Invalid;
  }
}
```

The add-on's requirements are Preem Weaponsmith 2.6.0 or later, and the frameworks Preem Weaponsmith needs (redscript, Codeware, TweakXL).

## What core keeps stable
- The `PreemAddon` methods above, their names, parameters and meaning, and `PreemAddons.ApiVersion()`. A change to any of them bumps the API version and is listed in the CHANGELOG. An add-on written for an older version keeps working unless the CHANGELOG says otherwise.
- The values of `PreemModStyleType` and `PreemModClassType`, and the Preem slot IDs in the table above.
- Everything else in core (`PreemModMaker`, `PreemModMapper`, `PreemModUnlocker`, `PreemCraftingSystem` and the rest) is internal and may change in any release. Don't call or rely on it.

## Limits
- **No `@wrapMethod` on core's classes.** redscript 0.5.32 can only wrap classes from the game's own scripts, not a class compiled with the mods (core and every add-on compile together). Use `PreemAddon` for the catalogue, and wrap game classes for behaviour.
- **No new enum values from the add-on**: see "What an add-on brings".
- The console (mod.io) build of Preem Weaponsmith doesn't support add-ons yet: they need Codeware's reflection.
