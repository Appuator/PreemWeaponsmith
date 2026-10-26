// Rule tests: slot rules, mod compatibility, unlock tiers. Compiled only when the mod is installed
// (registered by PreemModTests() in PreemModTests.reds). Expected values are the 2.2.5 behaviour,
// worked out by hand from the mod table as 2.2.5 shipped it (tag v2.2.5).
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.Core.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.PreemModMaker.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.ModSlotManager.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.PreemModUnlocker.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.PreemUI.*

// PreemModSlotManager.CanInstallPreemModInSlot: slot class, and required mods met by mods already
// slotted. Barrel_SmartMultiTarget requires Barrel_Smart; Barrel_Tech requires Trigger_Charge.
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public class PreemSlotRuleTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "SlotRules";
  }

  private func Slot(classType: PreemModClassType) -> ref<PreemSlot> {
    let slot = new PreemSlot();
    slot.preemClassType = classType;
    return slot;
  }

  // A slot manager whose slots already hold these mods (UI slots without widgets).
  private func ManagerWith(styles: array<PreemModStyleType>) -> ref<PreemModSlotManager> {
    let manager = new PreemModSlotManager();
    for style in styles {
      let mod = PreemModMaker.GetModFromModStyleType(style);
      let data = this.Slot(mod.preemClassType);
      data.SetSlottedMod(mod);
      let uiSlot = new PreemModSlot();
      uiSlot.SetSlotData(data);
      manager.AddModSlot(uiSlot);
    }
    return manager;
  }

  private func CanInstall(style: PreemModStyleType, slotClass: PreemModClassType, slotted: array<PreemModStyleType>) -> Bool {
    return this.ManagerWith(slotted).CanInstallPreemModInSlot(PreemModMaker.GetModFromModStyleType(style), this.Slot(slotClass));
  }

  private cb func Test_SlotClass() {
    let none: array<PreemModStyleType>;
    this.ExpectBool("Recoil barrel in a barrel slot", this.CanInstall(PreemModStyleType.Barrel_Recoil, PreemModClassType.Barrel, none), true);
    this.ExpectBool("Recoil barrel in a trigger slot", this.CanInstall(PreemModStyleType.Barrel_Recoil, PreemModClassType.Trigger, none), false);
    this.ExpectBool("Full-auto trigger in a trigger slot", this.CanInstall(PreemModStyleType.Trigger_FullAuto, PreemModClassType.Trigger, none), true);
    this.ExpectBool("Chem blade in a handle slot", this.CanInstall(PreemModStyleType.Blade_Chem, PreemModClassType.Handle, none), false);
    this.ExpectBool("Rubberized grip in a handle slot", this.CanInstall(PreemModStyleType.Handle_RubberizedGrip, PreemModClassType.Handle, none), true);
  }

  private cb func Test_RequiredMods() {
    let none: array<PreemModStyleType>;
    let smart: array<PreemModStyleType> = [PreemModStyleType.Barrel_Smart];
    let charge: array<PreemModStyleType> = [PreemModStyleType.Trigger_Charge];
    this.ExpectBool("Multi-target barrel without a Smart barrel", this.CanInstall(PreemModStyleType.Barrel_SmartMultiTarget, PreemModClassType.Barrel, none), false);
    this.ExpectBool("Multi-target barrel with a Smart barrel slotted", this.CanInstall(PreemModStyleType.Barrel_SmartMultiTarget, PreemModClassType.Barrel, smart), true);
    this.ExpectBool("Tech barrel without a Charge trigger", this.CanInstall(PreemModStyleType.Barrel_Tech, PreemModClassType.Barrel, none), false);
    this.ExpectBool("Tech barrel with a Charge trigger slotted", this.CanInstall(PreemModStyleType.Barrel_Tech, PreemModClassType.Barrel, charge), true);
  }

  private cb func Test_MissingInput() {
    let manager = new PreemModSlotManager();
    this.ExpectBool("no mod", manager.CanInstallPreemModInSlot(null, this.Slot(PreemModClassType.Barrel)), false);
    this.ExpectBool("no slot", manager.CanInstallPreemModInSlot(PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Recoil), null), false);
  }
}

// PreemCraftingSystem.AreModsCompatible: required mods (or the weapon's own evolution meeting a
// mod's required evolution) and incompatible styles, for the whole chosen set.
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public class PreemCompatibilityTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "Compatibility";
  }

  private func Compatible(styles: array<PreemModStyleType>, evolution: gamedataWeaponEvolution) -> Bool {
    let mods: array<ref<PreemMod>>;
    for style in styles {
      ArrayPush(mods, PreemModMaker.GetModFromModStyleType(style));
    }
    return PreemCraftingSystem.AreModsCompatible(mods, evolution);
  }

  private cb func Test_IncompatibleTriggers() {
    this.ExpectBool("Full-auto + Semi-auto", this.Compatible([PreemModStyleType.Trigger_FullAuto, PreemModStyleType.Trigger_SemiAuto], gamedataWeaponEvolution.Invalid), false);
    this.ExpectBool("Burst + Charge + Tech barrel", this.Compatible([PreemModStyleType.Trigger_Burst, PreemModStyleType.Trigger_Charge, PreemModStyleType.Barrel_Tech], gamedataWeaponEvolution.Invalid), false);
    this.ExpectBool("Full-auto alone", this.Compatible([PreemModStyleType.Trigger_FullAuto], gamedataWeaponEvolution.Invalid), true);
    this.ExpectBool("Insta-burst + Burst", this.Compatible([PreemModStyleType.Trigger_InstaBurst, PreemModStyleType.Trigger_Burst], gamedataWeaponEvolution.Invalid), true);
  }

  private cb func Test_RequiredEvolution() {
    this.ExpectBool("Multi-target, no Smart barrel, Power weapon", this.Compatible([PreemModStyleType.Barrel_SmartMultiTarget], gamedataWeaponEvolution.Power), false);
    this.ExpectBool("Multi-target on a Smart weapon", this.Compatible([PreemModStyleType.Barrel_SmartMultiTarget], gamedataWeaponEvolution.Smart), true);
    this.ExpectBool("Multi-target + Smart barrel on a Power weapon", this.Compatible([PreemModStyleType.Barrel_SmartMultiTarget, PreemModStyleType.Barrel_Smart], gamedataWeaponEvolution.Power), true);
    this.ExpectBool("Velocity booster, evolution unknown", this.Compatible([PreemModStyleType.Barrel_VelocityBooster], gamedataWeaponEvolution.Invalid), false);
  }

  // The Charge trigger requires a Tech barrel, and the Tech barrel requires a Charge trigger.
  private cb func Test_MutualRequirement() {
    this.ExpectBool("Charge trigger alone", this.Compatible([PreemModStyleType.Trigger_Charge], gamedataWeaponEvolution.Invalid), false);
    this.ExpectBool("Charge trigger + Tech barrel", this.Compatible([PreemModStyleType.Trigger_Charge, PreemModStyleType.Barrel_Tech], gamedataWeaponEvolution.Invalid), true);
  }
}

// PreemModUnlocker tier lists (Weapon Blueprints mode): each rarity unlocks its own mods plus every
// lower tier's. As 2.2.5 shipped them: Common and Common+ none; Uncommon 9 (Barrel_Recoil,
// Barrel_RecoilY, Barrel_Silencer, Trigger_Burst/FullAuto/SemiAuto, Handle_RubberizedGrip,
// Mag_QuickMag, Blade_DeflectorBlade); Rare +9 (elemental and bleed rounds and blades,
// Mag_Extended) = 18; Epic +14 (evolution barrels and their upgrades, Charge triggers, crit blades,
// Handle_Dash) = 32; Legendary +6 (Barrel_Turbo, Barrel_ExtraBarrel, Insta-burst, Ultra-action,
// Handle_Leap, Handle_StaminaReduction) = 38, every offered mod. The "+" tiers add nothing.
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public class PreemUnlockTierTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "UnlockTiers";
  }

  // ArraySize/ArrayContains take the array by reference, which a function result can't be.
  private func Size(list: array<PreemModStyleType>) -> Int32 {
    return ArraySize(list);
  }

  private func Has(list: array<PreemModStyleType>, style: PreemModStyleType) -> Bool {
    return ArrayContains(list, style);
  }

  private cb func Test_TierSizes() {
    this.ExpectInt32("Common", this.Size(PreemModUnlocker.GetUnlockedCommonModList()), 0);
    this.ExpectInt32("Common+", this.Size(PreemModUnlocker.GetUnlockedCommonPlusModList()), 0);
    this.ExpectInt32("Uncommon", this.Size(PreemModUnlocker.GetUnlockedUncommonModList()), 9);
    this.ExpectInt32("Uncommon+", this.Size(PreemModUnlocker.GetUnlockedUncommonPlusModList()), 9);
    this.ExpectInt32("Rare", this.Size(PreemModUnlocker.GetUnlockedRareModList()), 18);
    this.ExpectInt32("Rare+", this.Size(PreemModUnlocker.GetUnlockedRarePlusModList()), 18);
    this.ExpectInt32("Epic", this.Size(PreemModUnlocker.GetUnlockedEpicModList()), 32);
    this.ExpectInt32("Epic+", this.Size(PreemModUnlocker.GetUnlockedEpicPlusModList()), 32);
    this.ExpectInt32("Legendary", this.Size(PreemModUnlocker.GetUnlockedLegendaryModList()), 38);
    this.ExpectInt32("Legendary+", this.Size(PreemModUnlocker.GetUnlockedLegendaryPlusModList()), 38);
    this.ExpectInt32("Legendary++", this.Size(PreemModUnlocker.GetUnlockedLegendaryPlusPlusModList()), 38);
  }

  private cb func Test_TierMembership() {
    this.ExpectBool("Silencer at Uncommon", this.Has(PreemModUnlocker.GetUnlockedUncommonModList(), PreemModStyleType.Barrel_Silencer), true);
    this.ExpectBool("Thermal rounds not at Uncommon", this.Has(PreemModUnlocker.GetUnlockedUncommonModList(), PreemModStyleType.Mag_Thermal), false);
    this.ExpectBool("Thermal rounds at Rare", this.Has(PreemModUnlocker.GetUnlockedRareModList(), PreemModStyleType.Mag_Thermal), true);
    this.ExpectBool("Smart barrel not at Rare", this.Has(PreemModUnlocker.GetUnlockedRareModList(), PreemModStyleType.Barrel_Smart), false);
    this.ExpectBool("Smart barrel at Epic", this.Has(PreemModUnlocker.GetUnlockedEpicModList(), PreemModStyleType.Barrel_Smart), true);
    this.ExpectBool("Full-auto still at Epic", this.Has(PreemModUnlocker.GetUnlockedEpicModList(), PreemModStyleType.Trigger_FullAuto), true);
    this.ExpectBool("Extra barrel not at Epic", this.Has(PreemModUnlocker.GetUnlockedEpicModList(), PreemModStyleType.Barrel_ExtraBarrel), false);
    this.ExpectBool("Extra barrel at Legendary", this.Has(PreemModUnlocker.GetUnlockedLegendaryModList(), PreemModStyleType.Barrel_ExtraBarrel), true);
  }

  // Every mod the crafting UI offers can be unlocked at Legendary.
  private cb func Test_LegendaryUnlocksEveryOfferedMod() {
    let classes: array<PreemModClassType> = [PreemModClassType.Barrel, PreemModClassType.Trigger, PreemModClassType.Mag, PreemModClassType.Blade, PreemModClassType.Handle];
    let legendary = PreemModUnlocker.GetUnlockedLegendaryModList();
    let missing = 0;
    for classType in classes {
      for mod in PreemModMaker.GetModsFromClassType(classType) {
        if !ArrayContains(legendary, mod.modStyleType) {
          missing += 1;
        }
      }
    }
    this.ExpectInt32("offered mods not unlockable at Legendary", missing, 0);
  }
}
