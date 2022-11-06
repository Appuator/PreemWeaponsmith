module PreemCrafting.Tweaking

public class PreemModCreation extends ScriptableTweak {

    protected func CreatePreemMods() -> Void {
        
        let attachmentSlotsBarrel: array<TweakDBID>;
        ArrayPush(attachmentSlotsBarrel,t"AttachmentSlots.PreemBarrelMod01");
        ArrayPush(attachmentSlotsBarrel,t"AttachmentSlots.PreemBarrelMod02");

        let attachmentSlotsTrigger: array<TweakDBID>;
        ArrayPush(attachmentSlotsTrigger,t"AttachmentSlots.PreemTriggerMod01");
        ArrayPush(attachmentSlotsTrigger,t"AttachmentSlots.PreemTriggerMod02");

        let attachmentSlotsMagazine: array<TweakDBID>;
        ArrayPush(attachmentSlotsMagazine,t"AttachmentSlots.PreemMagazineMod01");
        ArrayPush(attachmentSlotsMagazine,t"AttachmentSlots.PreemMagazineMod02");

        //Create Mod PreemBarrelMod01
        let statList1: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelMod01", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelMod01.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelMod01.statModifiers", statList1);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelMod01");

        //Create Mod PreemBarrelMod02
        let statList2: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelMod02", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelMod02.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelMod02.statModifiers", statList2);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelMod02");

        //Create Mod PreemBarrelModExtraBarrel
        let statList9: array<TweakDBID>;
        //CreateShotgunStat Record
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline1.statType", t"BaseStats.NumShotsToFire");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline1.value", 2.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline2", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline2.statType", t"BaseStats.CycleTime");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline2.value", 1.3);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline3", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline3.statType", t"BaseStats.ProjectilesPerShot");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline3.value", 2.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline3");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline4", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline4.statType", t"BaseStats.Recoil");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline4.value", 2.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline4");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline5", t"AttackModifier.TechWeaponDPSReduction");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline5.value", 1.4);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline5");
        ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline1");
        ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline2");
        ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline3");
        ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline4");
        ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline5");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel.statModifiers", statList9);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel");

        //Create Mod PreemBarrelModRecoilX
        let statList10: array<TweakDBID>;
        //TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoil_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoil_inline2", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModRecoil_inline2.statType", t"BaseStats.Recoil");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModRecoil_inline2.value", 0.4);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModRecoil_inline2");
        //ArrayPush(statList10,t"Items.PreemBarrelModRecoil_inline1");
        ArrayPush(statList10,t"Items.PreemBarrelModRecoil_inline2");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoil", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModRecoil.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModRecoil.statModifiers", statList10);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModRecoil");

        //Create Mod PreemBarrelModRecoilY
        let statList21: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoilY_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoilY_inline2", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModRecoilY_inline2.statType", t"BaseStats.RecoilEnableLinearXADS");
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModRecoilY_inline2");
        ArrayPush(statList21,t"Items.PreemBarrelModRecoilY_inline1");
        ArrayPush(statList21,t"Items.PreemBarrelModRecoilY_inline2");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoilY", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModRecoilY.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModRecoilY.statModifiers", statList21);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModRecoilY");

        //Create Mod PreemBarrelModSmart
        let statList16: array<TweakDBID>;
        let smartGunProjectileList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Sidewinder_SmartGun_Stats.statModifiers"));
        let smartGunSmartLinkList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Sidewinder_SmartGun_Projectile_Stats.statModifiers"));
        let smartGunList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Sidewinder_SmartGun_SmartLink_Stats.statModifiers"));
        for stat in smartGunProjectileList{
            ArrayPush(statList16,stat);
        }
        for stat in smartGunSmartLinkList{
            ArrayPush(statList16,stat);
        }
        for stat in smartGunList{
            ArrayPush(statList16,stat);
        }
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmart_inline1", t"Ability.CanSmartShoot_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmart_inline2", t"Ability.CanSmartShoot_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmart_inline2.statType", t"BaseStats.HasSmartLink");
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmart_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmart_inline3", t"AttackModifier.SmartWeaponDPSReduction");
        ArrayPush(statList16,t"Items.PreemBarrelModSmart_inline1");
        ArrayPush(statList16,t"Items.PreemBarrelModSmart_inline2");
        ArrayPush(statList16,t"Items.PreemBarrelModSmart_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmart", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmart.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmart.statModifiers", statList16);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmart");

        //Create Mod PreemBarrelModTech
        let statList18: array<TweakDBID>;
        let techGunList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Tech_Stats.statModifiers"));
        let techEngineerList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Proficiencies.EngineeringWeaponPassives.statModifiers"));
        let techMultList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Tech_Revolver_Mult_Stats.statModifiers"));
        for stat in techGunList{
            ArrayPush(statList18,stat);
        }
        for stat in techEngineerList{
            ArrayPush(statList18,stat);
        }
        for stat in techMultList{
            ArrayPush(statList18,stat);
        }
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTech_inline1", t"AttackModifier.TechWeaponDPSReduction");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTech_inline2", t"Ability.CanCharge_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTech_inline3", t"Ability.CanChargedShoot_inline2");
        ArrayPush(statList18,t"Items.PreemBarrelModTech_inline1");
        ArrayPush(statList18,t"Items.PreemBarrelModTech_inline2");
        ArrayPush(statList18,t"Items.PreemBarrelModTech_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTech", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTech.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTech.statModifiers", statList18);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModTech");

        //Create Mod PreemBarrelModTurbo
        let statList20: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTurbo_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTurbo_inline1.statType", t"BaseStats.CycleTime");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTurbo_inline1.value", 0.7);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModTurbo_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTurbo_inline2", t"AttackModifier.TechWeaponDPSReduction");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTurbo_inline2.value", 1.3);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModTurbo_inline2");
        ArrayPush(statList20,t"Items.PreemBarrelModTurbo_inline1");
        ArrayPush(statList20,t"Items.PreemBarrelModTurbo_inline2");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTurbo", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTurbo.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTurbo.statModifiers", statList20);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModTurbo");


        //Create Mod PreemBarrelModAtomizer
        let statList21: array<TweakDBID>;
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModAtomizer_inline1", t"Items.SimpleWeaponMod11_inline2");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer_inline1.statType", t"BaseStats.CycleTime");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer_inline1.value", 0.7);
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModAtomizer_inline1");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModAtomizer_inline1", t"AttackModifier.TechWeaponDPSReduction");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer_inline1.value", 1.3);
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModAtomizer_inline1");
        //ArrayPush(statList21,t"Items.PreemBarrelModAtomizer_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModAtomizer", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer.statModifiers", statList21);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModAtomizer");

        //Create Mod TestMod1
        let statList3: array<TweakDBID>;
        //CreateShotgunStat Record
        TweakDBManager.CloneRecord(n"Items.TestMod1_inline1", t"BaseStats.ProjectilesPerShotModifier");
        TweakDBManager.SetFlat(t"Items.TestMod1_inline1.value", 5.0);
        TweakDBManager.UpdateRecord(t"Items.TestMod1_inline1");
        ArrayPush(statList3,t"Items.TestMod1_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.TestMod1", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.TestMod1.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.TestMod1.statModifiers", statList3);
        TweakDBManager.UpdateRecord(t"Items.TestMod1");

        //Create Mod PreemTriggerModSemiAuto
        let statList4: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModSemiAuto", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModSemiAuto.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModSemiAuto.statModifiers", statList4);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModSemiAuto");

        //Create Mod PreemTriggerModFullAuto
        let statList5: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModFullAuto", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModFullAuto.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModFullAuto.statModifiers", statList5);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModFullAuto");

        //Create Mod PreemTriggerModBurst
        let statList6: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModBurst_inline1", t"BaseStats.NumShotsInBurstModifier");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModBurst_inline1.value", 3.0);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModBurst_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModBurst_inline2", t"BaseStats.CycleTime_BurstModifier");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModBurst_inline2.value", 0.08);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModBurst_inline2");
        ArrayPush(statList6,t"Items.PreemTriggerModBurst_inline1");
        ArrayPush(statList6,t"Items.PreemTriggerModBurst_inline2");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModBurst", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModBurst.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModBurst.statModifiers", statList6);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModBurst");

        //Create Mod PreemTriggerModCharge
        let statList19: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge_inline1", t"Items.Base_Quasar_Technical_Stats_inline12");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModCharge_inline1.value", .75);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge_inline2", t"Items.Base_Quasar_Technical_Stats_inline11");
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge_inline3", t"Items.Base_Quasar_Technical_Stats_inline10");
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge_inline3");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge_inline4", t"Items.Base_Quasar_Technical_Stats_inline9");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModCharge_inline4.value", 1.5);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge_inline4");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge_inline5", t"Items.Base_Quasar_Technical_Stats_inline8");
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge_inline5");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge_inline6", t"Items.Base_Quasar_Technical_Stats_inline7");
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge_inline6");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge_inline7", t"Items.Base_Quasar_Technical_Stats_inline6");
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge_inline7");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        ArrayPush(statList19,t"Items.PreemTriggerModCharge_inline1");
        ArrayPush(statList19,t"Items.PreemTriggerModCharge_inline2");
        ArrayPush(statList19,t"Items.PreemTriggerModCharge_inline3");
        ArrayPush(statList19,t"Items.PreemTriggerModCharge_inline4");
        ArrayPush(statList19,t"Items.PreemTriggerModCharge_inline5");
        ArrayPush(statList19,t"Items.PreemTriggerModCharge_inline6");
        ArrayPush(statList19,t"Items.PreemTriggerModCharge_inline7");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModCharge.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModCharge.statModifiers", statList19);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge");

        //Create Mod PreemTriggerModChargeFullAuto
        let statList22: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModChargeFullAuto_inline1", t"Items.Base_Quasar_Constant_Stats_inline8");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        ArrayPush(statList22,t"Items.PreemTriggerModChargeFullAuto_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModChargeFullAuto", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModChargeFullAuto.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModChargeFullAuto.statModifiers", statList22);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModChargeFullAuto");

        //Create Mod PreemTriggerModInstaBurst
        let statList23: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModInstaBurst_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModInstaBurst_inline1.statType", t"BaseStats.CycleTime_Burst");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModInstaBurst_inline1.value", 0.0);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModInstaBurst_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        ArrayPush(statList23,t"Items.PreemTriggerModInstaBurst_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModInstaBurst", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModInstaBurst.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModInstaBurst.statModifiers", statList23);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModInstaBurst");

        //Create Mod PreemTriggerModUltraAction
        let statList24: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModUltraAction_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModUltraAction_inline1.statType", t"BaseStats.CycleTime");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModUltraAction_inline1.value", 0.2);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModUltraAction_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        ArrayPush(statList24,t"Items.PreemTriggerModUltraAction_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModUltraAction", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModUltraAction.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModUltraAction.statModifiers", statList24);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModUltraAction");

        //Create Mod PreemMagazineMod01
        let statList7: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineMod01", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineMod01.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineMod01.statModifiers", statList7);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineMod01");

        //Create Mod PreemMagazineMod02
        let statList8: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineMod02", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineMod02.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineMod02.statModifiers", statList8);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineMod02");

        //Create Mod PreemMagazineModThermalRounds
        let statsList11: array<TweakDBID>;
        let thermalMinMaxStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Melee_Weapon_Damage_Type_Thermal_Min_Max.statModifiers"));
        let thermalStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Weapon_Damage_Type_Thermal.statModifiers"));
        for stat in thermalMinMaxStatList{
            ArrayPush(statsList11,stat);
        }
        for stat in thermalStatList{
            ArrayPush(statsList11,stat);
        }
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds_inline1", t"Ability.DealsThermalDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds_inline2", t"Ability.CanCauseBurn_inline4");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds_inline2.value", 25.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds_inline3", t"Ability.CanCauseBurn_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds_inline3.value", 1.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds_inline3");
        ArrayPush(statsList11,t"Items.PreemMagazineModThermalRounds_inline1");
        ArrayPush(statsList11,t"Items.PreemMagazineModThermalRounds_inline2");
        ArrayPush(statsList11,t"Items.PreemMagazineModThermalRounds_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds.statModifiers", statsList11);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds");

        //Create Mod PreemMagazineModElectricalRounds
        let statsList12: array<TweakDBID>;
        let electricMinMaxStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Melee_Weapon_Damage_Type_Electric_Min_Max.statModifiers"));
        let electricStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Weapon_Damage_Type_Electric.statModifiers"));
        for stat in electricMinMaxStatList{
            ArrayPush(statsList12,stat);
        }
        for stat in electricStatList{
            ArrayPush(statsList12,stat);
        }
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModElectricalRounds_inline1", t"Ability.DealsElectricDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModElectricalRounds_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModElectricalRounds_inline2", t"Ability.CanCauseElectrocution_inline4");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds_inline2.value", 25.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModElectricalRounds_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModElectricalRounds_inline3", t"Ability.CanCauseElectrocution_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds_inline3.value", 1.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModElectricalRounds_inline3");
        ArrayPush(statsList12,t"Items.PreemMagazineModElectricalRounds_inline1");
        ArrayPush(statsList12,t"Items.PreemMagazineModElectricalRounds_inline2");
        ArrayPush(statsList12,t"Items.PreemMagazineModElectricalRounds_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModElectricalRounds", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds.statModifiers", statsList12);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModElectricalRounds");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModElectricalRounds", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds.statModifiers", statsList12);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModElectricalRounds");

        //Create Mod PreemMagazineModChemicalRounds
        let statsList13: array<TweakDBID>;
        let chemicalMinMaxStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Melee_Weapon_Damage_Type_Chemical_Min_Max.statModifiers"));
        let chemicalStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Weapon_Damage_Type_Chemical.statModifiers"));
        for stat in chemicalMinMaxStatList{
            ArrayPush(statsList13,stat);
        }
        for stat in chemicalStatList{
            ArrayPush(statsList13,stat);
        }
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModChemicalRounds_inline1", t"Ability.DealsChemicalDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModChemicalRounds_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModChemicalRounds_inline2", t"Ability.CanCausePoison_inline4");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModChemicalRounds_inline2.value", 25.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModChemicalRounds_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModChemicalRounds_inline3", t"Ability.CanCausePoison_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModChemicalRounds_inline3.value", 1.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModChemicalRounds_inline3");
        ArrayPush(statsList13,t"Items.PreemMagazineModChemicalRounds_inline1");
        ArrayPush(statsList13,t"Items.PreemMagazineModChemicalRounds_inline2");
        ArrayPush(statsList13,t"Items.PreemMagazineModChemicalRounds_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModChemicalRounds", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModChemicalRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModChemicalRounds.statModifiers", statsList13);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModChemicalRounds");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModChemicalRounds", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModChemicalRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModChemicalRounds.statModifiers", statsList13);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModChemicalRounds");

        //Create Mod PreemMagazineModExtendedMag
        let statsList14: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModExtendedMag_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModExtendedMag_inline1.value", 1.5);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModExtendedMag_inline1.statType", t"BaseStats.MagazineCapacity");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModExtendedMag_inline1");
        ArrayPush(statsList14,t"Items.PreemMagazineModExtendedMag_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModExtendedMag", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModExtendedMag.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModExtendedMag.statModifiers", statsList14);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModExtendedMag");

        //Create Mod PreemMagazineModBleedRounds
        let statsList15: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModBleedRounds_inline1", t"Ability.DealsChemicalDamage_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline1.statType", t"BaseStats.DealsPhysicalDamage");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModBleedRounds_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModBleedRounds_inline2", t"Ability.CanCausePoison_inline4");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline2.value", 25.0);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline2.refStat", t"BaseStats.PhysicalDamage");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline2.statType", t"BaseStats.BleedingApplicationRate");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModBleedRounds_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModBleedRounds_inline3", t"Ability.CanCausePoison_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline3.value", 1.0);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline3.statType", t"BaseStats.PhysicalDamage");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModBleedRounds_inline3");
        ArrayPush(statsList15,t"Items.PreemMagazineModBleedRounds_inline1");
        ArrayPush(statsList15,t"Items.PreemMagazineModBleedRounds_inline2");
        ArrayPush(statsList15,t"Items.PreemMagazineModBleedRounds_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModBleedRounds", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds.statModifiers", statsList15);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModBleedRounds");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModBleedRounds", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds.statModifiers", statsList15);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModBleedRounds");
        

        //Create Mod PreemMagazineMod01
        let statsList16: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineMod01", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineMod01.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineMod01.statModifiers", statsList16);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineMod01");

        //Create Mod PreemMagazineMod01
        let statsList17: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineMod01", t"Items.SimpleWeaponModBase");
        TweakDBManager.SetFlat(t"Items.PreemMagazineMod01.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineMod01.statModifiers", statsList17);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineMod01");
        
    }

    // protected func CreatePreemAttacks() -> Void {

    //     TweakDBManager.CloneRecord(n"Attacks.PreemAttackFlameThrowerShot", t"Attacks.PlasmaShotDefault");
    //     TweakDBManager.SetFlat(t"Attacks.PreemAttackFlameThrowerShot.NPCAttack", t"Attacks.PlasmaBeam");
    //     TweakDBManager.SetFlat(t"Attacks.PreemAttackFlameThrowerShot.playerAttack", t"Attacks.PlasmaBeam");
    //     TweakDBManager.UpdateRecord(t"Attacks.PreemAttackFlameThrowerShot");

    //     TweakDBManager.CloneRecord(n"Attacks.PreemAttackFlamethrowerPackage", t"Attacks.PlasmaProjectilePackage");
    //     TweakDBManager.SetFlat(t"Attacks.PreemAttackFlamethrowerPackage.defaultFire", t"Attacks.PreemAttackFlameThrowerShot");
    //     TweakDBManager.UpdateRecord(t"Attacks.PreemAttackFlamethrowerPackage");
    // }

    protected cb func OnApply() -> Void {

        this.CreatePreemMods();
        //this.CreatePreemAttacks();
    }

}