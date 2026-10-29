// Dev only, never shipped. A test add-on built the way docs/ADDONS.md says an add-on is built: a
// PreemAddon subclass with two barrels by ID, n"PreemDev.TestBarrel" (Rare) and
// n"PreemDev.TestBarrelPlus" (Epic, requires TestBarrel), each on its own item record
// (Items.DevAddonBarrel, Items.DevAddonBarrelPlus: clones of Items.TestMod1, so they can't be
// mistaken for core's fallback). Its mods are off unless a test or a dev command turns them on
// (PreemTestAddonSwitch.SetOn), so every other dev run sees core's own catalogue; the IDs are
// registered either way. Compiled only when the mod is installed.
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

  public static func ItemPlus() -> TweakDBID {
    return t"Items.DevAddonBarrelPlus";
  }
}

// The add-on's item records. A real add-on ships them as TweakXL YAML; dev-install copies only
// redscript, so the test add-on makes them here. They exist whether the add-on is on or off.
@if(ModuleExists("PreemCrafting.Addons"))
public class PreemTestAddonRecords extends ScriptableTweak {
  protected cb func OnApply() -> Void {
    TweakDBManager.CloneRecord(n"Items.DevAddonBarrel", t"Items.TestMod1");
    TweakDBManager.CloneRecord(n"Items.DevAddonBarrelPlus", t"Items.TestMod1");
  }
}

@if(ModuleExists("PreemCrafting.Addons"))
public class PreemTestAddon extends PreemAddon {
  public func GetModIds() -> array<CName> {
    return [n"PreemDev.TestBarrel", n"PreemDev.TestBarrelPlus"];
  }

  public func DefineMod(id: CName, mod: ref<PreemMod>) -> Bool {
    if !PreemTestAddonSwitch.IsOn() {
      return false;
    }
    if Equals(id, n"PreemDev.TestBarrel") {
      mod.preemClassType = PreemModClassType.Barrel;
      mod.SetModName(n"DevAddonBarrel");
      mod.SetDescription("Dev test add-on barrel");
      return true;
    }
    if Equals(id, n"PreemDev.TestBarrelPlus") {
      mod.preemClassType = PreemModClassType.Barrel;
      mod.SetModName(n"DevAddonBarrelPlus");
      mod.SetDescription("Dev test add-on barrel that needs the other one");
      mod.AddRequiredMod(PreemAddons.StyleOf(n"PreemDev.TestBarrel"));
      return true;
    }
    return false;
  }

  public func MapItem(id: CName) -> TweakDBID {
    if !PreemTestAddonSwitch.IsOn() {
      return TDBID.None();
    }
    if Equals(id, n"PreemDev.TestBarrel") {
      return PreemTestAddonSwitch.Item();
    }
    if Equals(id, n"PreemDev.TestBarrelPlus") {
      return PreemTestAddonSwitch.ItemPlus();
    }
    return TDBID.None();
  }

  public func GetUnlockQuality(id: CName) -> gamedataQuality {
    if !PreemTestAddonSwitch.IsOn() {
      return gamedataQuality.Invalid;
    }
    if Equals(id, n"PreemDev.TestBarrel") {
      return gamedataQuality.Rare;
    }
    if Equals(id, n"PreemDev.TestBarrelPlus") {
      return gamedataQuality.Epic;
    }
    return gamedataQuality.Invalid;
  }
}
