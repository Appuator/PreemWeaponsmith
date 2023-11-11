enum PreemWeaponsmithProgressionModUnlockStyle {
  Sandbox = 0,
  WeaponBlueprints = 1
}

enum PreemWeaponsmithProgressionModAmountStyle {
  Sandbox = 0,
  WeaponBlueprints = 1
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
  @runtimeProperty("ModSettings.displayValues", "\"Sandbox\",\"Weapon Blueprints\"")
  let ModUnlockMode: PreemWeaponsmithProgressionModUnlockStyle = PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints;

  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Mod Limit System")
  @runtimeProperty("ModSettings.category", "Progression System")
  @runtimeProperty("ModSettings.description", "System for limiting the amount of mods you can add to a weapon")
  @runtimeProperty("ModSettings.displayValues", "\"Sandbox\",\"Weapon Blueprints\"")
  let ModAmountMode: PreemWeaponsmithProgressionModAmountStyle = PreemWeaponsmithProgressionModAmountStyle.Sandbox;

  @runtimeProperty("ModSettings.mod", "Preem Weaponsmith")
  @runtimeProperty("ModSettings.displayName", "Preem Mod Slot Layout")
  @runtimeProperty("ModSettings.category", "Crafting Interface")
  @runtimeProperty("ModSettings.description", "Sets position of mod slots on the crafting screen")
  @runtimeProperty("ModSettings.displayValues", "\"On Weapon\",\"Below Weapon\"")
  let ModSlotPosition: PreemWeaponsmithModSlotPosition = PreemWeaponsmithModSlotPosition.OnWeapon;
}