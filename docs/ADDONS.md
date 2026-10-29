# Writing an add-on for Preem Weaponsmith

An add-on is a separate mod that adds its own Preem mods to Preem Weaponsmith's catalogue. Its mods are offered in the crafting screen's slot frame, unlocked by blueprint quality, crafted, shown on the Upgrades tab, counted toward the mod limit and read back from a weapon exactly like core's own. An add-on needs nothing from a core release: it names its own mods. Add-on API version: **1** (core 2.6.0). Background: SPEC §9, [ADR 0005](adr/0005-addon-subclasses.md).

## What an add-on brings
1. **An ID for each mod**: a CName of your choosing, prefixed with your add-on's module so it can't clash with another add-on's (`n"MyAddon.HackerBarrel"`). The ID is how your code names the mod everywhere. Core gives each ID a `PreemModStyleType` value of its own when it finds your add-on; you never pick or reserve one.
2. **An item record** per mod (TweakXL YAML in the add-on's own `r6/tweaks/<AddOn>/` folder). Base it on `Items.SimpleWeaponMod01`, and set `placementSlots` to both Preem slots of its slot class:

   | Slot class | `placementSlots` |
   |---|---|
   | Barrel | `AttachmentSlots.PreemBarrelMod01`, `AttachmentSlots.PreemBarrelMod02` |
   | Trigger | `AttachmentSlots.PreemTriggerMod01`, `AttachmentSlots.PreemTriggerMod02` |
   | Mag | `AttachmentSlots.PreemMagazineMod01`, `AttachmentSlots.PreemMagazineMod02` |
   | Blade | `AttachmentSlots.PreemBladeMod01`, `AttachmentSlots.PreemBladeMod02` |
   | Handle | `AttachmentSlots.PreemHandleMod01`, `AttachmentSlots.PreemHandleMod02` |

   Stat changes go in `statModifiers`, as in core's `tweaks/barrels.yaml`. The record's ID is what a weapon carries in its save: once released, don't rename it. (The mod ID isn't saved anywhere, but keep it stable too.)
3. **One `PreemAddon` subclass** (below): your mod IDs, their definitions, items and unlock quality.
4. **Any behaviour of its own**, as the add-on's own hooks on game classes (`@wrapMethod` on a game class, which works; see "Limits"). To find out whether a weapon carries your mod, check the weapon's item data for a part with your record in one of the slots above (`gameItemData.HasPartInSlot` / `GetItemPart`).

Core needs nothing else: no edits to its files, no load order, no core release.

## The `PreemAddon` class
Module `PreemCrafting.Addons`. Extend it once and override what you need; every method has a default that does nothing. Core finds every non-abstract subclass itself (Codeware's `Reflection.GetDerivedClasses`), makes one instance of it for the game session, and logs `[PreemWeaponsmith] add-on <YourModule.YourClass>: <n> mods` to CET's game log the first time it builds the catalogue.

| Method | Core calls it | Return |
|---|---|---|
| `RequiredApiVersion() -> Int32` | once, when it finds the class | The `PreemAddons.ApiVersion()` you wrote against (default 1). If core's is older, your add-on is skipped and core logs `skipped: needs add-on API <n>, this version has <m>`. |
| `GetModIds() -> array<CName>` | once, when it finds the class | Every mod ID your add-on owns. An ID another add-on already owns is ignored, with a log line. |
| `DefineMod(id: CName, mod: ref<PreemMod>) -> Bool` | whenever it lists or defines mods | For one of your IDs: fill in `mod` and return true. Return false to leave the mod out for now (it isn't offered and doesn't read back). |
| `MapItem(id: CName) -> TweakDBID` | when it needs the mod's item | Your item record, or `TDBID.None()`. |
| `GetUnlockQuality(id: CName) -> gamedataQuality` | when it builds the unlock tiers | The blueprint quality that unlocks the mod under Weapon Blueprints (Sandbox unlocks everything). The default, `gamedataQuality.Invalid`, keeps it locked under Weapon Blueprints. |

In `DefineMod`, set at least:
- `mod.preemClassType` (the slot class; the mod is offered in that class's slots);
- `mod.SetModName(n"...")` (the name shown on the mod);
- `mod.SetDescription("...")` (what it does) and `mod.SetAdditionalDescription("...")` (flavour text), both shown in the slot frame. Without them, the mod shows core's placeholder text.

Optionally:
- `mod.AddRequiredMod(style)` (needs that mod slotted first);
- `mod.AddIncompatMod(style)` (can't be on one weapon with it);
- `mod.SetRequiredEvolution(gamedataWeaponEvolution.Smart)` (only for that evolution).

The required and incompatible lists take styles. Use `PreemModStyleType.Barrel_Smart` and the like for a core mod, and `PreemAddons.StyleOf(n"MyAddon.OtherMod")` for one of yours, or another add-on's.

Don't set `mod.modStyleType`: core does. The strings are what players read, so the add-on writes its own.

Core asks an add-on only about its own IDs, and only where core has no answer of its own. An add-on can't change or remove a core mod.

### Styles and IDs
`PreemAddons.StyleOf(id) -> PreemModStyleType` gives the style core assigned to a mod ID, and `PreemAddons.IdOf(style) -> CName` goes the other way (`n"None"` for a core style). Use them when you need a style: requirements, or checking a `PreemMod`'s `modStyleType`. An add-on style is a value from 10000 up, sorted by ID across all installed add-ons. It can change when add-ons are added or removed, so never save it, and never write it as a number: save the ID, and call `StyleOf` when you need the style.

## Example
The test add-on core's own tests use (`dev/redscript/PreemDev/PreemTestAddon.reds`) is a complete working add-on with two barrels, one requiring the other. It turns its mods off unless a test switches them on, which a real add-on doesn't need. Stripped down to that, an add-on with one barrel looks like this:

```swift
module MyAddon
import PreemCrafting.Addons.*
import PreemCrafting.Core.*

public class MyAddon extends PreemAddon {
  public func GetModIds() -> array<CName> {
    return [n"MyAddon.HackerBarrel"];
  }

  public func DefineMod(id: CName, mod: ref<PreemMod>) -> Bool {
    if NotEquals(id, n"MyAddon.HackerBarrel") {
      return false;
    }
    mod.preemClassType = PreemModClassType.Barrel;
    mod.SetModName(n"<name>");
    mod.SetDescription("<what it does>");
    mod.SetAdditionalDescription("<flavour text>");
    return true;
  }

  public func MapItem(id: CName) -> TweakDBID {
    if Equals(id, n"MyAddon.HackerBarrel") {
      return t"Items.MyAddonHackerBarrel";
    }
    return TDBID.None();
  }

  public func GetUnlockQuality(id: CName) -> gamedataQuality {
    if Equals(id, n"MyAddon.HackerBarrel") {
      return gamedataQuality.Rare;
    }
    return gamedataQuality.Invalid;
  }
}
```

The add-on's requirements are Preem Weaponsmith 2.6.0 or later, and the frameworks Preem Weaponsmith needs (redscript, Codeware, TweakXL).

## What core keeps stable
- The `PreemAddon` methods above, `PreemAddons.ApiVersion()`, `StyleOf` and `IdOf`, their names, parameters and meaning. A change to any of them bumps the API version and is listed in the CHANGELOG. An add-on written for an older version keeps working unless the CHANGELOG says otherwise.
- The values of core's `PreemModStyleType` styles and `PreemModClassType`, and the Preem slot IDs in the table above. Add-on styles are not stable values (see "Styles and IDs").
- Everything else in core (`PreemModMaker`, `PreemModMapper`, `PreemModUnlocker`, `PreemCraftingSystem` and the rest) is internal and may change in any release. Don't call or rely on it.

## Limits
- **No `@wrapMethod` on core's classes.** redscript 0.5.32 can only wrap classes from the game's own scripts, not a class compiled with the mods (core and every add-on compile together). Use `PreemAddon` for the catalogue, and wrap game classes for behaviour.
- The console (mod.io) build of Preem Weaponsmith doesn't support add-ons yet: they need Codeware's reflection.
