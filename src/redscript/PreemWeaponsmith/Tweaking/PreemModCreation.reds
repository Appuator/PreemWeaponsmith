public class PreemModCreation extends ScriptableTweak {

    protected func CreatePreemMods() -> Void {
        
        let attachmentSlotsBarrel: array<TweakDBID>;
        ArrayPush(attachmentSlotsBarrel,t"AttachmentSlots.PreemBarrelMod01");
        ArrayPush(attachmentSlotsBarrel,t"AttachmentSlots.PreemBarrelMod02");

        let attachmentSlotsMuzzle: array<TweakDBID>;
        ArrayPush(attachmentSlotsMuzzle,t"AttachmentSlots.PowerModule");
        //ArrayPush(attachmentSlotsMuzzle,t"AttachmentSlots.PowerModule2");

        let attachmentSlotsTrigger: array<TweakDBID>;
        ArrayPush(attachmentSlotsTrigger,t"AttachmentSlots.PreemTriggerMod01");
        ArrayPush(attachmentSlotsTrigger,t"AttachmentSlots.PreemTriggerMod02");

        let attachmentSlotsMagazine: array<TweakDBID>;
        ArrayPush(attachmentSlotsMagazine,t"AttachmentSlots.PreemMagazineMod01");
        ArrayPush(attachmentSlotsMagazine,t"AttachmentSlots.PreemMagazineMod02");

        let attachmentSlotsBlade: array<TweakDBID>;
        ArrayPush(attachmentSlotsBlade,t"AttachmentSlots.PreemBladeMod01");
        ArrayPush(attachmentSlotsBlade,t"AttachmentSlots.PreemBladeMod02");

        let attachmentSlotsHandle: array<TweakDBID>;
        ArrayPush(attachmentSlotsHandle,t"AttachmentSlots.PreemHandleMod01");
        ArrayPush(attachmentSlotsHandle,t"AttachmentSlots.PreemHandleMod02");

        //Create Mod PreemBarrelModExtraBarrel
        let statList9: array<TweakDBID>;
        //CreateShotgunStat Record
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline1.statType", t"BaseStats.NumShotsToFire");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline1.value", 2.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline3", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline3.statType", t"BaseStats.ProjectilesPerShot");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline3.value", 2.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline3");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline4", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline4.statType", t"BaseStats.Recoil");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline4.value", 2.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline4");
        ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline1");
        ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline3");
        ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline4");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel.statModifiers", statList9);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel");

        //Create Mod PreemBarrelModExtraBarrel
        // let statList9: array<TweakDBID>;
        // //CreateShotgunStat Record
        // //TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline1", t"Items.SimpleWeaponMod11_inline2");
        // //TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline1.statType", t"BaseStats.NumShotsToFire");
        // //TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline1.value", 2.0);
        // //TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline1");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline2", t"Items.FaceClothingBase_inline9"); //additive
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline2.refStat", t"BaseStats.ProjectilesPerShot");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline2.statType", t"BaseStats.ProjectilesPerShot");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline2.value", 2.0);
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline2");
        // // TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline3", t"Items.FaceClothingBase_inline11");//multiplier
        // // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline3.refStat", t"BaseStats.ProjectilesPerShotBase");
        // // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline3.statType", t"BaseStats.ProjectilesPerShot");
        // // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline3.value", 2.0);
        // // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline3");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline4", t"Items.Base_Grad_Technical_Stats_inline6");//additiveMultiplier
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline4.refStat", t"BaseStats.ProjectilesPerShotBase");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline4.statType", t"BaseStats.ProjectilesPerShot");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline4.value", 2.0);
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel_inline4.refObject", "Self");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel_inline4");
        // //ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline1"); 
        // //ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline2");
        // //ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline3");
        // ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline4");
        // //ArrayPush(statList9,t"Items.PreemBarrelModExtraBarrel_inline5");
        // //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel", t"Items.SimpleWeaponMod01");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel.placementSlots", attachmentSlotsBarrel);
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModExtraBarrel.statModifiers", statList9);
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModExtraBarrel");

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
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoil", t"Items.SimpleWeaponMod01");
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
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoilY", t"Items.SimpleWeaponMod01");
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
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmart_inline2", t"Ability.CanSmartShoot_inline2");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModSmart_inline2.statType", t"BaseStats.HasSmartLink");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmart_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmart_inline3", t"AttackModifier.SmartWeaponDPSReduction");
        ArrayPush(statList16,t"Items.PreemBarrelModSmart_inline1");
        ArrayPush(statList16,t"Items.PreemBarrelModSmart_inline2");
        //ArrayPush(statList16,t"Items.PreemBarrelModSmart_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmart", t"Items.SimpleWeaponMod01");
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
        // for stat in techMultList{
        //     ArrayPush(statList18,stat);
        // }
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTech_inline1", t"AttackModifier.TechWeaponDPSReduction");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTech_inline2", t"Ability.CanCharge_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTech_inline3", t"Ability.CanChargedShoot_inline2");
        ArrayPush(statList18,t"Items.PreemBarrelModTech_inline1");
        ArrayPush(statList18,t"Items.PreemBarrelModTech_inline2");
        ArrayPush(statList18,t"Items.PreemBarrelModTech_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTech", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTech.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTech.statModifiers", statList18);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModTech");

        //Create Mod PreemBarrelModTurbo
        let statList20: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTurbo_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTurbo_inline1.statType", t"BaseStats.CycleTime");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModTurbo_inline1.value", 0.8);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModTurbo_inline1");
        ArrayPush(statList20,t"Items.PreemBarrelModTurbo_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModTurbo", t"Items.SimpleWeaponMod01");
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
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModAtomizer", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer.statModifiers", statList21);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModAtomizer");

        //Create Mod PreemBarrelModPower
        let statList28: array<TweakDBID>;
        let powerMainList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Power_Assault_Rifle_Stats.statModifiers"));
        let powerRPGlist: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Power_Assault_Rifle_RPG_Randomized_Stats.statModifiers"));
        for stat in powerMainList{
            ArrayPush(statList28,stat);
        }
        for stat in powerRPGlist{
            ArrayPush(statList28,stat);
        }
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModPower_inline1", t"AttackModifier.TechWeaponDPSReduction");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModPower_inline2", t"Ability.CanCharge_inline2");
        // ArrayPush(statList28,t"Items.PreemBarrelModPower_inline1");
        // ArrayPush(statList28,t"Items.PreemBarrelModPower_inline2");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModPower", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModPower.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModPower.statModifiers", statList28);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModPower");

        // //Create Mod PreemBarrelModSilencer
        // let statList29: array<TweakDBID>;
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline1", t"Items.w_silencer_01_inline0");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline1");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline2", t"Items.w_silencer_01_inline1");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline2");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline3", t"Items.SilencerBase_inline0");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline3");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline4", t"Items.SilencerBase_inline1");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline4");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline5", t"Items.SilencerBase_inline2");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline5");
        // ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline1");
        // ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline2");
        // ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline3");
        // ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline4");
        // ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline5");
        // //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer", t"Items.SilencerBase");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModSilencer.placementSlots", attachmentSlotsBarrel);
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModSilencer.statModifiers", statList29);
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer");

        //Create Mod PreemBarrelModSilencer
        let statList29: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline1", t"Items.w_silencer_01_inline0");
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline2", t"Items.w_silencer_01_inline1");
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline3", t"Items.SilencerBase_inline0");
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline3");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline4", t"Items.SilencerBase_inline1");
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline4");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline5", t"Items.SilencerBase_inline2");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline5");
        ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline1");
        ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline2");
        ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline3");
        ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline4");
        //ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline5");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer", t"Items.SilencerBase");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSilencer.placementSlots", attachmentSlotsMuzzle);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSilencer.statModifiers", statList29);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer");

        //Create Mod PreemBarrelModSmartMultiTarget
        let statList30: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartMultiTarget_inline1", t"Items.Base_Sidewinder_Divided_SmartGun_Stats_inline10");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartMultiTarget_inline1.value", 3.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartMultiTarget_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartMultiTarget_inline2", t"Items.Base_Sidewinder_Divided_SmartGun_Stats_inline11");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartMultiTarget_inline2.value", 5.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartMultiTarget_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartMultiTarget_inline3", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartMultiTarget_inline3.statType", t"BaseStats.SmartGunTrackAllBodyparts");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartMultiTarget_inline3.value", 0.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartMultiTarget_inline3");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartMultiTarget_inline4", t"Items.Base_Sidewinder_Divided_SmartGun_Stats_inline14");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartMultiTarget_inline4.value", 10.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartMultiTarget_inline4");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartMultiTarget_inline5", t"Items.Base_Sidewinder_Divided_SmartGun_Stats_inline15");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartMultiTarget_inline5.value", 0.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartMultiTarget_inline5");
        ArrayPush(statList30,t"Items.PreemBarrelModSmartMultiTarget_inline1");
        ArrayPush(statList30,t"Items.PreemBarrelModSmartMultiTarget_inline2");
        ArrayPush(statList30,t"Items.PreemBarrelModSmartMultiTarget_inline3");
        ArrayPush(statList30,t"Items.PreemBarrelModSmartMultiTarget_inline4");
        ArrayPush(statList30,t"Items.PreemBarrelModSmartMultiTarget_inline5");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartMultiTarget", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartMultiTarget.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartMultiTarget.statModifiers", statList30);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartMultiTarget");

        //Create Mod PreemBarrelModSmartRangeTarget
        let statList31: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline1.statType", t"BaseStats.SmartGunTargetAcquisitionRange");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline1.value", 1.5);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline2", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline2.statType", t"BaseStats.SmartGunHipLockingAnglePitch");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline2.value", 0.25);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline3", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline3.statType", t"BaseStats.SmartGunHipLockingAngleYaw");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline3.value", 0.25);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline3");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline4", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline4.statType", t"BaseStats.SmartGunAdsLockingAnglePitch");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline4.value", 0.25);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline4");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline5", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline5.statType", t"BaseStats.SmartGunAdsLockingAngleYaw");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline5.value", 0.25);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline5");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline6", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline6.statType", t"BaseStats.SmartGunHipTargetableAnglePitch");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline6.value", 0.25);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline6");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline7", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline7.statType", t"BaseStats.SmartGunHipTargetableAngleYaw");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline7.value", 0.25);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline7");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline8", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline8.statType", t"BaseStats.SmartGunAdsTargetableAnglePitch");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline8.value", 0.25);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline8");
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget_inline9", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline9.statType", t"BaseStats.SmartGunAdsTargetableAngleYaw");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget_inline9.value", 0.25);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget_inline9");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline1");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline2");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline3");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline4");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline5");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline6");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline7");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline8");
        ArrayPush(statList31,t"Items.PreemBarrelModSmartRangeTarget_inline9");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBarrelModSmartRangeTarget", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.PreemBarrelModSmartRangeTarget.statModifiers", statList31);
        TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSmartRangeTarget");

        //Create Mod TestMod1
        let statList3: array<TweakDBID>;
        //CreateShotgunStat Record
        TweakDBManager.CloneRecord(n"Items.TestMod1_inline1", t"BaseStats.ProjectilesPerShotModifier");
        TweakDBManager.SetFlat(t"Items.TestMod1_inline1.value", 5.0);
        TweakDBManager.UpdateRecord(t"Items.TestMod1_inline1");
        ArrayPush(statList3,t"Items.TestMod1_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.TestMod1", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.TestMod1.placementSlots", attachmentSlotsBarrel);
        TweakDBManager.SetFlat(t"Items.TestMod1.statModifiers", statList3);
        TweakDBManager.UpdateRecord(t"Items.TestMod1");

        //Create Mod PreemTriggerModSemiAuto
        let statList4: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModSemiAuto_inline1", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModSemiAuto_inline1.statType", t"BaseStats.NumShotsInBurst");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModSemiAuto_inline1.value", 0.0);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModSemiAuto_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModSemiAuto_inline2", t"Items.SimpleWeaponMod11_inline2");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModSemiAuto_inline2.statType", t"BaseStats.NumShotsInBurstSecondary");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModSemiAuto_inline2.value", 0.0);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModSemiAuto_inline2");
        ArrayPush(statList4, t"Items.PreemTriggerModSemiAuto_inline1");
        ArrayPush(statList4, t"Items.PreemTriggerModSemiAuto_inline2");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModSemiAuto", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModSemiAuto.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModSemiAuto.statModifiers", statList4);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModSemiAuto");

        //Create Mod PreemTriggerModFullAuto
        let statList5: array<TweakDBID>;
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModFullAuto", t"Items.SimpleWeaponMod01");
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
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModBurst", t"Items.SimpleWeaponMod01");
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
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModCharge", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModCharge.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModCharge.statModifiers", statList19);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModCharge");

        //Create Mod PreemTriggerModChargeFullAuto
        let statList22: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModChargeFullAuto_inline1", t"Items.Base_Quasar_Constant_Stats_inline8");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        ArrayPush(statList22,t"Items.PreemTriggerModChargeFullAuto_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModChargeFullAuto", t"Items.SimpleWeaponMod01");
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
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModInstaBurst", t"Items.SimpleWeaponMod01");
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
        TweakDBManager.CloneRecord(n"Items.PreemTriggerModUltraAction", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemTriggerModUltraAction.placementSlots", attachmentSlotsTrigger);
        TweakDBManager.SetFlat(t"Items.PreemTriggerModUltraAction.statModifiers", statList24);
        TweakDBManager.UpdateRecord(t"Items.PreemTriggerModUltraAction");

        // //Create Mod PreemMagazineModThermalRounds
        // let statsList11: array<TweakDBID>;
        // let thermalMinMaxStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Melee_Weapon_Damage_Type_Thermal_Min_Max.statModifiers"));
        // let thermalStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Weapon_Damage_Type_Thermal.statModifiers"));
        // for stat in thermalMinMaxStatList{
        //     ArrayPush(statsList11,stat);
        // }
        // for stat in thermalStatList{
        //     ArrayPush(statsList11,stat);
        // }
        // TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds_inline1", t"Ability.DealsThermalDamage_inline3");
        // TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds_inline1");
        // TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds_inline2", t"Ability.CanCauseBurn_inline4");
        // TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds_inline2.value", 25.0);
        // TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds_inline2");
        // TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds_inline3", t"Ability.CanCauseBurn_inline3");
        // TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds_inline3.value", 1.0);
        // TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds_inline3");
        // ArrayPush(statsList11,t"Items.PreemMagazineModThermalRounds_inline1");
        // ArrayPush(statsList11,t"Items.PreemMagazineModThermalRounds_inline2");
        // ArrayPush(statsList11,t"Items.PreemMagazineModThermalRounds_inline3");
        // //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        // TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds", t"Items.SimpleWeaponMod01");
        // TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds.placementSlots", attachmentSlotsMagazine);
        // TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds.statModifiers", statsList11);
        // TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds");

        //Create Mod PreemMagazineModThermalRounds
        let statsList11: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds_inline1", t"Ability.DealsThermalDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds_inline3", t"Ability.CanCauseBurn_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds_inline3.statType", t"BaseStats.BurningApplicationRate");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds_inline3.value", 15.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds_inline3");
        ArrayPush(statsList11,t"Items.PreemMagazineModThermalRounds_inline1");
        ArrayPush(statsList11,t"Items.PreemMagazineModThermalRounds_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModThermalRounds", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModThermalRounds.statModifiers", statsList11);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModThermalRounds");

        //Create Mod PreemMagazineModElectricalRounds
        let statsList12: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModElectricalRounds_inline1", t"Ability.DealsElectricDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModElectricalRounds_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModElectricalRounds_inline3", t"Ability.CanCauseElectrocution_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds_inline3.statType", t"BaseStats.ElectrocutedApplicationRate");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds_inline3.value", 15.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModElectricalRounds_inline3");
        ArrayPush(statsList12,t"Items.PreemMagazineModElectricalRounds_inline1");
        ArrayPush(statsList12,t"Items.PreemMagazineModElectricalRounds_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModElectricalRounds", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModElectricalRounds.statModifiers", statsList12);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModElectricalRounds");

        //Create Mod PreemMagazineModChemicalRounds
        let statsList13: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModChemicalRounds_inline1", t"Ability.DealsChemicalDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModChemicalRounds_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModChemicalRounds_inline3", t"Ability.CanCausePoison_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModChemicalRounds_inline3.statType", t"BaseStats.PoisonedApplicationRate");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModChemicalRounds_inline3.value", 15.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModChemicalRounds_inline3");
        ArrayPush(statsList13,t"Items.PreemMagazineModChemicalRounds_inline1");
        ArrayPush(statsList13,t"Items.PreemMagazineModChemicalRounds_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModChemicalRounds", t"Items.SimpleWeaponMod01");
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
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModExtendedMag", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModExtendedMag.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModExtendedMag.statModifiers", statsList14);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModExtendedMag");

        //Create Mod PreemMagazineModBleedRounds
        let statsList15: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModBleedRounds_inline1", t"Ability.DealsChemicalDamage_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline1.statType", t"BaseStats.DealsPhysicalDamage");
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModBleedRounds_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModBleedRounds_inline3", t"Ability.CanCausePoison_inline3");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline3.statType", t"BaseStats.BleedingApplicationRate");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds_inline3.value", 15.0);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModBleedRounds_inline3");
        ArrayPush(statsList15,t"Items.PreemMagazineModBleedRounds_inline1");
        ArrayPush(statsList15,t"Items.PreemMagazineModBleedRounds_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemMagazineModBleedRounds", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds.placementSlots", attachmentSlotsMagazine);
        TweakDBManager.SetFlat(t"Items.PreemMagazineModBleedRounds.statModifiers", statsList15);
        TweakDBManager.UpdateRecord(t"Items.PreemMagazineModBleedRounds");

        //Create Mod PreemBladeModChemBlade
        // let statsList23: array<TweakDBID>;
        // let chemicalMinMaxStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Melee_Weapon_Damage_Type_Chemical_Min_Max.statModifiers"));
        // let chemicalStatList: array<TweakDBID> = FromVariant(TweakDBInterface.GetFlat(t"Items.Base_Weapon_Damage_Type_Chemical.statModifiers"));
        // for stat in chemicalMinMaxStatList{
        //     ArrayPush(statsList23,stat);
        // }
        // for stat in chemicalStatList{
        //     ArrayPush(statsList23,stat);
        // }
        // TweakDBManager.CloneRecord(n"Items.PreemBladeModChemBlade_inline1", t"Ability.DealsChemicalDamage_inline3");
        // TweakDBManager.UpdateRecord(t"Items.PreemBladeModChemBlade_inline1");
        // TweakDBManager.CloneRecord(n"Items.PreemBladeModChemBlade_inline2", t"Ability.CanCausePoison_inline4");
        // TweakDBManager.SetFlat(t"Items.PreemBladeModChemBlade_inline2.value", 25.0);
        // TweakDBManager.UpdateRecord(t"Items.PreemBladeModChemBlade_inline2");
        // TweakDBManager.CloneRecord(n"Items.PreemBladeModChemBlade_inline3", t"Ability.CanCausePoison_inline3");
        // TweakDBManager.SetFlat(t"Items.PreemBladeModChemBlade_inline3.value", 1.0);
        // TweakDBManager.UpdateRecord(t"Items.PreemBladeModChemBlade_inline3");
        // ArrayPush(statsList23,t"Items.PreemBladeModChemBlade_inline1");
        // ArrayPush(statsList23,t"Items.PreemBladeModChemBlade_inline2");
        // ArrayPush(statsList23,t"Items.PreemBladeModChemBlade_inline3");
        // //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        // TweakDBManager.CloneRecord(n"Items.PreemBladeModChemBlade", t"Items.SimpleWeaponMod01");
        // TweakDBManager.SetFlat(t"Items.PreemBladeModChemBlade.placementSlots", attachmentSlotsBlade);
        // TweakDBManager.SetFlat(t"Items.PreemBladeModChemBlade.statModifiers", statsList23);
        // TweakDBManager.UpdateRecord(t"Items.PreemBladeModChemBlade");

        let statsList23: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBladeModChemBlade_inline1", t"Ability.DealsChemicalDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModChemBlade_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBladeModChemBlade_inline3", t"Ability.CanCausePoison_inline3");
        TweakDBManager.SetFlat(t"Items.PreemBladeModChemBlade_inline3.statType", t"BaseStats.PoisonedApplicationRate");
        TweakDBManager.SetFlat(t"Items.PreemBladeModChemBlade_inline3.value", 20.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModChemBlade_inline3");
        ArrayPush(statsList23,t"Items.PreemBladeModChemBlade_inline1");
        ArrayPush(statsList23,t"Items.PreemBladeModChemBlade_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBladeModChemBlade", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBladeModChemBlade.placementSlots", attachmentSlotsBlade);
        TweakDBManager.SetFlat(t"Items.PreemBladeModChemBlade.statModifiers", statsList23);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModChemBlade");

        //Create Mod PreemBladeModShockBlade
        let statsList24: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBladeModShockBlade_inline1", t"Ability.DealsElectricDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModShockBlade_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBladeModShockBlade_inline3", t"Ability.CanCauseElectrocution_inline3");
        TweakDBManager.SetFlat(t"Items.PreemBladeModShockBlade_inline3.statType", t"BaseStats.ElectrocutedApplicationRate");
        TweakDBManager.SetFlat(t"Items.PreemBladeModShockBlade_inline3.value", 20.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModShockBlade_inline3");
        ArrayPush(statsList24,t"Items.PreemBladeModShockBlade_inline1");
        ArrayPush(statsList24,t"Items.PreemBladeModShockBlade_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBladeModShockBlade", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBladeModShockBlade.placementSlots", attachmentSlotsBlade);
        TweakDBManager.SetFlat(t"Items.PreemBladeModShockBlade.statModifiers", statsList24);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModShockBlade");

        //Create Mod PreemBladeModThermalBlade
        let statsList25: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBladeModThermalBlade_inline1", t"Ability.DealsThermalDamage_inline3");
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModThermalBlade_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBladeModThermalBlade_inline3", t"Ability.CanCauseBurn_inline3");
        TweakDBManager.SetFlat(t"Items.PreemBladeModThermalBlade_inline3.statType", t"BaseStats.BurningApplicationRate");
        TweakDBManager.SetFlat(t"Items.PreemBladeModThermalBlade_inline3.value", 20.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModThermalBlade_inline3");
        ArrayPush(statsList25,t"Items.PreemBladeModThermalBlade_inline1");
        ArrayPush(statsList25,t"Items.PreemBladeModThermalBlade_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBladeModThermalBlade", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBladeModThermalBlade.placementSlots", attachmentSlotsBlade);
        TweakDBManager.SetFlat(t"Items.PreemBladeModThermalBlade.statModifiers", statsList25);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModThermalBlade");


        //Create Mod PreemBladeModBleedBlade
        let statsList26: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBladeModBleedBlade_inline1", t"Ability.DealsChemicalDamage_inline3");
        TweakDBManager.SetFlat(t"Items.PreemBladeModBleedBlade_inline1.statType", t"BaseStats.DealsPhysicalDamage");
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModBleedBlade_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemBladeModBleedBlade_inline3", t"Ability.CanCausePoison_inline3");
        TweakDBManager.SetFlat(t"Items.PreemBladeModBleedBlade_inline3.statType", t"BaseStats.BleedingApplicationRate");
        TweakDBManager.SetFlat(t"Items.PreemBladeModBleedBlade_inline3.value", 20.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModBleedBlade_inline3");
        ArrayPush(statsList26,t"Items.PreemBladeModBleedBlade_inline1");
        ArrayPush(statsList26,t"Items.PreemBladeModBleedBlade_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBladeModBleedBlade", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBladeModBleedBlade.placementSlots", attachmentSlotsBlade);
        TweakDBManager.SetFlat(t"Items.PreemBladeModBleedBlade.statModifiers", statsList26);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModBleedBlade");

        //Create Mod PreemBladeModCritChance
        let statsList33: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBladeModCritChance_inline1", t"Items.Base_Katana_Handling_Stats_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBladeModCritChance_inline1.statType", t"BaseStats.CritChance");
        TweakDBManager.SetFlat(t"Items.PreemBladeModCritChance_inline1.value", 20.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModCritChance_inline1");
        ArrayPush(statsList33,t"Items.PreemBladeModCritChance_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBladeModCritChance", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBladeModCritChance.placementSlots", attachmentSlotsBlade);
        TweakDBManager.SetFlat(t"Items.PreemBladeModCritChance.statModifiers", statsList33);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModCritChance");

        //Create Mod PreemBladeModCritDamage
        let statsList34: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemBladeModCritDamage_inline1", t"Items.Base_Katana_Handling_Stats_inline2");
        TweakDBManager.SetFlat(t"Items.PreemBladeModCritDamage_inline1.statType", t"BaseStats.CritDamage");
        TweakDBManager.SetFlat(t"Items.PreemBladeModCritDamage_inline1.value", 30.0);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModCritDamage_inline1");
        ArrayPush(statsList34,t"Items.PreemBladeModCritDamage_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemBladeModCritDamage", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemBladeModCritDamage.placementSlots", attachmentSlotsBlade);
        TweakDBManager.SetFlat(t"Items.PreemBladeModCritDamage.statModifiers", statsList34);
        TweakDBManager.UpdateRecord(t"Items.PreemBladeModCritDamage");


        //Create Mod PreemHandleModRubberizedGrip
        let statsList27: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemHandleModRubberizedGrip_inline1", t"Items.Base_Katana_Handling_Stats_inline2");
        TweakDBManager.SetFlat(t"Items.PreemHandleModRubberizedGrip_inline1.value", 1.0);
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModRubberizedGrip_inline1");
        ArrayPush(statsList27,t"Items.PreemHandleModRubberizedGrip_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemHandleModRubberizedGrip", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemHandleModRubberizedGrip.placementSlots", attachmentSlotsHandle);
        TweakDBManager.SetFlat(t"Items.PreemHandleModRubberizedGrip.statModifiers", statsList27);
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModRubberizedGrip");

        //Create Mod PreemHandleModLightweightHandle
        let statsList32: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemHandleModLightweightHandle_inline1", t"Items.WakakoKatanaWeaponMod_inline1");
        TweakDBManager.SetFlat(t"Items.PreemHandleModLightweightHandle_inline1.statType", t"BaseStats.CanWeaponDash");
        //TweakDBManager.SetFlat(t"Items.PreemHandleModLightweightHandle_inline1.value", 0.5);
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModLightweightHandle_inline1");
        TweakDBManager.CloneRecord(n"Items.PreemHandleModLightweightHandle_inline2", t"Items.WakakoKatanaWeaponMod_inline1");
        TweakDBManager.SetFlat(t"Items.PreemHandleModLightweightHandle_inline2.statType", t"BaseStats.CanMeleeDash");
        //TweakDBManager.SetFlat(t"Items.PreemHandleModLightweightHandle_inline2.value", 0.5);
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModLightweightHandle_inline2");
        TweakDBManager.CloneRecord(n"Items.PreemHandleModLightweightHandle_inline3", t"Items.WakakoKatanaWeaponMod_inline1");
        TweakDBManager.SetFlat(t"Items.PreemHandleModLightweightHandle_inline3.statType", t"BaseStats.CanDash");
        //TweakDBManager.SetFlat(t"Items.PreemHandleModLightweightHandle_inline3.value", 0.5);
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModLightweightHandle_inline3");
        ArrayPush(statsList32, t"Items.PreemHandleModLightweightHandle_inline1");
        ArrayPush(statsList32, t"Items.PreemHandleModLightweightHandle_inline2");
        ArrayPush(statsList32, t"Items.PreemHandleModLightweightHandle_inline3");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemHandleModLightweightHandle", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemHandleModLightweightHandle.placementSlots", attachmentSlotsHandle);
        TweakDBManager.SetFlat(t"Items.PreemHandleModLightweightHandle.statModifiers", statsList32);
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModLightweightHandle");
        
        //Create Mod PreemHandleModTygerHandle
        let statsList33: array<TweakDBID>;
        TweakDBManager.CloneRecord(n"Items.PreemHandleModTygerHandle_inline1", t"Items.WakakoKatanaWeaponMod_inline1");
        TweakDBManager.SetFlat(t"Items.PreemHandleModTygerHandle_inline1.statType", t"BaseStats.CanMeleeLeap");
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModTygerHandle_inline1");
        ArrayPush(statsList33, t"Items.PreemHandleModTygerHandle_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemHandleModTygerHandle", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemHandleModTygerHandle.placementSlots", attachmentSlotsHandle);
        TweakDBManager.SetFlat(t"Items.PreemHandleModTygerHandle.statModifiers", statsList33);
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModTygerHandle");

        //Create Mod PreemHandleModBoosterHandle
        let statsList34: array<TweakDBID>;
        // TweakDBManager.CloneRecord(n"Items.PreemHandleModBoosterHandle_inline1", t"Items.WakakoKatanaWeaponMod_inline1");
        // TweakDBManager.SetFlat(t"Items.PreemHandleModBoosterHandle_inline1.value", 0.5);
        // TweakDBManager.UpdateRecord(t"Items.PreemHandleModBoosterHandle_inline1");
        // ArrayPush(statsList34, t"Items.PreemHandleModBoosterHandle_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        TweakDBManager.CloneRecord(n"Items.PreemHandleModBoosterHandle", t"Items.SimpleWeaponMod01");
        TweakDBManager.SetFlat(t"Items.PreemHandleModBoosterHandle.placementSlots", attachmentSlotsHandle);
        TweakDBManager.SetFlat(t"Items.PreemHandleModBoosterHandle.statModifiers", statsList34);
        TweakDBManager.UpdateRecord(t"Items.PreemHandleModBoosterHandle");

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