// Add-on hook points (SPEC §9): with the dev test add-on (PreemTestAddon.reds) on, its barrel is
// in the catalogue like a core mod; with it off, the catalogue is core's own. Each test turns the
// add-on on only for its own checks. Expected values are the test add-on's own (Barrel_Hacker on
// Items.DevAddonBarrel) and core's 2.5 Barrel list, which doesn't offer Barrel_Hacker.
// Compiled only when the mod is installed (registered by PreemModTests() in PreemModTests.reds).
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.CraftingSystem.PreemModMaker.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.CraftingSystem.ModInstaller.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Core.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemDev.Addon.*

@if(ModuleExists("PreemCrafting.Addons"))
public class PreemAddonCatalogueTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "AddonCatalogue";
  }

  private func BarrelListHasHacker() -> Bool {
    for mod in PreemModMaker.GetModsFromClassType(PreemModClassType.Barrel) {
      if Equals(mod.modStyleType, PreemModStyleType.Barrel_Hacker) {
        return true;
      }
    }
    return false;
  }

  private func PartReadsBackAsHacker() -> Bool {
    let mod = PreemCraftingSystem.GetModForPartRecord(PreemTestAddonSwitch.Item());
    return IsDefined(mod) && Equals(mod.modStyleType, PreemModStyleType.Barrel_Hacker);
  }

  private cb func Test_AddonOnOffersItsBarrel() {
    PreemTestAddonSwitch.SetOn(true);
    let listed = this.BarrelListHasHacker();
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: Barrel list has Barrel_Hacker", listed, true);
  }

  private cb func Test_AddonOnDefinesItsBarrel() {
    PreemTestAddonSwitch.SetOn(true);
    let mod = PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Hacker);
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: Barrel_Hacker is a Barrel mod", Equals(mod.preemClassType, PreemModClassType.Barrel), true);
    this.ExpectCName("add-on on: Barrel_Hacker name", mod.GetModName(), n"DevAddonBarrel");
  }

  private cb func Test_AddonOnMapsItsItem() {
    PreemTestAddonSwitch.SetOn(true);
    let mod = PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Hacker);
    let item = ItemID.GetTDBID(new PreemModMapper().GetGameModFromPreemMod(mod));
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectTweakDBID("add-on on: Barrel_Hacker item", item, t"Items.DevAddonBarrel");
  }

  private cb func Test_AddonOnReadsBackItsPart() {
    PreemTestAddonSwitch.SetOn(true);
    let readBack = this.PartReadsBackAsHacker();
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: Items.DevAddonBarrel part reads back as Barrel_Hacker", readBack, true);
  }

  private cb func Test_AddonOffLeavesCoreCatalogue() {
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on off: Barrel list has no Barrel_Hacker", this.BarrelListHasHacker(), false);
    this.ExpectBool("add-on off: Items.DevAddonBarrel part doesn't read back", this.PartReadsBackAsHacker(), false);
    let mod = PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Hacker);
    this.ExpectTweakDBID("add-on off: Barrel_Hacker falls back to Items.TestMod1", ItemID.GetTDBID(new PreemModMapper().GetGameModFromPreemMod(mod)), t"Items.TestMod1");
  }

  private cb func Test_DevAddonRecordExists() {
    this.ExpectBool("Items.DevAddonBarrel record exists", IsDefined(TweakDBInterface.GetItemRecord(t"Items.DevAddonBarrel")), true);
  }
}
