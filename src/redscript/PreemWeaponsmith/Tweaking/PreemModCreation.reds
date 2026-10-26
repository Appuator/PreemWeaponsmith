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
        //CreateShotgunStat Record
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModExtraBarrel
        // let statList9: array<TweakDBID>;
        // //CreateShotgunStat Record
        // //TweakDBManager.CloneRecord(n"Items.PreemBarrelModExtraBarrel_inline1", t"Items.HitmanNovaWeaponMod_inline0");
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
        //TweakDBManager.CloneRecord(n"Items.PreemBarrelModRecoil_inline1", t"Items.HitmanNovaWeaponMod_inline0");
        //ArrayPush(statList10,t"Items.PreemBarrelModRecoil_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModRecoilY
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModSmart

        //Create Mod PreemBarrelModTech

        //Create Mod PreemBarrelModTurbo
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)


        //Create Mod PreemBarrelModAtomizer
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModAtomizer_inline1", t"Items.HitmanNovaWeaponMod_inline0");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer_inline1.statType", t"BaseStats.CycleTime");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer_inline1.value", 0.7);
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModAtomizer_inline1");
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModAtomizer_inline1", t"AttackModifier.TechWeaponDPSReduction");
        // TweakDBManager.SetFlat(t"Items.PreemBarrelModAtomizer_inline1.value", 1.3);
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModAtomizer_inline1");
        //ArrayPush(statList21,t"Items.PreemBarrelModAtomizer_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModPower

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
        // TweakDBManager.CloneRecord(n"Items.PreemBarrelModSilencer_inline5", t"Items.SilencerBase_inline2");
        // TweakDBManager.UpdateRecord(t"Items.PreemBarrelModSilencer_inline5");
        //ArrayPush(statList29,t"Items.PreemBarrelModSilencer_inline5");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModSmartMultiTarget
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModSmartRangeTarget
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModTurboCharge
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModOmegaCharge
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModVelocityBooster
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBarrelModCorkscrewRifling
        //TweakDBManager.SetFlat(t"Items.PreemBarrelModCorkscrewRifling_inline1.statType", t"BaseStats.RicochetTargetSearchAngle");
        //TweakDBManager.SetFlat(t"Items.PreemBarrelModCorkscrewRifling_inline2.statType", t"BaseStats.RicochetMaxAngle");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

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
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemTriggerModFullAuto
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemTriggerModBurst
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemTriggerModCharge

        //Create Mod PreemTriggerModChargeFullAuto
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemTriggerModInstaBurst
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemTriggerModUltraAction
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemMagazineModThermalRounds
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemMagazineModElectricalRounds
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemMagazineModChemicalRounds
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemMagazineModExtendedMag
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemMagazineModQuickMag
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemMagazineModBleedRounds
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBladeModShockBlade
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBladeModThermalBlade
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)


        //Create Mod PreemBladeModBleedBlade
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBladeModCritChance
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBladeModCritDamage
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemBladeModDeflectorBlade
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)


        //Create Mod PreemHandleModRubberizedGrip
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemHandleModLightweightHandle
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)
        
        //Create Mod PreemHandleModTygerHandle
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

        //Create Mod PreemHandleModBoosterHandle
        // TweakDBManager.CloneRecord(n"Items.PreemHandleModBoosterHandle_inline1", t"Items.WakakoKatanaWeaponMod_inline1");
        // TweakDBManager.SetFlat(t"Items.PreemHandleModBoosterHandle_inline1.value", 0.5);
        // TweakDBManager.UpdateRecord(t"Items.PreemHandleModBoosterHandle_inline1");
        // ArrayPush(statsList34, t"Items.PreemHandleModBoosterHandle_inline1");
        //Create Actual PreemMod Item Record (item to be used as part in the PartListElement Record)

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