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
import PreemCrafting.CraftingSystem.PreemModUnlocker.*

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

// Unlock tiers with the dev add-on on: its barrel unlocks at Rare under Weapon Blueprints (Tier 3 in
// the requirement text, as core's Rare mods) and always in Sandbox. With it off, core's own tiers
// are PreemUnlockTierTest's (Uncommon 9, Rare 18); on, Rare and up have one more.
@if(ModuleExists("PreemCrafting.Addons"))
public class PreemAddonUnlockTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "AddonUnlocks";
  }

  private func Has(list: array<PreemModStyleType>, style: PreemModStyleType) -> Bool {
    return ArrayContains(list, style);
  }

  private func Size(list: array<PreemModStyleType>) -> Int32 {
    return ArraySize(list);
  }

  private func Unlocked(mode: PreemWeaponsmithProgressionModUnlockStyle, quality: gamedataQuality) -> Bool {
    let unlocker = new PreemModUnlocker();
    unlocker.SetModes(mode, PreemWeaponsmithProgressionModAmountStyle.Sandbox);
    unlocker.SetWeaponQuality(quality);
    return unlocker.DetermineModUnlocked(PreemModStyleType.Barrel_Hacker, null);
  }

  private cb func Test_AddonOnUnlocksAtRare() {
    PreemTestAddonSwitch.SetOn(true);
    let inRareTier = this.Has(PreemModUnlocker.GetRareModStyles(), PreemModStyleType.Barrel_Hacker);
    let atUncommon = this.Has(PreemModUnlocker.GetUnlockedUncommonPlusModList(), PreemModStyleType.Barrel_Hacker);
    let rareSize = this.Size(PreemModUnlocker.GetUnlockedRareModList());
    let legendarySize = this.Size(PreemModUnlocker.GetUnlockedLegendaryModList());
    let uncommonSize = this.Size(PreemModUnlocker.GetUnlockedUncommonModList());
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: Barrel_Hacker in the Rare tier", inRareTier, true);
    this.ExpectBool("add-on on: Barrel_Hacker not unlocked at Uncommon+", atUncommon, false);
    this.ExpectInt32("add-on on: Uncommon unlocks", uncommonSize, 9);
    this.ExpectInt32("add-on on: Rare unlocks", rareSize, 19);
    this.ExpectInt32("add-on on: Legendary unlocks", legendarySize, 39);
  }

  private cb func Test_AddonOnUnlockCheck() {
    PreemTestAddonSwitch.SetOn(true);
    let blueprintUncommon = this.Unlocked(PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints, gamedataQuality.Uncommon);
    let blueprintRare = this.Unlocked(PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints, gamedataQuality.Rare);
    let blueprintEpic = this.Unlocked(PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints, gamedataQuality.Epic);
    let sandboxCommon = this.Unlocked(PreemWeaponsmithProgressionModUnlockStyle.Sandbox, gamedataQuality.Common);
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: Blueprints, Uncommon weapon: locked", blueprintUncommon, false);
    this.ExpectBool("add-on on: Blueprints, Rare weapon: unlocked", blueprintRare, true);
    this.ExpectBool("add-on on: Blueprints, Epic weapon: unlocked", blueprintEpic, true);
    this.ExpectBool("add-on on: Sandbox, Common weapon: unlocked", sandboxCommon, true);
  }

  private cb func Test_AddonOnRequirementText() {
    PreemTestAddonSwitch.SetOn(true);
    let text = PreemModUnlocker.GetPreemModUnlockReqDescription(PreemModStyleType.Barrel_Hacker, PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints);
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectString("add-on on: requirement text", text, "\nBlUEPRINT QUALITY REQUIRED:\nTier 3");
  }

  private cb func Test_AddonOffLeavesTiers() {
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on off: Barrel_Hacker not in the Rare tier", this.Has(PreemModUnlocker.GetRareModStyles(), PreemModStyleType.Barrel_Hacker), false);
    this.ExpectInt32("add-on off: Rare unlocks", this.Size(PreemModUnlocker.GetUnlockedRareModList()), 18);
    this.ExpectInt32("add-on off: Legendary unlocks", this.Size(PreemModUnlocker.GetUnlockedLegendaryModList()), 38);
  }
}
