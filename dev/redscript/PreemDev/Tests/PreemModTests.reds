// Tests that call into the mod itself. Compiled only when the mod is installed; with only the dev
// code installed, PreemModTests() returns no tests.
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.Core.*

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public func PreemModTests() -> array<ref<BaseTest>> {
  let tests: array<ref<BaseTest>>;
  ArrayPush(tests, new PreemCraftRecordTest());
  ArrayPush(tests, new PreemSlotRuleTest());
  ArrayPush(tests, new PreemCompatibilityTest());
  ArrayPush(tests, new PreemUnlockTierTest());
  return tests;
}

@if(!ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public func PreemModTests() -> array<ref<BaseTest>> {
  let tests: array<ref<BaseTest>>;
  return tests;
}

// PreemCraftingSystem.GetCraftRecord: which record CraftItem crafts for a set of chosen mods.
// Expected records are the 2.2.5 behaviour: an evolution barrel swaps to <weapon>_Preem<Evolution>
// unless the weapon already has that evolution; with no such variant the weapon itself is crafted.
// Fixtures: Items.Preset_Ajax_Default is a Power rifle with _PreemSmart/_PreemTech variants;
// Items.Preset_Katana_Default is melee and has no variants.
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public class PreemCraftRecordTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "CraftRecord";
  }

  private func Craft(weapon: TweakDBID, mod: PreemModStyleType) -> TweakDBID {
    let mods: array<PreemModStyleType>;
    ArrayPush(mods, mod);
    let record = PreemCraftingSystem.GetCraftRecord(TweakDBInterface.GetItemRecord(weapon), mods);
    return IsDefined(record) ? record.GetID() : TDBID.None();
  }

  private cb func Test_SmartBarrelOnPowerRifleCraftsSmartVariant() {
    this.ExpectTweakDBID("Ajax + Smart barrel", this.Craft(t"Items.Preset_Ajax_Default", PreemModStyleType.Barrel_Smart), t"Items.Preset_Ajax_Default_PreemSmart");
  }

  private cb func Test_TechBarrelOnPowerRifleCraftsTechVariant() {
    this.ExpectTweakDBID("Ajax + Tech barrel", this.Craft(t"Items.Preset_Ajax_Default", PreemModStyleType.Barrel_Tech), t"Items.Preset_Ajax_Default_PreemTech");
  }

  private cb func Test_OwnEvolutionBarrelKeepsWeapon() {
    this.ExpectTweakDBID("Ajax + Power barrel", this.Craft(t"Items.Preset_Ajax_Default", PreemModStyleType.Barrel_Power), t"Items.Preset_Ajax_Default");
  }

  private cb func Test_OtherBarrelKeepsWeapon() {
    this.ExpectTweakDBID("Ajax + Silencer", this.Craft(t"Items.Preset_Ajax_Default", PreemModStyleType.Barrel_Silencer), t"Items.Preset_Ajax_Default");
  }

  private cb func Test_NoVariantKeepsWeapon() {
    this.ExpectTweakDBID("Katana + Smart barrel", this.Craft(t"Items.Preset_Katana_Default", PreemModStyleType.Barrel_Smart), t"Items.Preset_Katana_Default");
  }
}
