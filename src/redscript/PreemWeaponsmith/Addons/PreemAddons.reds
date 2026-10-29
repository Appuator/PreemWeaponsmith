module PreemCrafting.Addons
import PreemCrafting.Core.*

// Add-on mods (SPEC §9, ADR 0005, docs/ADDONS.md). An add-on is a class that extends PreemAddon and
// overrides the methods it needs; core finds every such class itself (PreemAddonRegistry) and asks
// it about its own mods only. An add-on names each of its mods with its own CName ID, and core gives
// each ID a PreemModStyleType value of its own (PreemAddons.StyleOf), so a new add-on mod needs no
// core release. With no add-on installed the catalogue is core's own.
// redscript can't @wrapMethod a class compiled with the mods, which is why this isn't wrap-based.
// These methods are a public API: change one only with an ApiVersion bump and a CHANGELOG line.
public abstract class PreemAddon extends IScriptable {
  // The PreemAddons.ApiVersion() the add-on was written against. Core skips an add-on that needs a
  // newer API than it has.
  public func RequiredApiVersion() -> Int32 {
    return 1;
  }

  // Every mod the add-on owns, by ID (prefix it with the add-on's module, e.g.
  // n"MyAddon.HackerBarrel"). Asked once, when core finds the add-on; core gives each ID its style.
  public func GetModIds() -> array<CName> {
    let ids: array<CName>;
    return ids;
  }

  // Fills in one of the add-on's mods: at least its slot class (which decides where it's offered),
  // name and text; requirements by PreemAddons.StyleOf(id) for other add-on mods. Returns false to
  // leave the mod out for now. Everything that lists mods asks this: the slot frame, the Upgrades
  // tab and the read-back of a weapon's installed mods.
  public func DefineMod(id: CName, mod: ref<PreemMod>) -> Bool {
    return false;
  }

  // The mod's item record (TweakXL), or TDBID.None() for core's fallback, Items.TestMod1.
  public func MapItem(id: CName) -> TweakDBID {
    return TDBID.None();
  }

  // The weapon blueprint quality that unlocks the mod under Weapon Blueprints (Sandbox unlocks
  // everything). Core adds it to that quality's tier list (PreemModUnlocker), so the unlock check
  // and the requirement text follow. gamedataQuality.Invalid (the default) leaves it locked under
  // Weapon Blueprints.
  public func GetUnlockQuality(id: CName) -> gamedataQuality {
    return gamedataQuality.Invalid;
  }
}

public abstract class PreemAddons {
  // Bumped when a PreemAddon method changes in a way an add-on written against the old one breaks on.
  public static func ApiVersion() -> Int32 {
    return 1;
  }

  // The style core gave an add-on mod's ID; a value no core style uses. Only valid for the game
  // session: never save it (save the ID). An ID no add-on owns gives a style no mod has.
  public static func StyleOf(id: CName) -> PreemModStyleType {
    let registry = PreemAddons.Registry();
    let index = IsDefined(registry) ? registry.IndexOf(id) : -1;
    return IntEnum<PreemModStyleType>(index < 0 ? -1 : PreemAddons.FirstStyle() + index);
  }

  // The add-on mod ID of a style, or n"None" for a core style.
  public static func IdOf(style: PreemModStyleType) -> CName {
    let registry = PreemAddons.Registry();
    return IsDefined(registry) ? registry.IdAt(EnumInt(style) - PreemAddons.FirstStyle()) : n"None";
  }

  // Core's calls. Each asks only the add-on that owns the style.

  // The add-on styles offered in a slot class: those whose add-on defines them with that class now.
  public static func GetStyles(classType: PreemModClassType) -> array<PreemModStyleType> {
    let styles: array<PreemModStyleType>;
    let registry = PreemAddons.Registry();
    if !IsDefined(registry) {
      return styles;
    }
    let i = 0;
    while i < registry.Count() {
      let style = IntEnum<PreemModStyleType>(PreemAddons.FirstStyle() + i);
      let mod = new PreemMod();
      mod.modStyleType = style;
      if registry.OwnerAt(i).DefineMod(registry.IdAt(i), mod) && Equals(mod.preemClassType, classType) {
        ArrayPush(styles, style);
      }
      i += 1;
    }
    return styles;
  }

  public static func DefineMod(styleType: PreemModStyleType, mod: ref<PreemMod>) -> Bool {
    let registry = PreemAddons.Registry();
    let index = EnumInt(styleType) - PreemAddons.FirstStyle();
    return IsDefined(registry) && IsDefined(registry.OwnerAt(index)) && registry.OwnerAt(index).DefineMod(registry.IdAt(index), mod);
  }

  public static func MapItem(styleType: PreemModStyleType) -> TweakDBID {
    let registry = PreemAddons.Registry();
    let index = EnumInt(styleType) - PreemAddons.FirstStyle();
    if !IsDefined(registry) || !IsDefined(registry.OwnerAt(index)) {
      return TDBID.None();
    }
    return registry.OwnerAt(index).MapItem(registry.IdAt(index));
  }

  // Every add-on style whose unlock quality is exactly this one.
  public static func GetStylesUnlockedAt(quality: gamedataQuality) -> array<PreemModStyleType> {
    let styles: array<PreemModStyleType>;
    let registry = PreemAddons.Registry();
    if !IsDefined(registry) {
      return styles;
    }
    let i = 0;
    while i < registry.Count() {
      if Equals(registry.OwnerAt(i).GetUnlockQuality(registry.IdAt(i)), quality) {
        ArrayPush(styles, IntEnum<PreemModStyleType>(PreemAddons.FirstStyle() + i));
      }
      i += 1;
    }
    return styles;
  }

  // Add-on styles start here, far above core's own (0 to 504 in 2.6.0).
  private static func FirstStyle() -> Int32 {
    return 10000;
  }

  private static func Registry() -> ref<PreemAddonRegistry> {
    return GameInstance.GetScriptableServiceContainer().GetService(n"PreemCrafting.Addons.PreemAddonRegistry") as PreemAddonRegistry;
  }
}

// Finds the add-on classes once, on first use, with Codeware's reflection (the class list doesn't
// change after the scripts load), keeps one instance of each for the game session, and numbers
// every add-on mod ID: sorted by ID, the n-th gets style FirstStyle + n. A Codeware
// ScriptableService has a single instance reachable from static code with no GameInstance.
public class PreemAddonRegistry extends ScriptableService {
  private let m_ids: array<CName>;
  private let m_owners: array<ref<PreemAddon>>;
  private let m_found: Bool;

  public func Count() -> Int32 {
    this.Find();
    return ArraySize(this.m_ids);
  }

  public func IndexOf(id: CName) -> Int32 {
    this.Find();
    let i = 0;
    while i < ArraySize(this.m_ids) {
      if Equals(this.m_ids[i], id) {
        return i;
      }
      i += 1;
    }
    return -1;
  }

  public func IdAt(index: Int32) -> CName {
    this.Find();
    return index >= 0 && index < ArraySize(this.m_ids) ? this.m_ids[index] : n"None";
  }

  public func OwnerAt(index: Int32) -> ref<PreemAddon> {
    this.Find();
    return index >= 0 && index < ArraySize(this.m_owners) ? this.m_owners[index] : null;
  }

  private func Find() -> Void {
    if this.m_found {
      return;
    }
    this.m_found = true;
    for cls in Reflection.GetDerivedClasses(n"PreemCrafting.Addons.PreemAddon") {
      if !cls.IsAbstract() {
        // redscript warns this cast can't succeed (it doesn't see IScriptable under
        // ISerializable), but it does at runtime; FromVariant(cls.MakeInstance()) gives null.
        let addon = cls.MakeHandle() as PreemAddon;
        if IsDefined(addon) {
          let className = NameToString(cls.GetName());
          if addon.RequiredApiVersion() <= PreemAddons.ApiVersion() {
            let ids = addon.GetModIds();
            FTLog(s"[PreemWeaponsmith] add-on \(className): \(ArraySize(ids)) mods");
            for id in ids {
              this.Insert(id, addon, className);
            }
          } else {
            FTLog(s"[PreemWeaponsmith] add-on \(className) skipped: needs add-on API \(addon.RequiredApiVersion()), this version has \(PreemAddons.ApiVersion())");
          }
        }
      }
    }
  }

  // Keeps m_ids sorted, so a mod's style doesn't depend on the order the add-ons are found in.
  private func Insert(id: CName, owner: ref<PreemAddon>, className: String) -> Void {
    let name = NameToString(id);
    let at = 0;
    while at < ArraySize(this.m_ids) && StrCmp(NameToString(this.m_ids[at]), name) < 0 {
      at += 1;
    }
    if at < ArraySize(this.m_ids) && Equals(this.m_ids[at], id) {
      FTLog(s"[PreemWeaponsmith] add-on \(className): mod ID \(name) is already another add-on's; ignored");
      return;
    }
    ArrayInsert(this.m_ids, at, id);
    ArrayInsert(this.m_owners, at, owner);
  }
}
