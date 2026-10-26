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
                TweakDBManager.SetFlat(itemName2 + t".previewEffectName", n"weaponPreview");
                TweakDBManager.SetFlat(itemName2 + t".previewEffectTag", n"ricochet");
                TweakDBManager.SetFlat(itemName2 + t".crosshair", t"Crosshairs.Basic");
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
                TweakDBManager.SetFlat(itemName2 + t".previewEffectName", n"weaponPreview");
                TweakDBManager.SetFlat(itemName2 + t".previewEffectTag", n"ricochet");
                TweakDBManager.SetFlat(itemName2 + t".crosshair", t"Crosshairs.Basic");
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
