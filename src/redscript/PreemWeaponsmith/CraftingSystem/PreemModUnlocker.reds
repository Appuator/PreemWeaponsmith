module PreemCrafting.CraftingSystem.PreemModUnlocker
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModInstaller.*

public class PreemModUnlocker
{
    let devSystem: ref<PlayerDevelopmentSystem>;
    let weaponQuality: gamedataQuality;

    public func DetermineModUnlocked(preemModStyleType: PreemModStyleType, player: ref<PlayerPuppet>) -> Bool
    {
        let isUnlocked: Bool = false;
        let preemSettings: ref<PreemModSettings> = new PreemModSettings();
        if(Equals(preemSettings.ModUnlockMode, PreemWeaponsmithProgressionModUnlockStyle.Sandbox))
        {
            return true;
        }
        else
        {
            let CommonModList: array<PreemModStyleType>;
            let CommonPlusModList: array<PreemModStyleType>;
            let UncommonModList: array<PreemModStyleType>;
            let UncommonPlusModList: array<PreemModStyleType>;
            let RareModList: array<PreemModStyleType>;
            let RarePlusModList: array<PreemModStyleType>;
            let EpicModList: array<PreemModStyleType>;
            let EpicPlusModList: array<PreemModStyleType>;
            let LegendaryModList: array<PreemModStyleType>;
            let LegendaryPlusModList: array<PreemModStyleType>;
            let LegendaryPlusPlusModList: array<PreemModStyleType>;
            let weaponRarity = this.weaponQuality;
            CommonModList = PreemModUnlocker.GetUnlockedCommonModList();
            CommonPlusModList = PreemModUnlocker.GetUnlockedCommonPlusModList();
            UncommonModList = PreemModUnlocker.GetUnlockedUncommonModList();
            UncommonPlusModList = PreemModUnlocker.GetUnlockedUncommonPlusModList();
            RareModList = PreemModUnlocker.GetUnlockedRareModList();
            RarePlusModList = PreemModUnlocker.GetUnlockedRarePlusModList();
            EpicModList = PreemModUnlocker.GetUnlockedEpicModList();
            EpicPlusModList = PreemModUnlocker.GetUnlockedEpicPlusModList();
            LegendaryModList = PreemModUnlocker.GetUnlockedLegendaryModList();
            LegendaryPlusModList = PreemModUnlocker.GetUnlockedLegendaryPlusModList();
            LegendaryPlusPlusModList = PreemModUnlocker.GetUnlockedLegendaryPlusPlusModList();

            switch weaponRarity {
                case gamedataQuality.Common:
                    if(ArrayContains(CommonModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.CommonPlus:
                    if(ArrayContains(CommonPlusModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.Uncommon:
                    if(ArrayContains(UncommonModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.UncommonPlus:
                    if(ArrayContains(UncommonPlusModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.Rare:
                    if(ArrayContains(RareModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.RarePlus:
                    if(ArrayContains(RarePlusModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.Epic:
                    if(ArrayContains(EpicModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.EpicPlus:
                    if(ArrayContains(EpicPlusModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.Legendary:
                    if(ArrayContains(LegendaryModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.LegendaryPlus:
                    if(ArrayContains(LegendaryPlusModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
                case gamedataQuality.LegendaryPlusPlus:
                    if(ArrayContains(LegendaryPlusPlusModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                    break;
            }
        }

        return isUnlocked;
    }

    public func DetermineAmountOfModsAllowed(player: ref<PlayerPuppet>) -> Int32
    {
        let preemSettings: ref<PreemModSettings> = new PreemModSettings();
        let weaponRarity = this.weaponQuality;
        if(Equals(preemSettings.ModAmountMode, PreemWeaponsmithProgressionModAmountStyle.TechnicalAbilitySkill))
        {
            let modsAllowed: Int32 = 1;
            let playerCraftingLevel: Float = Cast<Float>(this.devSystem.GetProficiencyLevel(player, gamedataProficiencyType.TechnicalAbilitySkill));
            modsAllowed += FloorF(playerCraftingLevel / 4.0);
            return FloorF(ClampF((Cast<Float>(modsAllowed)),1.0,6.0));
        }
        else{
                if(Equals(preemSettings.ModAmountMode, PreemWeaponsmithProgressionModAmountStyle.WeaponBlueprints))
                {
                    switch weaponRarity {
                        case gamedataQuality.Common:
                            return 0;
                            break;
                        case gamedataQuality.CommonPlus:
                            return 0;
                            break;
                        case gamedataQuality.Uncommon:
                            return 2;
                            break;
                        case gamedataQuality.UncommonPlus:
                            return 2;
                            break;
                        case gamedataQuality.Rare:
                            return 3;
                            break;
                        case gamedataQuality.RarePlus:
                            return 3;
                            break;
                        case gamedataQuality.Epic:
                            return 5;
                            break;
                        case gamedataQuality.EpicPlus:
                            return 5;
                            break;
                        case gamedataQuality.Legendary:
                            return 6;
                            break;
                        case gamedataQuality.LegendaryPlus:
                            return 6;
                            break;
                        case gamedataQuality.LegendaryPlusPlus:
                            return 6;
                            break;
                        }
                }
                else{
                    return 6;
                }
            }
        return 6;
    }

    public func SetDevSystem(player: ref<PlayerPuppet>) -> Void
    {
        this.devSystem = GameInstance.GetScriptableSystemsContainer(player.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    }

    public func SetWeaponQuality(weaponRarity: gamedataQuality) -> Void
    {
        this.weaponQuality = weaponRarity;
    }

    public final static func GetUnlockedCommonModList() -> array<PreemModStyleType>
    {
        let CommonModList: array<PreemModStyleType>;

        for mod in PreemModUnlocker.GetCommonModStyles() {
            ArrayPush(CommonModList, mod);
        }

        return CommonModList;
    }

    public final static func GetUnlockedCommonPlusModList() -> array<PreemModStyleType>
    {
        let CommonPlusModList: array<PreemModStyleType>;

        CommonPlusModList = PreemModUnlocker.GetUnlockedCommonModList();

        for mod in PreemModUnlocker.GetCommonPlusModStyles() {
            ArrayPush(CommonPlusModList, mod);
        }

        return CommonPlusModList;
    }

    public final static func GetUnlockedUncommonModList() -> array<PreemModStyleType>
    {
        let UncommonModList: array<PreemModStyleType>;

        UncommonModList = PreemModUnlocker.GetUnlockedCommonPlusModList();
        
        for mod in PreemModUnlocker.GetUncommonModStyles() {
            ArrayPush(UncommonModList, mod);
        }

        return UncommonModList;
    }

    public final static func GetUnlockedUncommonPlusModList() -> array<PreemModStyleType>
    {
        let UncommonPlusModList: array<PreemModStyleType>;

        UncommonPlusModList = PreemModUnlocker.GetUnlockedUncommonModList();
        
        for mod in PreemModUnlocker.GetUncommonPlusModStyles() {
            ArrayPush(UncommonPlusModList, mod);
        }

        return UncommonPlusModList;
    }

    public final static func GetUnlockedRareModList() -> array<PreemModStyleType>
    {
        let RareModList: array<PreemModStyleType>;

        RareModList = PreemModUnlocker.GetUnlockedUncommonPlusModList();

        for mod in PreemModUnlocker.GetRareModStyles() {
            ArrayPush(RareModList, mod);
        }

        return RareModList;
    }

    public final static func GetUnlockedRarePlusModList() -> array<PreemModStyleType>
    {
        let RarePlusModList: array<PreemModStyleType>;

        RarePlusModList = PreemModUnlocker.GetUnlockedRareModList();

        for mod in PreemModUnlocker.GetRarePlusModStyles() {
            ArrayPush(RarePlusModList, mod);
        }

        return RarePlusModList;
    }

    public final static func GetUnlockedEpicModList() -> array<PreemModStyleType>
    {
        let EpicModList: array<PreemModStyleType>;

        EpicModList = PreemModUnlocker.GetUnlockedRarePlusModList();

        for mod in PreemModUnlocker.GetEpicModStyles() {
            ArrayPush(EpicModList, mod);
        }

        return EpicModList;
    }

    public final static func GetUnlockedEpicPlusModList() -> array<PreemModStyleType>
    {
        let EpicPlusModList: array<PreemModStyleType>;

        EpicPlusModList = PreemModUnlocker.GetUnlockedEpicModList();

        for mod in PreemModUnlocker.GetEpicPlusModStyles() {
            ArrayPush(EpicPlusModList, mod);
        }

        return EpicPlusModList;
    }

    public final static func GetUnlockedLegendaryModList() -> array<PreemModStyleType>
    {
        let LegendaryModList: array<PreemModStyleType>;

        LegendaryModList = PreemModUnlocker.GetUnlockedEpicPlusModList();

        for mod in PreemModUnlocker.GetLegendaryModStyles() {
            ArrayPush(LegendaryModList, mod);
        }

        return LegendaryModList;
    }

    public final static func GetUnlockedLegendaryPlusModList() -> array<PreemModStyleType>
    {
        let LegendaryPlusModList: array<PreemModStyleType>;

        LegendaryPlusModList = PreemModUnlocker.GetUnlockedLegendaryModList();

        for mod in PreemModUnlocker.GetLegendaryPlusModStyles() {
            ArrayPush(LegendaryPlusModList, mod);
        }

        return LegendaryPlusModList;
    }

    public final static func GetUnlockedLegendaryPlusPlusModList() -> array<PreemModStyleType>
    {
        let LegendaryPlusPlusModList: array<PreemModStyleType>;

        LegendaryPlusPlusModList = PreemModUnlocker.GetUnlockedLegendaryPlusModList();

        for mod in PreemModUnlocker.GetLegendaryPlusPlusModStyles() {
            ArrayPush(LegendaryPlusPlusModList, mod);
        }

        return LegendaryPlusPlusModList;
    }

    public final static func GetPreemModUnlockReqDescription(preemModStyleType: PreemModStyleType) -> String
    {
        let preemSettings: ref<PreemModSettings> = new PreemModSettings();
        let unlockReqDescription: String = "";

        if(Equals(preemSettings.ModUnlockMode, PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints))
        {
            unlockReqDescription = "\nBlUEPRINT QUALITY REQUIRED:\n";

            let CommonModList: array<PreemModStyleType>;
            let CommonPlusModList: array<PreemModStyleType>;
            let UncommonModList: array<PreemModStyleType>;
            let UncommonPlusModList: array<PreemModStyleType>;
            let RareModList: array<PreemModStyleType>;
            let RarePlusModList: array<PreemModStyleType>;
            let EpicModList: array<PreemModStyleType>;
            let EpicPlusModList: array<PreemModStyleType>;
            let LegendaryModList: array<PreemModStyleType>;
            let LegendaryPlusModList: array<PreemModStyleType>;
            let LegendaryPlusPlusModList: array<PreemModStyleType>;
            CommonModList = PreemModUnlocker.GetCommonModStyles();
            CommonPlusModList = PreemModUnlocker.GetCommonPlusModStyles();
            UncommonModList = PreemModUnlocker.GetUncommonModStyles();
            UncommonPlusModList = PreemModUnlocker.GetUncommonPlusModStyles();
            RareModList = PreemModUnlocker.GetRareModStyles();
            RarePlusModList = PreemModUnlocker.GetRarePlusModStyles();
            EpicModList = PreemModUnlocker.GetEpicModStyles();
            EpicPlusModList = PreemModUnlocker.GetEpicPlusModStyles();
            LegendaryModList = PreemModUnlocker.GetLegendaryModStyles();
            LegendaryPlusModList = PreemModUnlocker.GetLegendaryPlusModStyles();
            LegendaryPlusPlusModList = PreemModUnlocker.GetLegendaryPlusPlusModStyles();

            if(ArrayContains(CommonModList, preemModStyleType))
            {
                unlockReqDescription += "Tier 1";
            }
            else{
                    if(ArrayContains(CommonPlusModList, preemModStyleType))
                    {
                        unlockReqDescription += "Tier 1+";
                    }
                    else{
                        if(ArrayContains(UncommonModList, preemModStyleType))
                        {
                            unlockReqDescription += "Tier 2";
                        }
                        else{
                            if(ArrayContains(UncommonPlusModList, preemModStyleType))
                            {
                                unlockReqDescription += "Tier 2+";
                            }
                            else{
                                if(ArrayContains(RareModList, preemModStyleType))
                                {
                                    unlockReqDescription += "Tier 3";
                                }
                                else{
                                    if(ArrayContains(RarePlusModList, preemModStyleType))
                                    {
                                        unlockReqDescription += "Tier 3+";
                                    }
                                    else{
                                        if(ArrayContains(EpicModList, preemModStyleType))
                                        {
                                            unlockReqDescription += "Tier 4";
                                        }
                                        else{
                                            if(ArrayContains(EpicPlusModList, preemModStyleType))
                                            {
                                                unlockReqDescription += "Tier 4+";
                                            }
                                            else{
                                                if(ArrayContains(LegendaryModList, preemModStyleType))
                                                {
                                                    unlockReqDescription += "Tier 5";
                                                }
                                                else{
                                                    if(ArrayContains(LegendaryPlusModList, preemModStyleType))
                                                    {
                                                        unlockReqDescription += "Tier 5+";
                                                    }
                                                    else{
                                                        if(ArrayContains(LegendaryPlusPlusModList, preemModStyleType))
                                                        {
                                                            unlockReqDescription += "Tier 5++";
                                                        }
                                                        else{
                                                            unlockReqDescription = "";
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
        }

        return unlockReqDescription;
    }

    public final static func GetCommonModStyles() -> array<PreemModStyleType>
    {
        let CommonTierModList: array<PreemModStyleType>;
        return CommonTierModList;
    }

    public final static func GetCommonPlusModStyles() -> array<PreemModStyleType>
    {
        let CommonPlusTierModList: array<PreemModStyleType>;
        return CommonPlusTierModList;
    }

    public final static func GetUncommonModStyles() -> array<PreemModStyleType>
    {
        let UncommonTierModList: array<PreemModStyleType>;

        ArrayPush(UncommonTierModList, PreemModStyleType.Barrel_Recoil);
        ArrayPush(UncommonTierModList, PreemModStyleType.Trigger_Burst);
        ArrayPush(UncommonTierModList, PreemModStyleType.Trigger_FullAuto);
        ArrayPush(UncommonTierModList, PreemModStyleType.Trigger_SemiAuto);
        ArrayPush(UncommonTierModList, PreemModStyleType.Barrel_RecoilY);
        ArrayPush(UncommonTierModList, PreemModStyleType.Barrel_Silencer);
        ArrayPush(UncommonTierModList, PreemModStyleType.Handle_RubberizedGrip);
        ArrayPush(UncommonTierModList, PreemModStyleType.Mag_QuickMag);
        ArrayPush(UncommonTierModList, PreemModStyleType.Blade_DeflectorBlade);
        return UncommonTierModList;
    }

    public final static func GetUncommonPlusModStyles() -> array<PreemModStyleType>
    {
        let UncommonPlusTierModList: array<PreemModStyleType>;
        return UncommonPlusTierModList;
    }

    public final static func GetRareModStyles() -> array<PreemModStyleType>
    {
        let RareTierModList: array<PreemModStyleType>;
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Electric);
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Thermal);
        ArrayPush(RareTierModList, PreemModStyleType.Blade_Shock);
        ArrayPush(RareTierModList, PreemModStyleType.Blade_Thermal);
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Extended);
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Chemical);
        ArrayPush(RareTierModList, PreemModStyleType.Blade_Chem);
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Bleed);
        ArrayPush(RareTierModList, PreemModStyleType.Blade_Bleed);
        return RareTierModList;
    }

    public final static func GetRarePlusModStyles() -> array<PreemModStyleType>
    {
        let RarePlusTierModList: array<PreemModStyleType>;
        return RarePlusTierModList;
    }

    public final static func GetEpicModStyles() -> array<PreemModStyleType>
    {
        let EpicTierModList: array<PreemModStyleType>;
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_Power);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_Smart);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_Tech);
        ArrayPush(EpicTierModList, PreemModStyleType.Trigger_Charge);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_SmartRangeTarget);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_SmartMultiTarget);
        ArrayPush(EpicTierModList, PreemModStyleType.Trigger_ChargeFullAuto);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_TurboCharger);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_OmegaCharge);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_VelocityBooster);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_CorkscrewRifling);
        ArrayPush(EpicTierModList, PreemModStyleType.Blade_CritDamage);
        ArrayPush(EpicTierModList, PreemModStyleType.Blade_CritChance);
        ArrayPush(EpicTierModList, PreemModStyleType.Handle_Dash);
        return EpicTierModList;
    }

    public final static func GetEpicPlusModStyles() -> array<PreemModStyleType>
    {
        let EpicPlusTierModList: array<PreemModStyleType>;
        return EpicPlusTierModList;
    }

    public final static func GetLegendaryModStyles() -> array<PreemModStyleType>
    {
        let LegendaryTierModList: array<PreemModStyleType>;

        ArrayPush(LegendaryTierModList, PreemModStyleType.Barrel_Turbo);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Trigger_InstaBurst);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Trigger_UltraAction);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Handle_Leap);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Handle_StaminaReduction);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Barrel_ExtraBarrel);
        return LegendaryTierModList;
    }

    public final static func GetLegendaryPlusModStyles() -> array<PreemModStyleType>
    {
        let LegendaryPlusTierModList: array<PreemModStyleType>;
        return LegendaryPlusTierModList;
    }

    public final static func GetLegendaryPlusPlusModStyles() -> array<PreemModStyleType>
    {
        let LegendaryPlusPlusTierModList: array<PreemModStyleType>;
        return LegendaryPlusPlusTierModList;
    }

}