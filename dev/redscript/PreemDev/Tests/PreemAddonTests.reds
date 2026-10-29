// Add-on mods (SPEC §9): with the dev test add-on (PreemTestAddon.reds) on, its two barrels are in
// the catalogue like core mods, by ID; with it off, the catalogue is core's own. Each test turns the
// add-on on only for its own checks. Expected values, worked out by hand: the add-on is the only one
// installed, so its IDs sorted give n"PreemDev.TestBarrel" the first add-on style, 10000, and
// n"PreemDev.TestBarrelPlus" 10001; TestBarrel unlocks at Rare (Tier 3) and TestBarrelPlus at Epic
// (Tier 4) on top of core's tiers (PreemUnlockTierTest: Uncommon 9, Rare 18, Epic 32, Legendary 38).
// Compiled only when the mod is installed (registered by PreemModTests() in PreemModTests.reds).
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Addons.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.CraftingSystem.PreemModMaker.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.CraftingSystem.ModInstaller.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.CraftingSystem.PreemModUnlocker.*
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

  private func Barrel() -> PreemModStyleType {
    return PreemAddons.StyleOf(n"PreemDev.TestBarrel");
  }

  private func BarrelPlus() -> PreemModStyleType {
    return PreemAddons.StyleOf(n"PreemDev.TestBarrelPlus");
  }

  private func AddonStylesInBarrelList() -> Int32 {
    let count = 0;
    for mod in PreemModMaker.GetModsFromClassType(PreemModClassType.Barrel) {
      if Equals(mod.modStyleType, this.Barrel()) || Equals(mod.modStyleType, this.BarrelPlus()) {
        count += 1;
      }
    }
    return count;
  }

  private func ReadsBackAs(part: TweakDBID, style: PreemModStyleType) -> Bool {
    let mod = PreemCraftingSystem.GetModForPartRecord(part);
    return IsDefined(mod) && Equals(mod.modStyleType, style);
  }

  private func Mods(styles: array<PreemModStyleType>) -> array<ref<PreemMod>> {
    let mods: array<ref<PreemMod>>;
    for style in styles {
      ArrayPush(mods, PreemModMaker.GetModFromModStyleType(style));
    }
    return mods;
  }

  private cb func Test_IdsGetTheirOwnStyles() {
    this.ExpectInt32("TestBarrel style value", EnumInt(this.Barrel()), 10000);
    this.ExpectInt32("TestBarrelPlus style value", EnumInt(this.BarrelPlus()), 10001);
    this.ExpectCName("style 10000 is TestBarrel", PreemAddons.IdOf(this.Barrel()), n"PreemDev.TestBarrel");
    this.ExpectCName("a core style has no add-on ID", PreemAddons.IdOf(PreemModStyleType.Barrel_Smart), n"None");
  }

  private cb func Test_AddonOnOffersItsBarrels() {
    PreemTestAddonSwitch.SetOn(true);
    let listed = this.AddonStylesInBarrelList();
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectInt32("add-on on: add-on barrels in the Barrel list", listed, 2);
  }

  private cb func Test_AddonOnDefinesAndMaps() {
    PreemTestAddonSwitch.SetOn(true);
    let mod = PreemModMaker.GetModFromModStyleType(this.Barrel());
    let plus = PreemModMaker.GetModFromModStyleType(this.BarrelPlus());
    let mapper = new PreemModMapper();
    let item = ItemID.GetTDBID(mapper.GetGameModFromPreemMod(mod));
    let itemPlus = ItemID.GetTDBID(mapper.GetGameModFromPreemMod(plus));
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: TestBarrel is a Barrel mod", Equals(mod.preemClassType, PreemModClassType.Barrel), true);
    this.ExpectCName("add-on on: TestBarrel name", mod.GetModName(), n"DevAddonBarrel");
    this.ExpectTweakDBID("add-on on: TestBarrel item", item, t"Items.DevAddonBarrel");
    this.ExpectTweakDBID("add-on on: TestBarrelPlus item", itemPlus, t"Items.DevAddonBarrelPlus");
  }

  private cb func Test_AddonOnReadsBack() {
    PreemTestAddonSwitch.SetOn(true);
    let barrel = this.ReadsBackAs(t"Items.DevAddonBarrel", this.Barrel());
    let plus = this.ReadsBackAs(t"Items.DevAddonBarrelPlus", this.BarrelPlus());
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: Items.DevAddonBarrel reads back as TestBarrel", barrel, true);
    this.ExpectBool("add-on on: Items.DevAddonBarrelPlus reads back as TestBarrelPlus", plus, true);
  }

  private cb func Test_AddonOnCompatibility() {
    PreemTestAddonSwitch.SetOn(true);
    let alone = PreemCraftingSystem.AreModsCompatible(this.Mods([this.BarrelPlus()]), gamedataWeaponEvolution.Power);
    let both = PreemCraftingSystem.AreModsCompatible(this.Mods([this.Barrel(), this.BarrelPlus()]), gamedataWeaponEvolution.Power);
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: TestBarrelPlus without TestBarrel", alone, false);
    this.ExpectBool("add-on on: TestBarrelPlus with TestBarrel", both, true);
  }

  private cb func Test_AddonOnInstallPlan() {
    PreemTestAddonSwitch.SetOn(true);
    let plan = PreemCraftingSystem.PlanModSlots(this.Mods([this.Barrel(), this.BarrelPlus()]));
    let installed = PreemCraftingSystem.PlanModSlots(this.Mods([this.Barrel()]));
    let installs: array<ref<PreemModPlacement>>;
    let removals: array<TweakDBID>;
    PreemCraftingSystem.PlanModChanges(installed, installed, installs, removals);
    let record = PreemCraftingSystem.GetCraftRecord(TweakDBInterface.GetItemRecord(t"Items.Preset_Ajax_Default"), [this.Barrel(), this.BarrelPlus()]);
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectInt32("add-on on: both barrels planned", ArraySize(plan), 2);
    if ArraySize(plan) == 2 {
      this.ExpectTweakDBID("add-on on: TestBarrel slot", plan[0].slotID, t"AttachmentSlots.PreemBarrelMod01");
      this.ExpectTweakDBID("add-on on: TestBarrelPlus slot", plan[1].slotID, t"AttachmentSlots.PreemBarrelMod02");
    }
    this.ExpectInt32("add-on on: TestBarrel already in its slot: installs", ArraySize(installs), 0);
    this.ExpectInt32("add-on on: TestBarrel already in its slot: removals", ArraySize(removals), 0);
    this.ExpectTweakDBID("add-on on: Ajax with both barrels is crafted as itself", IsDefined(record) ? record.GetID() : TDBID.None(), t"Items.Preset_Ajax_Default");
    this.ExpectBool("add-on on: TestBarrel allowed on an owned weapon", PreemCraftingSystem.IsModAllowedOnOwnedWeapon(this.Barrel()), true);
  }

  private cb func Test_AddonOffLeavesCoreCatalogue() {
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectInt32("add-on off: add-on barrels in the Barrel list", this.AddonStylesInBarrelList(), 0);
    this.ExpectBool("add-on off: Items.DevAddonBarrel doesn't read back", this.ReadsBackAs(t"Items.DevAddonBarrel", this.Barrel()), false);
    let mod = PreemModMaker.GetModFromModStyleType(this.Barrel());
    this.ExpectTweakDBID("add-on off: TestBarrel falls back to Items.TestMod1", ItemID.GetTDBID(new PreemModMapper().GetGameModFromPreemMod(mod)), t"Items.TestMod1");
  }

  private cb func Test_DevAddonRecordsExist() {
    this.ExpectBool("Items.DevAddonBarrel exists", IsDefined(TweakDBInterface.GetItemRecord(t"Items.DevAddonBarrel")), true);
    this.ExpectBool("Items.DevAddonBarrelPlus exists", IsDefined(TweakDBInterface.GetItemRecord(t"Items.DevAddonBarrelPlus")), true);
  }
}

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

  private func Unlocked(style: PreemModStyleType, mode: PreemWeaponsmithProgressionModUnlockStyle, quality: gamedataQuality) -> Bool {
    let unlocker = new PreemModUnlocker();
    unlocker.SetModes(mode, PreemWeaponsmithProgressionModAmountStyle.Sandbox);
    unlocker.SetWeaponQuality(quality);
    return unlocker.DetermineModUnlocked(style, null);
  }

  private cb func Test_AddonOnTiers() {
    let barrel = PreemAddons.StyleOf(n"PreemDev.TestBarrel");
    let plus = PreemAddons.StyleOf(n"PreemDev.TestBarrelPlus");
    PreemTestAddonSwitch.SetOn(true);
    let inRareTier = this.Has(PreemModUnlocker.GetRareModStyles(), barrel);
    let plusInEpicTier = this.Has(PreemModUnlocker.GetEpicModStyles(), plus);
    let atUncommon = this.Has(PreemModUnlocker.GetUnlockedUncommonPlusModList(), barrel);
    let uncommonSize = this.Size(PreemModUnlocker.GetUnlockedUncommonModList());
    let rareSize = this.Size(PreemModUnlocker.GetUnlockedRareModList());
    let epicSize = this.Size(PreemModUnlocker.GetUnlockedEpicModList());
    let legendarySize = this.Size(PreemModUnlocker.GetUnlockedLegendaryModList());
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: TestBarrel in the Rare tier", inRareTier, true);
    this.ExpectBool("add-on on: TestBarrelPlus in the Epic tier", plusInEpicTier, true);
    this.ExpectBool("add-on on: TestBarrel not unlocked at Uncommon+", atUncommon, false);
    this.ExpectInt32("add-on on: Uncommon unlocks", uncommonSize, 9);
    this.ExpectInt32("add-on on: Rare unlocks", rareSize, 19);
    this.ExpectInt32("add-on on: Epic unlocks", epicSize, 34);
    this.ExpectInt32("add-on on: Legendary unlocks", legendarySize, 40);
  }

  private cb func Test_AddonOnUnlockCheck() {
    let barrel = PreemAddons.StyleOf(n"PreemDev.TestBarrel");
    PreemTestAddonSwitch.SetOn(true);
    let blueprintUncommon = this.Unlocked(barrel, PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints, gamedataQuality.Uncommon);
    let blueprintRare = this.Unlocked(barrel, PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints, gamedataQuality.Rare);
    let blueprintEpic = this.Unlocked(barrel, PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints, gamedataQuality.Epic);
    let sandboxCommon = this.Unlocked(barrel, PreemWeaponsmithProgressionModUnlockStyle.Sandbox, gamedataQuality.Common);
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on on: Blueprints, Uncommon weapon: locked", blueprintUncommon, false);
    this.ExpectBool("add-on on: Blueprints, Rare weapon: unlocked", blueprintRare, true);
    this.ExpectBool("add-on on: Blueprints, Epic weapon: unlocked", blueprintEpic, true);
    this.ExpectBool("add-on on: Sandbox, Common weapon: unlocked", sandboxCommon, true);
  }

  private cb func Test_AddonOnRequirementText() {
    PreemTestAddonSwitch.SetOn(true);
    let text = PreemModUnlocker.GetPreemModUnlockReqDescription(PreemAddons.StyleOf(n"PreemDev.TestBarrel"), PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints);
    let textPlus = PreemModUnlocker.GetPreemModUnlockReqDescription(PreemAddons.StyleOf(n"PreemDev.TestBarrelPlus"), PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints);
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectString("add-on on: TestBarrel requirement text", text, "\nBlUEPRINT QUALITY REQUIRED:\nTier 3");
    this.ExpectString("add-on on: TestBarrelPlus requirement text", textPlus, "\nBlUEPRINT QUALITY REQUIRED:\nTier 4");
  }

  private cb func Test_AddonOffLeavesTiers() {
    PreemTestAddonSwitch.SetOn(false);
    this.ExpectBool("add-on off: TestBarrel not in the Rare tier", this.Has(PreemModUnlocker.GetRareModStyles(), PreemAddons.StyleOf(n"PreemDev.TestBarrel")), false);
    this.ExpectInt32("add-on off: Rare unlocks", this.Size(PreemModUnlocker.GetUnlockedRareModList()), 18);
    this.ExpectInt32("add-on off: Legendary unlocks", this.Size(PreemModUnlocker.GetUnlockedLegendaryModList()), 38);
  }
}
