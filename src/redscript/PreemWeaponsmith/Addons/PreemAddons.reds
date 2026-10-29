module PreemCrafting.Addons
import PreemCrafting.Core.*

// Add-on mods (SPEC §9, ADR 0005, docs/ADDONS.md). An add-on is a class that extends PreemAddon and
// overrides the methods it needs; core finds every such class itself (PreemAddons.All) and asks
// each one at the catalogue steps below. With no add-on installed the catalogue is core's own.
// redscript can't @wrapMethod a class compiled with the mods, which is why this isn't wrap-based.
// These methods are a public API: change one only with an ApiVersion bump and a CHANGELOG line.
public abstract class PreemAddon extends IScriptable {
  // The PreemAddons.ApiVersion() the add-on was written against. Core skips an add-on that needs a
  // newer API than it has.
  public func RequiredApiVersion() -> Int32 {
    return 1;
  }

  // The add-on's styles in a slot class, offered after core's own (PreemModMaker.GetModsFromClassType).
  // Everything that lists mods goes through here: the slot frame, the Upgrades tab and the read-back
  // of a weapon's installed mods.
  public func GetStyles(classType: PreemModClassType) -> array<PreemModStyleType> {
    let styles: array<PreemModStyleType>;
    return styles;
  }

  // Called for a style core has no definition for (PreemModMaker.GetModFromModStyleType). An add-on
  // that owns the style fills in the mod (class, name, text, requirements) and returns true.
  public func DefineMod(styleType: PreemModStyleType, mod: ref<PreemMod>) -> Bool {
    return false;
  }

  // Called for a style core has no item for (PreemModMapper.GetGameModFromPreemMod). An add-on that
  // owns the style returns its item record; TDBID.None() leaves it to the next add-on or core's
  // fallback, Items.TestMod1.
  public func MapItem(styleType: PreemModStyleType) -> TweakDBID {
    return TDBID.None();
  }

  // The weapon blueprint quality that unlocks one of the add-on's styles under Weapon Blueprints
  // (Sandbox unlocks everything). Asked for each style GetStyles lists; core adds it to that
  // quality's tier list (PreemModUnlocker), so the unlock check and the requirement text follow.
  // gamedataQuality.Invalid (the default) leaves the style locked under Weapon Blueprints.
  public func GetUnlockQuality(styleType: PreemModStyleType) -> gamedataQuality {
    return gamedataQuality.Invalid;
  }
}

public abstract class PreemAddons {
  // Bumped when a PreemAddon method changes in a way an add-on written against the old one breaks on.
  public static func ApiVersion() -> Int32 {
    return 1;
  }

  // One instance of every installed add-on class (PreemAddonRegistry).
  public static func All() -> array<ref<PreemAddon>> {
    let registry = GameInstance.GetScriptableServiceContainer().GetService(n"PreemCrafting.Addons.PreemAddonRegistry") as PreemAddonRegistry;
    if !IsDefined(registry) {
      let none: array<ref<PreemAddon>>;
      return none;
    }
    return registry.GetAddons();
  }

  public static func GetStyles(classType: PreemModClassType) -> array<PreemModStyleType> {
    let styles: array<PreemModStyleType>;
    for addon in PreemAddons.All() {
      for style in addon.GetStyles(classType) {
        ArrayPush(styles, style);
      }
    }
    return styles;
  }

  // The first add-on that owns the style defines it.
  public static func DefineMod(styleType: PreemModStyleType, mod: ref<PreemMod>) -> Bool {
    for addon in PreemAddons.All() {
      if addon.DefineMod(styleType, mod) {
        return true;
      }
    }
    return false;
  }

  public static func MapItem(styleType: PreemModStyleType) -> TweakDBID {
    for addon in PreemAddons.All() {
      let id = addon.MapItem(styleType);
      if TDBID.IsValid(id) {
        return id;
      }
    }
    return TDBID.None();
  }

  // Every add-on style (of any slot class) whose unlock quality is exactly this one.
  public static func GetStylesUnlockedAt(quality: gamedataQuality) -> array<PreemModStyleType> {
    let styles: array<PreemModStyleType>;
    let classes: array<PreemModClassType> = [PreemModClassType.Barrel, PreemModClassType.Trigger, PreemModClassType.Mag, PreemModClassType.Sight, PreemModClassType.Blade, PreemModClassType.Handle, PreemModClassType.Blunt];
    for addon in PreemAddons.All() {
      for classType in classes {
        for style in addon.GetStyles(classType) {
          if Equals(addon.GetUnlockQuality(style), quality) && !ArrayContains(styles, style) {
            ArrayPush(styles, style);
          }
        }
      }
    }
    return styles;
  }
}

// Finds the add-on classes once, on first use, with Codeware's reflection (the class list doesn't
// change after the scripts load), and keeps one instance of each for the game session. A Codeware
// ScriptableService has a single instance reachable from static code with no GameInstance.
public class PreemAddonRegistry extends ScriptableService {
  private let m_addons: array<ref<PreemAddon>>;
  private let m_found: Bool;

  public func GetAddons() -> array<ref<PreemAddon>> {
    if !this.m_found {
      this.m_found = true;
      for cls in Reflection.GetDerivedClasses(n"PreemCrafting.Addons.PreemAddon") {
        if !cls.IsAbstract() {
          // redscript warns this cast can't succeed (it doesn't see IScriptable under
          // ISerializable), but it does at runtime; FromVariant(cls.MakeInstance()) gives null.
          let addon = cls.MakeHandle() as PreemAddon;
          if IsDefined(addon) {
            if addon.RequiredApiVersion() <= PreemAddons.ApiVersion() {
              ArrayPush(this.m_addons, addon);
              FTLog(s"[PreemWeaponsmith] add-on \(NameToString(cls.GetName()))");
            } else {
              FTLog(s"[PreemWeaponsmith] add-on \(NameToString(cls.GetName())) skipped: needs add-on API \(addon.RequiredApiVersion()), this version has \(PreemAddons.ApiVersion())");
            }
          }
        }
      }
    }
    return this.m_addons;
  }
}
