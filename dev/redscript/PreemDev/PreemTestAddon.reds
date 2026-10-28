// Dev only, never shipped. A test add-on built the way docs/ADDONS.md says an add-on is built: a
// PreemAddon subclass that adds one barrel, Barrel_Hacker, on its own item record
// (Items.DevAddonBarrel, a clone of Items.TestMod1, so it can't be mistaken for core's fallback).
// It is off unless a test or a dev command turns it on (PreemTestAddonSwitch.SetOn), so every other
// dev run sees core's own catalogue. Compiled only when the mod is installed.
module PreemDev.Addon

@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Addons.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Core.*

// The on/off switch, in a Codeware ScriptableService: one instance for the game session, reachable
// from static code.
public class PreemTestAddonSwitch extends ScriptableService {
  private let m_on: Bool;

  private static func Get() -> ref<PreemTestAddonSwitch> {
    return GameInstance.GetScriptableServiceContainer().GetService(n"PreemDev.Addon.PreemTestAddonSwitch") as PreemTestAddonSwitch;
  }

  public static func IsOn() -> Bool {
    let service = PreemTestAddonSwitch.Get();
    return IsDefined(service) && service.m_on;
  }

  public static func SetOn(on: Bool) -> Void {
    let service = PreemTestAddonSwitch.Get();
    if IsDefined(service) {
      service.m_on = on;
    }
  }

  public static func Item() -> TweakDBID {
    return t"Items.DevAddonBarrel";
  }
}

// The add-on's item record. A real add-on ships it as TweakXL YAML; dev-install copies only
// redscript, so the test add-on makes it here. Exists whether the add-on is on or off.
@if(ModuleExists("PreemCrafting.Addons"))
public class PreemTestAddonRecords extends ScriptableTweak {
  protected cb func OnApply() -> Void {
    TweakDBManager.CloneRecord(n"Items.DevAddonBarrel", t"Items.TestMod1");
  }
}

@if(ModuleExists("PreemCrafting.Addons"))
public class PreemTestAddon extends PreemAddon {
  public func GetStyles(classType: PreemModClassType) -> array<PreemModStyleType> {
    let styles: array<PreemModStyleType>;
    if PreemTestAddonSwitch.IsOn() && Equals(classType, PreemModClassType.Barrel) {
      ArrayPush(styles, PreemModStyleType.Barrel_Hacker);
    }
    return styles;
  }

  public func DefineMod(styleType: PreemModStyleType, mod: ref<PreemMod>) -> Bool {
    if !PreemTestAddonSwitch.IsOn() || NotEquals(styleType, PreemModStyleType.Barrel_Hacker) {
      return false;
    }
    mod.preemClassType = PreemModClassType.Barrel;
    mod.SetModName(n"DevAddonBarrel");
    mod.SetDescription("Dev test add-on barrel");
    return true;
  }

  public func MapItem(styleType: PreemModStyleType) -> TweakDBID {
    if PreemTestAddonSwitch.IsOn() && Equals(styleType, PreemModStyleType.Barrel_Hacker) {
      return PreemTestAddonSwitch.Item();
    }
    return TDBID.None();
  }
}
