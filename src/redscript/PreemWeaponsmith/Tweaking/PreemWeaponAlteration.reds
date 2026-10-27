import PreemCrafting.CraftingSystem.PreemCraftingSystem.*

public class PreemWeaponAlteration extends ScriptableTweak {

    protected func GiveAllRangedWeaponsEvolutions(record: ref<TweakDBRecord>) -> Void {
            let rangedWeaponItemTypeList: array<gamedataItemType>;
            let baseRecord = record as WeaponItem_Record;
            let baseRecordId: TweakDBID = baseRecord.GetID();
            let baseRecordType: gamedataItemType = baseRecord.ItemType().Type();

            //Wea_AssaultRifle = 54,
            //Wea_Axe = 55,
            //Wea_Chainsword = 56,
            //Wea_Fists = 57,
            //Wea_Hammer = 58,
            //Wea_Handgun = 59,
            //Wea_HeavyMachineGun = 60,
            //Wea_Katana = 61,
            //Wea_Knife = 62,
            //Wea_LightMachineGun = 63,
            //Wea_LongBlade = 64,
            //Wea_Machete = 65,
            //Wea_Melee = 66,
            //Wea_OneHandedClub = 67,
            //Wea_PrecisionRifle = 68,
            //Wea_Revolver = 69,
            //Wea_Rifle = 70,
            //Wea_ShortBlade = 71,
            //Wea_Shotgun = 72,
            //Wea_ShotgunDual = 73,
            //Wea_SniperRifle = 74,
            //Wea_SubmachineGun = 75,
            //Wea_TwoHandedClub

            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_AssaultRifle);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_Handgun);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_HeavyMachineGun);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_LightMachineGun);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_PrecisionRifle);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_Revolver);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_Rifle);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_Shotgun);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_ShotgunDual);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_SniperRifle);
            ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_SubmachineGun);

            if(ArrayContains(rangedWeaponItemTypeList,baseRecordType))
            {
                this.CreateWeaponEvolutionSet(baseRecord);
            }
}

// Clones the base weapon as <base>_Preem<Evolution>. The CName overload also registers the name,
// so CET and the dumps show it; a base without a debug name gets a bare ID. Same ID either way.
private func CloneVariant(base: TweakDBID, suffix: String) -> TweakDBID {
  let id = base + TDBID.Create(suffix);
  let baseName = TDBID.ToStringDEBUG(base);
  if !StrBeginsWith(baseName, "<TDBID:") && TDBID.Create(baseName + suffix) == id {
    TweakDBManager.CloneRecord(StringToName(baseName + suffix), base);
  } else {
    TweakDBManager.CloneRecord(id, base);
  }
  return id;
}

// The clone still carries the base's evolution markers; set the variant's own, as vanilla weapons
// of that evolution have them.
private func SetEvolutionMarkers(variant: TweakDBID, from: gamedataWeaponEvolution, evolution: gamedataWeaponEvolution) -> Void {
  this.SetEvolutionTags(variant, evolution);
  if NotEquals(evolution, gamedataWeaponEvolution.Tech) {
    PreemWeaponAlteration.DropChargeSecondaryTrigger(variant);
  }
  PreemWeaponAlteration.SetPreviewEffect(variant, evolution);
  PreemWeaponAlteration.SetEvolutionPrice(variant + t".buyPrice", evolution);
  PreemWeaponAlteration.SetEvolutionPrice(variant + t".sellPrice", evolution);
  PreemWeaponAlteration.AddEvolutionStatModifiers(variant, from, evolution);
}

// A weapon's price list has one Price.<Evolution>Weapon multiplier; swap it in place for the
// variant's. Lists without one (some NPC records) are left alone.
private static func SetEvolutionPrice(priceFlat: TweakDBID, evolution: gamedataWeaponEvolution) -> Void {
  let entries: array<TweakDBID> = [t"Price.SmartWeapon", t"Price.TechWeapon", t"Price.PowerWeapon"];
  let own = t"Price.PowerWeapon";
  if Equals(evolution, gamedataWeaponEvolution.Smart) {
    own = t"Price.SmartWeapon";
  }
  if Equals(evolution, gamedataWeaponEvolution.Tech) {
    own = t"Price.TechWeapon";
  }
  // A clone's flat ID can collide with another flat's (Items.Preset_Nova_Military_Left_Hand_PreemSmart
  // .buyPrice reads as a number); never write to that one.
  let flat = TweakDBInterface.GetFlat(priceFlat);
  if NotEquals(VariantTypeName(flat), n"array:TweakDBID") {
    return;
  }
  let prices: array<TweakDBID> = FromVariant(flat);
  let i = 0;
  while i < ArraySize(prices) {
    if ArrayContains(entries, prices[i]) {
      prices[i] = own;
    }
    i += 1;
  }
  TweakDBManager.SetFlat(priceFlat, prices);
}

// The inspect preview shows a Tech gun's penetration or a Power gun's ricochet; Smart guns have none.
private static func SetPreviewEffect(variant: TweakDBID, evolution: gamedataWeaponEvolution) -> Void {
  switch evolution {
    case gamedataWeaponEvolution.Smart:
      TweakDBManager.SetFlat(variant + t".previewEffectName", n"None");
      TweakDBManager.SetFlat(variant + t".previewEffectTag", n"None");
      break;
    case gamedataWeaponEvolution.Tech:
      TweakDBManager.SetFlat(variant + t".previewEffectName", n"weaponPreview");
      TweakDBManager.SetFlat(variant + t".previewEffectTag", n"pierce");
      break;
    case gamedataWeaponEvolution.Power:
      TweakDBManager.SetFlat(variant + t".previewEffectName", n"weaponPreview");
      TweakDBManager.SetFlat(variant + t".previewEffectTag", n"ricochet");
      break;
  }
}

// Swaps the cloned evolution tags for the variant's own, as vanilla weapons carry them. The game
// reads these tags for the Smart/Tech/Power damage perks and skill XP, not the evolution flat.
private func SetEvolutionTags(variant: TweakDBID, evolution: gamedataWeaponEvolution) -> Void {
  let evolutionTags: array<CName> = [n"Smart", n"SmartWeapon", n"TechWeapon", n"PowerWeapon"];
  let tags: array<CName> = FromVariant(TweakDBInterface.GetFlat(variant + t".tags"));
  let newTags: array<CName>;
  for tag in tags {
    if !ArrayContains(evolutionTags, tag) {
      ArrayPush(newTags, tag);
    }
  }
  switch evolution {
    case gamedataWeaponEvolution.Smart:
      ArrayPush(newTags, n"Smart");
      ArrayPush(newTags, n"SmartWeapon");
      break;
    case gamedataWeaponEvolution.Tech:
      ArrayPush(newTags, n"TechWeapon");
      break;
    case gamedataWeaponEvolution.Power:
      ArrayPush(newTags, n"PowerWeapon");
      break;
  }
  TweakDBManager.SetFlat(variant + t".tags", newTags);
}

// Vanilla's evolution DPS penalty (Smart x0.8, Tech x0.9) sits in the class group
// Items.Base_<Evolution>_<Class>_Mult_Stats, and Smart's headshot penalties in Items.Base_Smart_Stats
// (-0.5) and the Smart handgun (-0.15) and sniper (-1.0) class groups. A clone keeps every group of
// its original, so only these modifiers are added: undo the old evolution's DPS and headshot
// penalties, apply the new one's (the Smart barrel brings Smart's -0.5). Undo records are in
// tweaks/evolution-stats.yaml. No class group (NPC and vehicle weapons): nothing.
public static func EvolutionStatModifiers(groups: array<TweakDBID>, from: gamedataWeaponEvolution, to: gamedataWeaponEvolution) -> array<TweakDBID> {
  let result: array<TweakDBID>;
  let index = -1;
  for group in groups {
    if index < 0 {
      index = PreemWeaponAlteration.ClassStatGroupIndex(group);
    }
  }
  if index < 0 || Equals(from, to) {
    return result;
  }
  if Equals(from, gamedataWeaponEvolution.Smart) {
    ArrayPush(result, t"PreemWeaponsmith.UndoSmartDPSReduction");
  }
  if Equals(from, gamedataWeaponEvolution.Tech) {
    ArrayPush(result, t"PreemWeaponsmith.UndoTechDPSReduction");
  }
  if Equals(to, gamedataWeaponEvolution.Smart) {
    ArrayPush(result, t"AttackModifier.SmartWeaponDPSReduction");
  }
  if Equals(to, gamedataWeaponEvolution.Tech) {
    ArrayPush(result, t"AttackModifier.TechWeaponDPSReduction");
  }
  if Equals(from, gamedataWeaponEvolution.Smart) {
    ArrayPush(result, t"PreemWeaponsmith.UndoSmartHeadshotPenalty");
    if index == PreemWeaponAlteration.HandgunClass() || index == PreemWeaponAlteration.RevolverClass() {
      ArrayPush(result, t"PreemWeaponsmith.UndoSmartHandgunHeadshotPenalty");
    }
    if index == PreemWeaponAlteration.SniperClass() {
      ArrayPush(result, t"PreemWeaponsmith.UndoSmartSniperHeadshotPenalty");
    }
  }
  if Equals(to, gamedataWeaponEvolution.Smart) {
    // Vanilla has no Smart revolver; it takes the Smart handgun's penalty.
    if index == PreemWeaponAlteration.HandgunClass() || index == PreemWeaponAlteration.RevolverClass() {
      ArrayPush(result, t"Items.Base_Smart_Handgun_Mult_Stats_inline1");
    }
    if index == PreemWeaponAlteration.SniperClass() {
      ArrayPush(result, t"Items.Base_Smart_Sniper_Rifle_Mult_Stats_inline1");
    }
  }
  return result;
}

// Vanilla's class groups, one per class in the same order for every evolution; None where vanilla
// has no weapon of that evolution and class (Smart revolver, Smart and Tech LMG).
private static func ClassStatGroups(evolution: gamedataWeaponEvolution) -> array<TweakDBID> {
  switch evolution {
    case gamedataWeaponEvolution.Smart:
      return [t"Items.Base_Smart_Assault_Rifle_Mult_Stats", t"Items.Base_Smart_Handgun_Mult_Stats", TDBID.None(), t"Items.Base_Smart_Precision_Rifle_Mult_Stats",
        TDBID.None(), t"Items.Base_Smart_Shotgun_Mult_Stats", t"Items.Base_Smart_Sniper_Rifle_Mult_Stats", t"Items.Base_Smart_Submachinegun_Mult_Stats"];
    case gamedataWeaponEvolution.Tech:
      return [t"Items.Base_Tech_Assault_Rifle_Mult_Stats", t"Items.Base_Tech_Handgun_Mult_Stats", TDBID.None(), t"Items.Base_Tech_Precision_Rifle_Mult_Stats",
        t"Items.Base_Tech_Revolver_Mult_Stats", t"Items.Base_Tech_Shotgun_Mult_Stats", t"Items.Base_Tech_Sniper_Rifle_Mult_Stats", t"Items.Base_Tech_Submachinegun_Mult_Stats"];
    default:
      return [t"Items.Base_Power_Assault_Rifle_Mult_Stats", t"Items.Base_Power_Handgun_Mult_Stats", t"Items.Base_Power_Lightmachinegun_Mult_Stats", t"Items.Base_Power_Precision_Rifle_Mult_Stats",
        t"Items.Base_Power_Revolver_Mult_Stats", t"Items.Base_Power_Shotgun_Mult_Stats", t"Items.Base_Power_Sniper_Rifle_Mult_Stats", t"Items.Base_Power_Submachinegun_Mult_Stats"];
  }
}

private static func HandgunClass() -> Int32 { return 1; }
private static func RevolverClass() -> Int32 { return 4; }
private static func SniperClass() -> Int32 { return 6; }

private static func ClassStatGroupIndex(group: TweakDBID) -> Int32 {
  if !TDBID.IsValid(group) {
    return -1;
  }
  for evolution in [gamedataWeaponEvolution.Smart, gamedataWeaponEvolution.Tech, gamedataWeaponEvolution.Power] {
    let classGroups = PreemWeaponAlteration.ClassStatGroups(evolution);
    let index = ArrayFindFirst(classGroups, group);
    if index >= 0 {
      return index;
    }
  }
  return -1;
}

private static func AddEvolutionStatModifiers(variant: TweakDBID, from: gamedataWeaponEvolution, to: gamedataWeaponEvolution) -> Void {
  let groupsFlat = TweakDBInterface.GetFlat(variant + t".statModifierGroups");
  let modsFlat = TweakDBInterface.GetFlat(variant + t".statModifiers");
  if NotEquals(VariantTypeName(groupsFlat), n"array:TweakDBID") || NotEquals(VariantTypeName(modsFlat), n"array:TweakDBID") {
    return;
  }
  let groups: array<TweakDBID> = FromVariant(groupsFlat);
  let mods: array<TweakDBID> = FromVariant(modsFlat);
  for mod in PreemWeaponAlteration.EvolutionStatModifiers(groups, from, to) {
    ArrayPush(mods, mod);
  }
  TweakDBManager.SetFlat(variant + t".statModifiers", mods);
}

// Vanilla Smart and Power weapons have no Charge secondary trigger (Tech guns do). With none, the
// game never offers the fire-mode switch (WeaponObject.HasSecondaryTriggerMode is false).
private static func DropChargeSecondaryTrigger(variant: TweakDBID) -> Void {
  let secondary: TweakDBID = FromVariant(TweakDBInterface.GetFlat(variant + t".secondaryTriggerMode"));
  if secondary == t"TriggerMode.Charge" {
    TweakDBManager.SetFlat(variant + t".secondaryTriggerMode", TDBID.None());
  }
}

protected func CreateWeaponEvolutionSet(weaponRecord: ref<WeaponItem_Record>) -> Void {
    let currEvolution: gamedataWeaponEvolution = weaponRecord.Evolution().Type();
    let evolutionTypeList: array<gamedataWeaponEvolution>;
    let itemName1: TweakDBID;
    let itemName2: TweakDBID;
    let statPoolList: array<TweakDBID>;
    let statModifierGroupsList: array<TweakDBID>;
    let statModifiersList: array<TweakDBID>;
    let smartOnAttach: array<TweakDBID>;
    smartOnAttach = FromVariant(TweakDBInterface.GetFlat(weaponRecord.GetID() + t".OnAttach"));
    ArrayPush(statPoolList,t"BaseStatPools.WeaponCharge");
    ArrayPush(smartOnAttach,t"Items.SmartWeaponTargetsPriorityQueues");
    //let attackList: array<TweakDBID>;
    // attackList = FromVariant(TweakDBInterface.GetFlat(weaponRecord.GetID() + t".attacks"));
    // ArrayPush(attackList,t"Attacks.PlasmaProjectile");
    // ArrayPush(attackList,t"Attacks.PlasmaBeamShot");
    // ArrayPush(attackList,t"Attacks.PlasmaProjectileWeak");
    // ArrayPush(attackList,t"Attacks.PlasmaProjectileSplash");
    // ArrayPush(attackList,t"Attacks.PlasmaBeam");
    // ArrayPush(attackList,t"Attacks.BiotechGrenadeV2");
    // ArrayPush(attackList,t"Attacks.BombusFlameShort");

    // TweakDBManager.SetFlat(weaponRecord.GetID() + t".attacks", attackList);
    // TweakDBManager.UpdateRecord(weaponRecord.GetID());
    ArrayPush(evolutionTypeList, gamedataWeaponEvolution.Smart);
    ArrayPush(evolutionTypeList, gamedataWeaponEvolution.Tech);
    ArrayPush(evolutionTypeList, gamedataWeaponEvolution.Power);

    switch currEvolution
    {

            case gamedataWeaponEvolution.Smart:
                itemName1 = this.CloneVariant(weaponRecord.GetID(), "_PreemTech");
                itemName2 = this.CloneVariant(weaponRecord.GetID(), "_PreemPower");

                TweakDBManager.SetFlat(itemName1 + t".evolution", t"WeaponEvolution.Tech");
                TweakDBManager.SetFlat(itemName1 + t".secondaryTriggerMode", t"TriggerMode.Charge");
                TweakDBManager.SetFlat(itemName1 + t".statPools", statPoolList);
                TweakDBManager.SetFlat(itemName1 + t".crosshair", t"Crosshairs.Tech_Simple");
                TweakDBManager.SetFlat(itemName1 + t".fxPackage", t"WeaponFxPackage.TechRevolver");
                TweakDBManager.SetFlat(itemName2 + t".evolution", t"WeaponEvolution.Power");
                TweakDBManager.SetFlat(itemName2 + t".crosshair", t"Crosshairs.Basic");
                this.SetEvolutionMarkers(itemName1, currEvolution, gamedataWeaponEvolution.Tech);
                this.SetEvolutionMarkers(itemName2, currEvolution, gamedataWeaponEvolution.Power);
                TweakDBManager.UpdateRecord(itemName1);
                TweakDBManager.UpdateRecord(itemName2);
                break;
            case gamedataWeaponEvolution.Tech:
                itemName1 = this.CloneVariant(weaponRecord.GetID(), "_PreemSmart");
                itemName2 = this.CloneVariant(weaponRecord.GetID(), "_PreemPower");
                TweakDBManager.SetFlat(itemName1 + t".evolution", t"WeaponEvolution.Smart");
                TweakDBManager.SetFlat(itemName1 + t".fxPackage", t"WeaponFxPackage.SmartRifle");
                TweakDBManager.SetFlat(itemName1 + t".crosshair", t"Crosshairs.SmartGun");
                TweakDBManager.SetFlat(itemName1 + t".OnAttach", smartOnAttach);
                TweakDBManager.SetFlat(itemName2 + t".evolution", t"WeaponEvolution.Power");
                TweakDBManager.SetFlat(itemName2 + t".crosshair", t"Crosshairs.Basic");
                this.SetEvolutionMarkers(itemName1, currEvolution, gamedataWeaponEvolution.Smart);
                this.SetEvolutionMarkers(itemName2, currEvolution, gamedataWeaponEvolution.Power);
                TweakDBManager.UpdateRecord(itemName1);
                TweakDBManager.UpdateRecord(itemName2);
                break;
            case gamedataWeaponEvolution.Power:
                itemName1 = this.CloneVariant(weaponRecord.GetID(), "_PreemTech");
                itemName2 = this.CloneVariant(weaponRecord.GetID(), "_PreemSmart");
                TweakDBManager.SetFlat(itemName1 + t".evolution", t"WeaponEvolution.Tech");
                TweakDBManager.SetFlat(itemName1 + t".secondaryTriggerMode", t"TriggerMode.Charge");
                TweakDBManager.SetFlat(itemName1 + t".statPools", statPoolList);
                TweakDBManager.SetFlat(itemName1 + t".crosshair", t"Crosshairs.Tech_Simple");
                TweakDBManager.SetFlat(itemName1 + t".fxPackage", t"WeaponFxPackage.TechRevolver");
                TweakDBManager.SetFlat(itemName2 + t".evolution", t"WeaponEvolution.Smart");
                TweakDBManager.SetFlat(itemName2 + t".fxPackage", t"WeaponFxPackage.SmartRifle");
                TweakDBManager.SetFlat(itemName2 + t".crosshair", t"Crosshairs.SmartGun");
                TweakDBManager.SetFlat(itemName2 + t".OnAttach", smartOnAttach);
                this.SetEvolutionMarkers(itemName1, currEvolution, gamedataWeaponEvolution.Tech);
                this.SetEvolutionMarkers(itemName2, currEvolution, gamedataWeaponEvolution.Smart);
                TweakDBManager.UpdateRecord(itemName1);
                TweakDBManager.UpdateRecord(itemName2);
                break;
    }
    
}



protected func GiveAllRangedWeaponsPreemSlots(record: ref<TweakDBRecord>) -> Void {
            let triggerModeList: array<TweakDBID>;
            let triggerModeListOriginal: array<TweakDBID>;
            let blueprintElementList: array<TweakDBID>;
            let blueprintElementListOriginal: array<TweakDBID>;
            let blueprint: TweakDBID;
            let rootElement: TweakDBID;

            ArrayPush(triggerModeList, t"TriggerMode.SemiAuto");
            ArrayPush(triggerModeList, t"TriggerMode.FullAuto");
            ArrayPush(triggerModeList, t"TriggerMode.Burst");
            ArrayPush(triggerModeList, t"TriggerMode.Charge");

            ArrayPush(blueprintElementList, t"Items.PreemBarrelSlot01Element");
            ArrayPush(blueprintElementList, t"Items.PreemBarrelSlot02Element");
            ArrayPush(blueprintElementList, t"Items.PreemBarrelSlot03Element");
            ArrayPush(blueprintElementList, t"Items.PreemTriggerSlot01Element");
            ArrayPush(blueprintElementList, t"Items.PreemTriggerSlot02Element");
            ArrayPush(blueprintElementList, t"Items.PreemMagazineSlot01Element");
            ArrayPush(blueprintElementList, t"Items.PreemMagazineSlot02Element");

            triggerModeListOriginal = FromVariant(TweakDBInterface.GetFlat(record.GetID() + t".triggerModes"));
            for elem in triggerModeList{
                if(!ArrayContains(triggerModeListOriginal, elem))
                {
                    ArrayPush(triggerModeListOriginal, elem);
                }
            }    

            blueprint = FromVariant(TweakDBInterface.GetFlat(record.GetID() + t".blueprint"));

            rootElement = FromVariant(TweakDBInterface.GetFlat(blueprint + t".rootElement"));

            blueprintElementListOriginal = FromVariant(TweakDBInterface.GetFlat(rootElement + t".childElements"));
            for elem in blueprintElementList{
                if(!ArrayContains(blueprintElementListOriginal, elem))
                {
                    ArrayPush(blueprintElementListOriginal, elem);
                }
            }

            TweakDBManager.SetFlat(rootElement + t".childElements", blueprintElementListOriginal);
            TweakDBManager.SetFlat(record.GetID() + t".triggerModes", triggerModeListOriginal);
            TweakDBManager.UpdateRecord(rootElement);
            TweakDBManager.UpdateRecord(blueprint);
            TweakDBManager.UpdateRecord(record.GetID());
    }

protected func GiveAllMeleeWeaponsPreemSlots(record: ref<TweakDBRecord>) -> Void {
            let blueprintElementList: array<TweakDBID>;
            let blueprintElementListOriginal: array<TweakDBID>;
            let blueprint: TweakDBID;
            let rootElement: TweakDBID;

            ArrayPush(blueprintElementList, t"Items.PreemBladeSlot01Element");
            ArrayPush(blueprintElementList, t"Items.PreemBladeSlot02Element");
            ArrayPush(blueprintElementList, t"Items.PreemHandleSlot01Element");
            ArrayPush(blueprintElementList, t"Items.PreemHandleSlot02Element");

            blueprint = FromVariant(TweakDBInterface.GetFlat(record.GetID() + t".blueprint"));

            rootElement = FromVariant(TweakDBInterface.GetFlat(blueprint + t".rootElement"));

            blueprintElementListOriginal = FromVariant(TweakDBInterface.GetFlat(rootElement + t".childElements"));
            for elem in blueprintElementList{
                if(!ArrayContains(blueprintElementListOriginal, elem))
                {
                    ArrayPush(blueprintElementListOriginal, elem);
                }
            }

            TweakDBManager.SetFlat(rootElement + t".childElements", blueprintElementListOriginal);
            TweakDBManager.UpdateRecord(rootElement);
            TweakDBManager.UpdateRecord(blueprint);
            TweakDBManager.UpdateRecord(record.GetID());
    }

protected cb func OnApply() -> Void {

    let weaponsList = TweakDBInterface.GetRecords(n"WeaponItem");
    let rangedWeaponItemTypeList: array<gamedataItemType>;
    let meleeWeaponItemTypeList: array<gamedataItemType>;

    rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
    meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

    for record in weaponsList {
        let baseRecord = record as WeaponItem_Record;
        // Some NPC weapons (e.g. Jurij.Jurij_Launcher_Base) have no item type record; .Type() on
        // it returns garbage, which sometimes matched a ranged type.
        let baseRecordType: gamedataItemType = IsDefined(baseRecord.ItemType()) ? baseRecord.ItemType().Type() : gamedataItemType.Invalid;

        if(ArrayContains(rangedWeaponItemTypeList, baseRecordType))
        {
            this.GiveAllRangedWeaponsPreemSlots(record);
            this.CreateWeaponEvolutionSet(baseRecord);
        }
        else{
            if(ArrayContains(meleeWeaponItemTypeList, baseRecordType))
            {
                this.GiveAllMeleeWeaponsPreemSlots(record);
            }
        }
    }
}

}
