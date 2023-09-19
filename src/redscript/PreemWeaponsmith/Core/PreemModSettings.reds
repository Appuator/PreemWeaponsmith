enum PreemWeaponsmithProgressionModUnlockStyle {
  Sandbox = 0,
  CraftingPerks = 1,
  WeaponBlueprints = 2
}

enum PreemWeaponsmithProgressionModAmountStyle {
  Sandbox = 0,
  CraftingLevel = 1
}

enum PreemWeaponsmithModUnlockPerks {
  TrueCraftsman = 0,
  GreaseMonkey = 1,
  EdgerunnerArtisan = 2
}

enum PreemWeaponsmithModSlotPosition {
  OnWeapon = 0,
  BelowWeapon = 1
}

public class PreemModSettings extends IScriptable {
  
  public static func GetInstance() -> ref<PreemModSettings> {
    let self: ref<PreemModSettings> = new PreemModSettings();
    return self;
  }

  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Mod Unlock System")
  @runtimeProperty("ModSettings.category", "Progression System")
  @runtimeProperty("ModSettings.description", "System for unlocking which mods the player can add to a weapon")
  @runtimeProperty("ModSettings.displayValues", "\"Sandbox\",\"Crafting Perks\",\"Weapon Blueprints\"")
  let ModUnlockMode: PreemWeaponsmithProgressionModUnlockStyle = PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints;

  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Mod Limit System")
  @runtimeProperty("ModSettings.category", "Progression System")
  @runtimeProperty("ModSettings.description", "System for limiting the amount of mods you can add to a weapon")
  @runtimeProperty("ModSettings.displayValues", "\"Sandbox\",\"Crafting Level\"")
  let ModAmountMode: PreemWeaponsmithProgressionModAmountStyle = PreemWeaponsmithProgressionModAmountStyle.Sandbox;

  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Tier 1 Mods")
  @runtimeProperty("ModSettings.category", "Mod Unlock: Crafting Perks")
  @runtimeProperty("ModSettings.description", "Perk that will unlock Tier 1 Mods")
  @runtimeProperty("ModSettings.displayValues", "\"True Craftsman\",\"Grease Monkey\", \"Edgerunner Artisan\"")
  let ModUnlockPerk1: PreemWeaponsmithModUnlockPerks = PreemWeaponsmithModUnlockPerks.TrueCraftsman;

  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Tier 2 Mods")
  @runtimeProperty("ModSettings.category", "Mod Unlock: Crafting Perks")
  @runtimeProperty("ModSettings.description", "Perk that will unlock Tier 2 Mods")
  @runtimeProperty("ModSettings.displayValues", "\"True Craftsman\",\"Grease Monkey\", \"Edgerunner Artisan\"")
  let ModUnlockPerk2: PreemWeaponsmithModUnlockPerks = PreemWeaponsmithModUnlockPerks.GreaseMonkey;

  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Tier 3 Mods")
  @runtimeProperty("ModSettings.category", "Mod Unlock: Crafting Perks")
  @runtimeProperty("ModSettings.description", "Perk that will unlock Tier 3 Mods")
  @runtimeProperty("ModSettings.displayValues", "\"True Craftsman\",\"Grease Monkey\", \"Edgerunner Artisan\"")
  let ModUnlockPerk3: PreemWeaponsmithModUnlockPerks = PreemWeaponsmithModUnlockPerks.EdgerunnerArtisan;


  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Limit Increase Per Crafting Level")
  @runtimeProperty("ModSettings.category", "Mod Limit: Crafting Level")
  @runtimeProperty("ModSettings.description", "Increases mods by 1 every x Crafting level")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "4")
  let IncreaseAmountLevel: Int32 = 4;

  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Preem Mod Slot Layout")
  @runtimeProperty("ModSettings.category", "Crafting Interface")
  @runtimeProperty("ModSettings.description", "Sets position of mod slots on the crafting screen")
  @runtimeProperty("ModSettings.displayValues", "\"On Weapon\",\"Below Weapon\"")
  let ModSlotPosition: PreemWeaponsmithModSlotPosition = PreemWeaponsmithModSlotPosition.OnWeapon;
}