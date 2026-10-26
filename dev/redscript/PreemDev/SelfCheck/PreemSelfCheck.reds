// Dev only, never shipped. Checks that every TweakDB record the mod creates or changes exists and
// is wired up: the Preem attachment slots, the blueprint elements that put them on weapons, every
// mod item the crafting UI offers (its placement slots and stat modifiers resolve), and for every ranged weapon its evolution variants (<weapon>_Preem<Evolution>) and
// for every crafted weapon its Preem blueprint elements.
// One "[PreemCheck] PASS|FAIL <check>[: reason]" line per check, then a "done" summary, all via
// FTLog (CET gamelog.log). tools/boot-check.ps1 reads them (tools/SelfCheckLog.psm1).
// Runs from PreemDevSystem.OnAttach: by then TweakXL has run the mod's ScriptableTweaks.
// Compiled only when the mod itself is installed; otherwise PreemRunSelfCheck does nothing.
module PreemDev.SelfCheck

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemModMaker"))
import PreemCrafting.Core.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemModMaker"))
import PreemCrafting.CraftingSystem.PreemModMaker.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemModMaker"))
import PreemCrafting.CraftingSystem.ModInstaller.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemModMaker"))
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemModMaker"))
public func PreemRunSelfCheck() -> Void {
  PreemSelfCheck.Run();
}

@if(!ModuleExists("PreemCrafting.CraftingSystem.PreemModMaker"))
public func PreemRunSelfCheck() -> Void {}

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemModMaker"))
public class PreemSelfCheck {
  private let m_passed: Int32;
  private let m_failed: Int32;

  public static func Run() -> Void {
    let check = new PreemSelfCheck();
    check.CheckSlots();
    check.CheckBlueprintElements();
    check.CheckMods();
    check.CheckWeapons();
    FTLog(s"[PreemCheck] done: \(check.m_passed) passed, \(check.m_failed) failed");
  }

  // An empty problem means the check passed.
  private func Report(check: String, problem: String) -> Void {
    if StrLen(problem) == 0 {
      this.m_passed += 1;
      FTLog("[PreemCheck] PASS " + check);
    } else {
      this.m_failed += 1;
      FTLog("[PreemCheck] FAIL " + check + ": " + problem);
    }
  }

  // Each slot exists, and its entitySlotName is its own name (as every pair is set up).
  private func CheckSlots() -> Void {
    let names: array<String> = [
      "PreemBarrelMod01", "PreemBarrelMod02", "PreemTriggerMod01", "PreemTriggerMod02",
      "PreemMagazineMod01", "PreemMagazineMod02", "PreemBladeMod01", "PreemBladeMod02",
      "PreemHandleMod01", "PreemHandleMod02"
    ];
    for name in names {
      let slot = TweakDBInterface.GetAttachmentSlotRecord(TDBID.Create("AttachmentSlots." + name));
      let problem = "";
      if !IsDefined(slot) {
        problem = "missing";
      } else {
        if NotEquals(slot.EntitySlotName(), name) {
          problem = "entitySlotName is " + slot.EntitySlotName();
        }
      }
      this.Report("slot AttachmentSlots." + name, problem);
    }
  }

  // Each blueprint element exists and points at its slot.
  private func CheckBlueprintElements() -> Void {
    let elements: array<String> = [
      "PreemBarrelSlot01Element", "PreemBarrelSlot02Element", "PreemBarrelSlot03Element",
      "PreemTriggerSlot01Element", "PreemTriggerSlot02Element",
      "PreemMagazineSlot01Element", "PreemMagazineSlot02Element",
      "PreemBladeSlot01Element", "PreemBladeSlot02Element",
      "PreemHandleSlot01Element", "PreemHandleSlot02Element"
    ];
    let slots: array<String> = [
      "PreemBarrelMod01", "PreemBarrelMod02", "PowerModule",
      "PreemTriggerMod01", "PreemTriggerMod02",
      "PreemMagazineMod01", "PreemMagazineMod02",
      "PreemBladeMod01", "PreemBladeMod02",
      "PreemHandleMod01", "PreemHandleMod02"
    ];
    let i = 0;
    while i < ArraySize(elements) {
      let element = TweakDBInterface.GetRecord(TDBID.Create("Items." + elements[i])) as ItemBlueprintElement_Record;
      let problem = "";
      if !IsDefined(element) {
        problem = "missing";
      } else {
        if !IsDefined(element.Slot()) {
          problem = "slot does not resolve";
        } else {
          if element.Slot().GetID() != TDBID.Create("AttachmentSlots." + slots[i]) {
            problem = "slot is " + TDBID.ToStringDEBUG(element.Slot().GetID()) + ", expected AttachmentSlots." + slots[i];
          }
        }
      }
      this.Report("element Items." + elements[i], problem);
      i += 1;
    }
  }

  // Every mod the crafting UI offers maps to an item record whose type, placement slots and
  // stat modifiers (with their stat types) all resolve.
  private func CheckMods() -> Void {
    let classes: array<PreemModClassType> = [
      PreemModClassType.Barrel, PreemModClassType.Trigger, PreemModClassType.Mag,
      PreemModClassType.Blade, PreemModClassType.Handle
    ];
    let mapper = new PreemModMapper();
    for classType in classes {
      for mod in PreemModMaker.GetModsFromClassType(classType) {
        let id = ItemID.GetTDBID(mapper.GetGameModFromPreemMod(mod));
        let check = "mod " + NameToString(mod.GetModName()) + " (" + TDBID.ToStringDEBUG(id) + ")";
        // redscript has no `continue`.
        if id == t"Items.TestMod1" {
          this.Report(check, "no item mapped (falls back to Items.TestMod1)");
        } else {
          this.Report(check, this.ModProblem(id));
        }
      }
    }
  }

  private func ModProblem(id: TweakDBID) -> String {
    let item = TweakDBInterface.GetItemRecord(id);
    if !IsDefined(item) {
      return "missing";
    }
    if !IsDefined(item.ItemType()) {
      return "item type does not resolve";
    }
    let slots: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(id + t".placementSlots"));
    if ArraySize(slots) == 0 {
      return "no placement slots";
    }
    for slot in slots {
      if !IsDefined(TweakDBInterface.GetAttachmentSlotRecord(slot)) {
        return "placement slot " + TDBID.ToStringDEBUG(slot) + " does not resolve";
      }
    }
    let modifiers: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(id + t".statModifiers"));
    for modifierID in modifiers {
      let modifier = TweakDBInterface.GetRecord(modifierID) as StatModifier_Record;
      if !IsDefined(modifier) {
        return "stat modifier " + TDBID.ToStringDEBUG(modifierID) + " does not resolve";
      }
      if !IsDefined(modifier.StatType()) {
        return "stat modifier " + TDBID.ToStringDEBUG(modifierID) + " has no stat type";
      }
    }
    return "";
  }

  // Ranged weapons: each base weapon has a variant for each other evolution (Smart, Tech, Power)
  // with that evolution, and its blueprint root holds the ranged Preem elements. Melee weapons:
  // the melee elements. Weapons without a blueprint can't be crafted and are only counted.
  private func CheckWeapons() -> Void {
    let ranged = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
    let melee = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();
    let evolutions: array<gamedataWeaponEvolution> = [gamedataWeaponEvolution.Smart, gamedataWeaponEvolution.Tech, gamedataWeaponEvolution.Power];
    let rangedElements: array<TweakDBID> = [
      t"Items.PreemBarrelSlot01Element", t"Items.PreemBarrelSlot02Element", t"Items.PreemBarrelSlot03Element",
      t"Items.PreemTriggerSlot01Element", t"Items.PreemTriggerSlot02Element",
      t"Items.PreemMagazineSlot01Element", t"Items.PreemMagazineSlot02Element"
    ];
    let meleeElements: array<TweakDBID> = [
      t"Items.PreemBladeSlot01Element", t"Items.PreemBladeSlot02Element",
      t"Items.PreemHandleSlot01Element", t"Items.PreemHandleSlot02Element"
    ];
    let records = TweakDBInterface.GetRecords(n"WeaponItem");

    // The variants are WeaponItem records too; collect their IDs first so they aren't taken for
    // base weapons.
    let variantIDs = new inkHashMap();
    for record in records {
      let weapon = record as WeaponItem_Record;
      if ArrayContains(ranged, PreemSelfCheck.TypeOf(weapon)) {
        for evolution in evolutions {
          variantIDs.Insert(TDBID.ToNumber(weapon.GetID() + PreemSelfCheck.VariantSuffix(evolution)), this);
        }
      }
    }

    let noBlueprint = 0;
    for record in records {
      let weapon = record as WeaponItem_Record;
      let type = PreemSelfCheck.TypeOf(weapon);
      let isRanged = ArrayContains(ranged, type);
      let isBase = !variantIDs.KeyExist(TDBID.ToNumber(weapon.GetID()));
      if isBase && (isRanged || ArrayContains(melee, type)) {
        if isRanged {
          let own = IsDefined(weapon.Evolution()) ? weapon.Evolution().Type() : gamedataWeaponEvolution.Invalid;
          if ArrayContains(evolutions, own) {
            for evolution in evolutions {
              if NotEquals(evolution, own) {
                this.CheckVariant(weapon, evolution);
              }
            }
          }
        }
        let blueprint = weapon.Blueprint();
        if !IsDefined(blueprint) || !IsDefined(blueprint.RootElement()) {
          noBlueprint += 1;
        } else {
          this.Report("elements " + TDBID.ToStringDEBUG(weapon.GetID()), PreemSelfCheck.MissingElements(blueprint.RootElement(), isRanged ? rangedElements : meleeElements));
        }
      }
    }
    FTLog(s"[PreemCheck] info: \(noBlueprint) Preem-eligible weapons have no blueprint (not craftable); skipped");
  }

  private func CheckVariant(weapon: ref<WeaponItem_Record>, evolution: gamedataWeaponEvolution) -> Void {
    let id = weapon.GetID() + PreemSelfCheck.VariantSuffix(evolution);
    let variant = TweakDBInterface.GetWeaponItemRecord(id);
    let problem = "";
    if !IsDefined(variant) {
      // Say what the base is: a base weapon without a debug name can't be found otherwise.
      problem = "missing (base entity " + NameToString(weapon.EntityName()) + ", displayName " + NameToString(weapon.DisplayName()) + ")";
    } else {
      if !IsDefined(variant.Evolution()) || NotEquals(variant.Evolution().Type(), evolution) {
        problem = "wrong evolution";
      } else {
        if NotEquals(PreemSelfCheck.TypeOf(variant), PreemSelfCheck.TypeOf(weapon)) {
          problem = "item type differs from " + TDBID.ToStringDEBUG(weapon.GetID());
        }
      }
    }
    // Cloned records have no debug name, so name the variant after its base weapon.
    this.Report("variant " + TDBID.ToStringDEBUG(weapon.GetID()) + PreemSelfCheck.VariantSuffixName(evolution), problem);
  }

  // ItemType().Type() on a weapon without an item type record returns garbage (it differed between
  // two reads of the same record), so check the record first.
  private static func TypeOf(weapon: ref<WeaponItem_Record>) -> gamedataItemType {
    return IsDefined(weapon.ItemType()) ? weapon.ItemType().Type() : gamedataItemType.Invalid;
  }

  private static func VariantSuffix(evolution: gamedataWeaponEvolution) -> TweakDBID {
    switch evolution {
      case gamedataWeaponEvolution.Smart:
        return t"_PreemSmart";
      case gamedataWeaponEvolution.Tech:
        return t"_PreemTech";
      default:
        return t"_PreemPower";
    }
  }

  private static func VariantSuffixName(evolution: gamedataWeaponEvolution) -> String {
    switch evolution {
      case gamedataWeaponEvolution.Smart:
        return "_PreemSmart";
      case gamedataWeaponEvolution.Tech:
        return "_PreemTech";
      default:
        return "_PreemPower";
    }
  }

  private static func MissingElements(root: wref<ItemBlueprintElement_Record>, expected: array<TweakDBID>) -> String {
    let children: array<wref<ItemBlueprintElement_Record>>;
    root.ChildElements(children);
    let missing = "";
    for id in expected {
      let found = false;
      for child in children {
        if child.GetID() == id {
          found = true;
        }
      }
      if !found {
        missing += (StrLen(missing) > 0 ? ", " : "missing ") + TDBID.ToStringDEBUG(id);
      }
    }
    return missing;
  }
}
