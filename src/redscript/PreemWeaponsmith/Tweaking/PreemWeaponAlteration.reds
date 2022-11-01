module PreemCrafting.Tweaking

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
    let statPoolList: array<TweakDBID>;
    let statModifierGroupsList: array<TweakDBID>;
    let statModifiersList: array<TweakDBID>;
    statPoolList = FromVariant(TweakDBInterface.GetFlat(t"Items.Preset_Quasar_Default.statPools"));

    ArrayPush(evolutionTypeList, gamedataWeaponEvolution.Smart);
    ArrayPush(evolutionTypeList, gamedataWeaponEvolution.Tech);

    switch currEvolution
    {

            case gamedataWeaponEvolution.Smart:
                itemName1 = weaponRecord.GetID() + t"_PreemTech";
                TweakDBManager.CloneRecord(itemName1, weaponRecord.GetID());
                TweakDBManager.SetFlat(itemName1 + t".evolution", t"WeaponEvolution.Tech");
                TweakDBManager.SetFlat(itemName1 + t".secondaryTriggerMode", t"TriggerMode.Charge");
                TweakDBManager.SetFlat(itemName1 + t".statPools", statPoolList);
                TweakDBManager.SetFlat(itemName1 + t".crosshair", t"Crosshairs.Tech_Omaha");
                TweakDBManager.SetFlat(itemName1 + t".fxPackage", t"WeaponFxPackage.TechRevolver");
                TweakDBManager.UpdateRecord(itemName1);
                break;
            case gamedataWeaponEvolution.Tech:
                itemName1 = weaponRecord.GetID() + t"_PreemSmart";
                TweakDBManager.CloneRecord(itemName1, weaponRecord.GetID());  
                TweakDBManager.SetFlat(itemName1 + t".evolution", t"WeaponEvolution.Smart");
                TweakDBManager.SetFlat(itemName1 + t".crosshair", t"Crosshairs.SmartGun");
                TweakDBManager.UpdateRecord(itemName1);
                break;
            case gamedataWeaponEvolution.Power:
                itemName1 = weaponRecord.GetID() + t"_PreemTech";
                itemName2 = weaponRecord.GetID() + t"_PreemSmart";
                TweakDBManager.CloneRecord(itemName1, weaponRecord.GetID());
                TweakDBManager.CloneRecord(itemName2, weaponRecord.GetID());

                TweakDBManager.SetFlat(itemName1 + t".evolution", t"WeaponEvolution.Tech");
                TweakDBManager.SetFlat(itemName1 + t".secondaryTriggerMode", t"TriggerMode.Charge");
                TweakDBManager.SetFlat(itemName1 + t".statPools", statPoolList);
                TweakDBManager.SetFlat(itemName1 + t".crosshair", t"Crosshairs.Tech_Omaha");
                TweakDBManager.SetFlat(itemName1 + t".fxPackage", t"WeaponFxPackage.TechRevolver");
                TweakDBManager.SetFlat(itemName2 + t".evolution", t"WeaponEvolution.Smart");
                TweakDBManager.SetFlat(itemName2 + t".crosshair", t"Crosshairs.SmartGun");
                TweakDBManager.UpdateRecord(itemName1);
                TweakDBManager.UpdateRecord(itemName2);
                break;
    }
}


    protected func GiveAllWeaponsPreemSlots(record: ref<TweakDBRecord>) -> Void {
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
            //LogChannel(n"DEBUG", s"PreemWeaponAlterations:: BlueprintOGElements: \(ArraySize(blueprintElementListOriginal))");
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

    protected func CreatePreemSlots() -> Void {

        //Create Slot Record
        TweakDBManager.CloneRecord(n"AttachmentSlots.PreemBarrelMod01", t"AttachmentSlots.IconicWeaponModLegendary");
        TweakDBManager.SetFlat(t"AttachmentSlots.PreemBarrelMod01.entitySlotName", "PreemBarrelMod01");
        TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemBarrelMod01");

        //Create Slot Record
        TweakDBManager.CloneRecord(n"AttachmentSlots.PreemBarrelMod02", t"AttachmentSlots.IconicWeaponModLegendary");
        TweakDBManager.SetFlat(t"AttachmentSlots.PreemBarrelMod02.entitySlotName", "PreemBarrelMod01");
        TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemBarrelMod02");

        //Create Slot Record
        TweakDBManager.CloneRecord(n"AttachmentSlots.PreemTriggerMod01", t"AttachmentSlots.IconicWeaponModLegendary");
        TweakDBManager.SetFlat(t"AttachmentSlots.PreemTriggerMod01.entitySlotName", "PreemTriggerMod01");
        TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemTriggerMod01");

        //Create Slot Record
        TweakDBManager.CloneRecord(n"AttachmentSlots.PreemTriggerMod02", t"AttachmentSlots.IconicWeaponModLegendary");
        TweakDBManager.SetFlat(t"AttachmentSlots.PreemTriggerMod02.entitySlotName", "PreemTriggerMod01");
        TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemTriggerMod02");

        //Create Slot Record
        TweakDBManager.CloneRecord(n"AttachmentSlots.PreemMagazineMod01", t"AttachmentSlots.IconicWeaponModLegendary");
        TweakDBManager.SetFlat(t"AttachmentSlots.PreemMagazineMod01.entitySlotName", "PreemMagazineMod01");
        TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemMagazineMod01");

        //Create Slot Record
        TweakDBManager.CloneRecord(n"AttachmentSlots.PreemMagazineMod02", t"AttachmentSlots.IconicWeaponModLegendary");
        TweakDBManager.SetFlat(t"AttachmentSlots.PreemMagazineMod02.entitySlotName", "PreemMagazineMod01");
        TweakDBManager.UpdateRecord(t"AttachmentSlots.PreemMagazineMod02");
        
    }

    protected func CreatePreemWeaponBlueprintElements()
    {

        //Create ItemBlueprintChildElement Record
        TweakDBManager.CloneRecord(n"Items.PreemBarrelSlot01Element", t"Items.IconicWeaponModElement");
        TweakDBManager.SetFlat(t"Items.PreemBarrelSlot01Element.slot", t"AttachmentSlots.PreemBarrelMod01");
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelSlot01Element");

        TweakDBManager.CloneRecord(n"Items.PreemBarrelSlot02Element", t"Items.IconicWeaponModElement");
        TweakDBManager.SetFlat(t"Items.PreemBarrelSlot02Element.slot", t"AttachmentSlots.PreemBarrelMod02");
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelSlot02Element");

        TweakDBManager.CloneRecord(n"Items.PreemTriggerSlot01Element", t"Items.IconicWeaponModElement");
        TweakDBManager.SetFlat(t"Items.PreemTriggerSlot01Element.slot", t"AttachmentSlots.PreemTriggerMod01");
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerSlot01Element");

        TweakDBManager.CloneRecord(n"Items.PreemTriggerSlot02Element", t"Items.IconicWeaponModElement");
        TweakDBManager.SetFlat(t"Items.PreemTriggerSlot02Element.slot", t"AttachmentSlots.PreemTriggerMod02");
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerSlot02Element");

        TweakDBManager.CloneRecord(n"Items.PreemMagazineSlot01Element", t"Items.IconicWeaponModElement");
        TweakDBManager.SetFlat(t"Items.PreemMagazineSlot01Element.slot", t"AttachmentSlots.PreemMagazineMod01");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineSlot01Element");

        TweakDBManager.CloneRecord(n"Items.PreemMagazineSlot02Element", t"Items.IconicWeaponModElement");
        TweakDBManager.SetFlat(t"Items.PreemMagazineSlot02Element.slot", t"AttachmentSlots.PreemMagazineMod02");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineSlot02Element");

    }

    protected cb func OnApply() -> Void {
        this.CreatePreemSlots();
        this.CreatePreemWeaponBlueprintElements();

        let weaponsList = TweakDBInterface.GetRecords(n"WeaponItem");

    
        for record in weaponsList {
            this.GiveAllWeaponsPreemSlots(record);
            this.GiveAllRangedWeaponsEvolutions(record);
        }

    }

}