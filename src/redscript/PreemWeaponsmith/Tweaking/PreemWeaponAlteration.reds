import PreemCrafting.CraftingSystem.PreemCraftingSystem.*

@if(ModuleExists("EnhancedCraft.Common"))
import EnhancedCraft.Common.L

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

protected func CreateWeaponEvolutionSet(weaponRecord: ref<WeaponItem_Record>) -> Void {
    let currEvolution: gamedataWeaponEvolution = weaponRecord.Evolution().Type();
    let evolutionTypeList: array<gamedataWeaponEvolution>;
    let itemName1: TweakDBID;
    let itemName2: TweakDBID;
    let itemName1Test: CName;
    let itemName2Test: CName;
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
                itemName1 = weaponRecord.GetID() + t"_PreemTech";
                itemName2 = weaponRecord.GetID() + t"_PreemPower";
                //itemName1Test = StringToName(TweakDBInterface.GetString(weaponRecord.GetID() + t".stringName", "") + "_PreemTech");
                //itemName1 = TDBID.Create(NameToString(itemName1Test));
                //itemName2 = weaponRecord.GetID() + t"_PreemPower";

                TweakDBManager.CloneRecord(itemName1, weaponRecord.GetID());
                TweakDBManager.CloneRecord(itemName2, weaponRecord.GetID());
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
                itemName1 = weaponRecord.GetID() + t"_PreemSmart";
                itemName2 = weaponRecord.GetID() + t"_PreemPower";
                //itemName1Test = StringToName(TweakDBInterface.GetString(weaponRecord.GetID() + t".stringName", "") + "_PreemSmart");
                //itemName1 = TDBID.Create(NameToString(itemName1Test));
                TweakDBManager.CloneRecord(itemName1, weaponRecord.GetID());
                TweakDBManager.CloneRecord(itemName2, weaponRecord.GetID());  
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
                itemName1 = weaponRecord.GetID() + t"_PreemTech";
                itemName2 = weaponRecord.GetID() + t"_PreemSmart";
                //itemName1Test = StringToName(TweakDBInterface.GetString(weaponRecord.GetID() + t".stringName", "") + "_PreemTech");
                //itemName2Test = StringToName(TweakDBInterface.GetString(weaponRecord.GetID() + t".stringName", "") + "_PreemSmart");
                //itemName1 = TDBID.Create(NameToString(itemName1Test));
                //itemName2 = TDBID.Create(NameToString(itemName2Test));
                TweakDBManager.CloneRecord(itemName1, weaponRecord.GetID());
                TweakDBManager.CloneRecord(itemName2, weaponRecord.GetID());
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
    

    //Conditional methods for other mods creating new records
    CreateWeaponEvolutionSetEnhancedCraft(weaponRecord);
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

protected func CreatePreemSlots() -> Void {

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemBarrelMod01", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemBarrelMod01.entitySlotName", "PreemBarrelMod01");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemBarrelMod01");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemBarrelMod02", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemBarrelMod02.entitySlotName", "PreemBarrelMod02");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemBarrelMod02");

    //Create Slot Record
    //TweakDBManager.CloneRecord(n"AttachmentSlots.PowerModule2", t"AttachmentSlots.PowerModule");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemTriggerMod01", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemTriggerMod01.entitySlotName", "PreemTriggerMod01");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemTriggerMod01");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemTriggerMod02", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemTriggerMod02.entitySlotName", "PreemTriggerMod02");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemTriggerMod02");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemMagazineMod01", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemMagazineMod01.entitySlotName", "PreemMagazineMod01");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemMagazineMod01");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemMagazineMod02", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemMagazineMod02.entitySlotName", "PreemMagazineMod02");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemMagazineMod02");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemBladeMod01", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemBladeMod01.entitySlotName", "PreemBladeMod01");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemBladeMod01");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemBladeMod02", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemBladeMod02.entitySlotName", "PreemBladeMod02");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemBladeMod02");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemHandleMod01", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemHandleMod01.entitySlotName", "PreemHandleMod01");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemHandleMod01");

    //Create Slot Record
    TweakDBManager.CloneRecord(n"AttachmentSlots.PreemHandleMod02", t"AttachmentSlots.IconicWeaponModLegendary");
    TweakDBManager.SetFlat(t"AttachmentSlots.PreemHandleMod02.entitySlotName", "PreemHandleMod02");
    TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemHandleMod02");
    
}

protected func CreatePreemWeaponBlueprintElements()
{
    let powerElementList: array<TweakDBID>;

    //Create ItemBlueprintChildElement Record
    TweakDBManager.CloneRecord(n"Items.PreemBarrelSlot01Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemBarrelSlot01Element.slot", t"AttachmentSlots.PreemBarrelMod01");
    TweakDBManager.UpdateRecord(t"Items.PreemBarrelSlot01Element");

    TweakDBManager.CloneRecord(n"Items.PreemBarrelSlot02Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemBarrelSlot02Element.slot", t"AttachmentSlots.PreemBarrelMod02");
    TweakDBManager.UpdateRecord(t"Items.PreemBarrelSlot02Element");

    TweakDBManager.CloneRecord(n"Items.PreemBarrelSlot03Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemBarrelSlot03Element.slot", t"AttachmentSlots.PowerModule");
    TweakDBManager.UpdateRecord(t"Items.PreemBarrelSlot03Element");

    // TweakDBManager.CloneRecord(n"Items.PreemBarrelSlot03Element", t"Items.Base_Handgun_Blueprint_inline4");
    // TweakDBManager.UpdateRecord(t"Items.PreemBarrelSlot03Element");

    TweakDBManager.CloneRecord(n"Items.PreemTriggerSlot01Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemTriggerSlot01Element.slot", t"AttachmentSlots.PreemTriggerMod01");
    TweakDBManager.UpdateRecord(t"Items.PreemTriggerSlot01Element");

    TweakDBManager.CloneRecord(n"Items.PreemTriggerSlot02Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemTriggerSlot02Element.slot", t"AttachmentSlots.PreemTriggerMod02");
    TweakDBManager.UpdateRecord(t"Items.PreemTriggerSlot02Element");

    TweakDBManager.CloneRecord(n"Items.PreemMagazineSlot01Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemMagazineSlot01Element.slot", t"AttachmentSlots.PreemMagazineMod01");
    TweakDBManager.UpdateRecord(t"Items.PreemMagazineSlot01Element");

    TweakDBManager.CloneRecord(n"Items.PreemMagazineSlot02Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemMagazineSlot02Element.slot", t"AttachmentSlots.PreemMagazineMod02");
    TweakDBManager.UpdateRecord(t"Items.PreemMagazineSlot02Element");

    TweakDBManager.CloneRecord(n"Items.PreemBladeSlot01Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemBladeSlot01Element.slot", t"AttachmentSlots.PreemBladeMod01");
    TweakDBManager.UpdateRecord(t"Items.PreemBladeSlot01Element");
    
    TweakDBManager.CloneRecord(n"Items.PreemBladeSlot02Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemBladeSlot02Element.slot", t"AttachmentSlots.PreemBladeMod02");
    TweakDBManager.UpdateRecord(t"Items.PreemBladeSlot02Element");

    TweakDBManager.CloneRecord(n"Items.PreemHandleSlot01Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemHandleSlot01Element.slot", t"AttachmentSlots.PreemHandleMod01");
    TweakDBManager.UpdateRecord(t"Items.PreemHandleSlot01Element");

    TweakDBManager.CloneRecord(n"Items.PreemHandleSlot02Element", t"Items.Base_Tech_Shotgun_NoMuzzle_Blueprint_inline2");
    TweakDBManager.SetFlat(t"Items.PreemHandleSlot02Element.slot", t"AttachmentSlots.PreemHandleMod02");
    TweakDBManager.UpdateRecord(t"Items.PreemHandleSlot02Element");
}

protected cb func OnApply() -> Void {
    this.CreatePreemSlots();
    this.CreatePreemWeaponBlueprintElements();

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


@if(ModuleExists("EnhancedCraft.Common"))
func CreateWeaponEvolutionSetEnhancedCraft(weaponRecord: ref<WeaponItem_Record>) -> Void {
    let currEvolution: gamedataWeaponEvolution = weaponRecord.Evolution().Type();
    let evolutionTypeList: array<gamedataWeaponEvolution>;
    let weaponNameBase: String;
    let itemName1: TweakDBID;
    let itemName2: TweakDBID;
    let itemName1Test: CName;
    let itemName2Test: CName;
    let statPoolList: array<TweakDBID>;
    let statModifierGroupsList: array<TweakDBID>;
    let statModifiersList: array<TweakDBID>;
    let weaponsVariants: array<CName>;
    let variantRecord: ref<Item_Record>;
    let variantVisualTags: array<CName>;
    let firstTag: CName;
    let weaponNameWithVariant: String;
    let isPresetIconic: Bool;
    let weaponECraftVariants: array<TweakDBID>;
    let smartOnAttach: array<TweakDBID>;
    ArrayPush(statPoolList,t"BaseStatPools.WeaponCharge");
    //let attackList: array<TweakDBID>;
    weaponsVariants = TweakDBInterface.GetCNameArray(weaponRecord.GetID() + t".weaponVariants");
    weaponNameBase = TweakDBInterface.GetString(weaponRecord.GetID() + t".stringName", "");
    weaponECraftVariants = TweakDBInterface.GetForeignKeyArray(weaponRecord.GetID() + t".ecraftVariants");
    smartOnAttach = FromVariant(TweakDBInterface.GetFlat(weaponRecord.GetID() + t".OnAttach"));
    ArrayPush(smartOnAttach,t"Items.SmartWeaponTargetsPriorityQueues");

    for weaponVariant in weaponsVariants
    {
        variantRecord = TweakDBInterface.GetItemRecord(TDBID.Create(NameToString(weaponVariant)));
        variantVisualTags = variantRecord.VisualTags();
        isPresetIconic = TweakDBInterface.GetBool(TDBID.Create(s"\(weaponVariant).iconicVariant"), false);
        if ArraySize(variantVisualTags) > 0 {  

            firstTag = variantVisualTags[0];
            weaponNameWithVariant = s"\(weaponNameBase)_\(firstTag)";

            switch currEvolution
            {
                case gamedataWeaponEvolution.Smart:
                    //itemName1 = weaponRecord.GetID() + t"_PreemTech";
                    itemName1Test = StringToName(weaponNameWithVariant + "_PreemTech");
                    itemName2Test = StringToName(weaponNameWithVariant + "_PreemPower");
                    itemName1 = TDBID.Create(NameToString(itemName1Test));
                    itemName2 = TDBID.Create(NameToString(itemName2Test));
                    //itemName2 = weaponRecord.GetID() + t"_PreemPower";
                    TweakDBManager.CloneRecord(itemName1Test, weaponRecord.GetID());
                    TweakDBManager.CloneRecord(itemName2Test, weaponRecord.GetID());
                    TweakDBManager.SetFlat(itemName1Test + n".evolution", t"WeaponEvolution.Tech");
                    TweakDBManager.SetFlat(itemName1Test + n".secondaryTriggerMode", t"TriggerMode.Charge");
                    TweakDBManager.SetFlat(itemName1 + t".statPools", statPoolList);
                    TweakDBManager.SetFlat(itemName1Test + n".crosshair", t"Crosshairs.Tech_Omaha");
                    TweakDBManager.SetFlat(itemName1Test + n".fxPackage", t"WeaponFxPackage.TechRevolver");
                    TweakDBManager.SetFlat(itemName1Test + n".isPresetIconic", isPresetIconic);
                    TweakDBManager.SetFlat(itemName1Test + n".usesVariants", true);
                    TweakDBManager.SetFlat(itemName1Test + n".visualTags", variantVisualTags);
                    TweakDBManager.SetFlat(itemName1Test + n".iconPath", variantRecord.IconPath());
                    TweakDBManager.SetFlat(itemName2Test + n".evolution", t"WeaponEvolution.Power");
                    TweakDBManager.SetFlat(itemName2Test + n".previewEffectName", n"weaponPreview");
                    TweakDBManager.SetFlat(itemName2Test + n".previewEffectTag", n"ricochet");
                    TweakDBManager.SetFlat(itemName2Test + n".crosshair", t"Crosshairs.Basic");
                    TweakDBManager.SetFlat(itemName2Test + n".isPresetIconic", isPresetIconic);
                    TweakDBManager.SetFlat(itemName2Test + n".usesVariants", true);
                    TweakDBManager.SetFlat(itemName2Test + n".visualTags", variantVisualTags);
                    TweakDBManager.SetFlat(itemName2Test + n".iconPath", variantRecord.IconPath());
                    TweakDBManager.UpdateRecord(itemName1);
                    TweakDBManager.UpdateRecord(itemName2);
                    ArrayPush(weaponECraftVariants, itemName1);
                    ArrayPush(weaponECraftVariants, itemName2);
                    TweakDBManager.SetFlat(weaponRecord.GetID() + t".ecraftVariants", ToVariant(weaponECraftVariants));
                    TweakDBManager.UpdateRecord(weaponRecord.GetID());
                    break;
                case gamedataWeaponEvolution.Tech:
                    //itemName1 = weaponRecord.GetID() + t"_PreemSmart";
                    itemName1Test = StringToName(weaponNameWithVariant + "_PreemSmart");
                    itemName2Test = StringToName(weaponNameWithVariant + "_PreemPower");
                    itemName1 = TDBID.Create(NameToString(itemName1Test));
                    itemName2 = TDBID.Create(NameToString(itemName2Test));
                    TweakDBManager.CloneRecord(itemName1Test, weaponRecord.GetID());
                    TweakDBManager.CloneRecord(itemName2Test, weaponRecord.GetID());  
                    TweakDBManager.SetFlat(itemName1Test + n".evolution", t"WeaponEvolution.Smart");
                    TweakDBManager.SetFlat(itemName1Test + n".crosshair", t"Crosshairs.SmartGun");
                    TweakDBManager.SetFlat(itemName1Test + n".isPresetIconic", isPresetIconic);
                    TweakDBManager.SetFlat(itemName1Test + n".usesVariants", true);
                    TweakDBManager.SetFlat(itemName1Test + n".visualTags", variantVisualTags);
                    TweakDBManager.SetFlat(itemName1Test + n".iconPath", variantRecord.IconPath());
                    TweakDBManager.SetFlat(itemName1Test + n".OnAttach", smartOnAttach);
                    TweakDBManager.SetFlat(itemName2Test + n".evolution", t"WeaponEvolution.Power");
                    TweakDBManager.SetFlat(itemName2Test + n".previewEffectName", n"weaponPreview");
                    TweakDBManager.SetFlat(itemName2Test + n".previewEffectTag", n"ricochet");
                    TweakDBManager.SetFlat(itemName2Test + n".crosshair", t"Crosshairs.Basic");
                    TweakDBManager.SetFlat(itemName2Test + n".isPresetIconic", isPresetIconic);
                    TweakDBManager.SetFlat(itemName2Test + n".usesVariants", true);
                    TweakDBManager.SetFlat(itemName2Test + n".visualTags", variantVisualTags);
                    TweakDBManager.SetFlat(itemName2Test + n".iconPath", variantRecord.IconPath());
                    TweakDBManager.UpdateRecord(itemName1);
                    TweakDBManager.UpdateRecord(itemName2);
                    ArrayPush(weaponECraftVariants, itemName1);
                    ArrayPush(weaponECraftVariants, itemName2);
                    TweakDBManager.SetFlat(weaponRecord.GetID() + t".ecraftVariants", ToVariant(weaponECraftVariants));
                    TweakDBManager.UpdateRecord(weaponRecord.GetID());
                    break;
                case gamedataWeaponEvolution.Power:
                    //itemName1 = weaponRecord.GetID() + t"_PreemTech";
                    //itemName2 = weaponRecord.GetID() + t"_PreemSmart";
                    itemName1Test = StringToName(weaponNameWithVariant + "_PreemTech");
                    itemName2Test = StringToName(weaponNameWithVariant + "_PreemSmart");
                    itemName1 = TDBID.Create(NameToString(itemName1Test));
                    itemName2 = TDBID.Create(NameToString(itemName2Test));
                    TweakDBManager.CloneRecord(itemName1Test, weaponRecord.GetID());
                    TweakDBManager.CloneRecord(itemName2Test, weaponRecord.GetID());
                    TweakDBManager.SetFlat(itemName1Test + n".evolution", t"WeaponEvolution.Tech");
                    TweakDBManager.SetFlat(itemName1Test + n".secondaryTriggerMode", t"TriggerMode.Charge");
                    TweakDBManager.SetFlat(itemName1 + t".statPools", statPoolList);
                    TweakDBManager.SetFlat(itemName1Test + n".crosshair", t"Crosshairs.Tech_Omaha");
                    TweakDBManager.SetFlat(itemName1Test + n".fxPackage", t"WeaponFxPackage.TechRevolver");
                    TweakDBManager.SetFlat(itemName1Test + n".isPresetIconic", isPresetIconic);
                    TweakDBManager.SetFlat(itemName1Test + n".usesVariants", true);
                    TweakDBManager.SetFlat(itemName1Test + n".visualTags", variantVisualTags);
                    TweakDBManager.SetFlat(itemName1Test + n".iconPath", variantRecord.IconPath());
                    TweakDBManager.SetFlat(itemName2Test + n".evolution", t"WeaponEvolution.Smart");
                    TweakDBManager.SetFlat(itemName2Test + n".crosshair", t"Crosshairs.SmartGun");
                    TweakDBManager.SetFlat(itemName2Test + n".OnAttach", smartOnAttach);
                    TweakDBManager.SetFlat(itemName2Test + n".isPresetIconic", isPresetIconic);
                    TweakDBManager.SetFlat(itemName2Test + n".usesVariants", true);
                    TweakDBManager.SetFlat(itemName2Test + n".visualTags", variantVisualTags);
                    TweakDBManager.SetFlat(itemName2Test + n".iconPath", variantRecord.IconPath());
                    TweakDBManager.UpdateRecord(itemName1);
                    TweakDBManager.UpdateRecord(itemName2);
                    ArrayPush(weaponECraftVariants, itemName1);
                    ArrayPush(weaponECraftVariants, itemName2);
                    TweakDBManager.SetFlat(weaponRecord.GetID() + t".ecraftVariants", ToVariant(weaponECraftVariants));
                    TweakDBManager.UpdateRecord(weaponRecord.GetID());
                    break;
            }
        }

    }
}

@if(!ModuleExists("EnhancedCraft.Common"))
func CreateWeaponEvolutionSetEnhancedCraft(weaponRecord: ref<WeaponItem_Record>) -> Void {
    //Do nothing
}