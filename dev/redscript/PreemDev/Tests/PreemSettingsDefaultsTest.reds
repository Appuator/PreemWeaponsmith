// Built-in settings defaults when Mod Settings is not installed (it is optional: decisions log
// 2026-10-25). Compiled only without Mod Settings (module ModSettingsModule) and with the mod;
// with Mod Settings the values come from its saved settings instead. Run a boot without it:
//   pwsh tools/boot-check.ps1 -Without 'Mod Settings'
// Expected values from SPEC §5 "Built-in defaults": unlock = Weapon Blueprints, limit = Sandbox
// (6 mods on any weapon, as in 2.2.5), layout = on the weapon.
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem") && !ModuleExists("ModSettingsModule"))
import PreemCrafting.CraftingSystem.PreemModUnlocker.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem") && !ModuleExists("ModSettingsModule"))
import PreemCrafting.Core.*

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem") && !ModuleExists("ModSettingsModule"))
public func PreemSettingsTests() -> array<ref<BaseTest>> {
  let tests: array<ref<BaseTest>>;
  ArrayPush(tests, new PreemSettingsDefaultsTest());
  return tests;
}

@if(!ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem") || ModuleExists("ModSettingsModule"))
public func PreemSettingsTests() -> array<ref<BaseTest>> {
  let tests: array<ref<BaseTest>>;
  return tests;
}

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem") && !ModuleExists("ModSettingsModule"))
public class PreemSettingsDefaultsTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "SettingsDefaults";
  }

  private cb func Test_Defaults() {
    let settings = new PreemModSettings();
    this.ExpectBool("unlock mode is Weapon Blueprints", Equals(settings.ModUnlockMode, PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints), true);
    this.ExpectBool("limit mode is Sandbox", Equals(settings.ModAmountMode, PreemWeaponsmithProgressionModAmountStyle.Sandbox), true);
    this.ExpectBool("slot layout is on the weapon", Equals(settings.ModSlotPosition, PreemWeaponsmithModSlotPosition.OnWeapon), true);
  }

  // The defaults in effect: Sandbox limit allows 6 mods even on a Common weapon, and Blueprints
  // unlocks nothing on a Common weapon (the Common tier is empty) but the Smart barrel at Epic.
  private cb func Test_DefaultsApply() {
    let unlocker = new PreemModUnlocker();
    unlocker.SetWeaponQuality(gamedataQuality.Common);
    this.ExpectInt32("mods allowed on a Common weapon", unlocker.DetermineAmountOfModsAllowed(null), 6);
    this.ExpectBool("Smart barrel unlocked on a Common weapon", unlocker.DetermineModUnlocked(PreemModStyleType.Barrel_Smart, null), false);
    unlocker.SetWeaponQuality(gamedataQuality.Epic);
    this.ExpectBool("Smart barrel unlocked on an Epic weapon", unlocker.DetermineModUnlocked(PreemModStyleType.Barrel_Smart, null), true);
  }
}
