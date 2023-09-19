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
        if(Equals(preemSettings.ModUnlockMode, PreemWeaponsmithProgressionModUnlockStyle.CraftingPerks))
        {
            let trueCraftsmanPerk = this.devSystem.GetPerkLevel(player, gamedataPerkType.Crafting_Area_02_Perk_1);
            let greaseMonkeyPerk = this.devSystem.GetPerkLevel(player, gamedataPerkType.Crafting_Area_06_Perk_3);
            let edgeRunnerArtisanPerk = this.devSystem.GetPerkLevel(player, gamedataPerkType.Crafting_Area_09_Perk_1);
            let trueCraftsmanStyleList: array<PreemModStyleType>;
            let greaseMonkeyStyleList: array<PreemModStyleType>;
            let edgeRunnerStyleList: array<PreemModStyleType>;
            trueCraftsmanStyleList = PreemModUnlocker.GetUnlockedWeaponTrueCraftsman();
            greaseMonkeyStyleList = PreemModUnlocker.GetUnlockedWeaponGreaseMonkey();
            edgeRunnerStyleList = PreemModUnlocker.GetUnlockedWeaponEdgerunnerArtisan();

            if(ArrayContains(trueCraftsmanStyleList, preemModStyleType))
            {
                if(trueCraftsmanPerk > 0)
                {
                    isUnlocked = true;
                }
                else{
                    isUnlocked = false;
                }
            }
            else{
                    if(ArrayContains(greaseMonkeyStyleList, preemModStyleType))
                    {
                        if(greaseMonkeyPerk > 0)
                        {
                            isUnlocked = true;
                        }
                        else{
                            isUnlocked = false;
                        }
                    }
                    else{
                        if(ArrayContains(edgeRunnerStyleList, preemModStyleType))
                        {
                            if(edgeRunnerArtisanPerk > 0)
                            {
                                isUnlocked = true;
                            }
                            else{
                                isUnlocked = false;
                            }
                        }
                        else{

                            isUnlocked = true;
                        }
                    }
            }
        }
        else {

            if(Equals(preemSettings.ModUnlockMode, PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints))
            {
                let CommonModList: array<PreemModStyleType>;
                let UncommonModList: array<PreemModStyleType>;
                let RareModList: array<PreemModStyleType>;
                let EpicModList: array<PreemModStyleType>;
                let LegendaryModList: array<PreemModStyleType>;
                let weaponRarity = this.weaponQuality;
                CommonModList = PreemModUnlocker.GetUnlockedCommonModList();
                UncommonModList = PreemModUnlocker.GetUnlockedUncommonModList();
                RareModList = PreemModUnlocker.GetUnlockedRareModList();
                EpicModList = PreemModUnlocker.GetUnlockedEpicModList();
                LegendaryModList = PreemModUnlocker.GetUnlockedLegendaryModList();

                if(Equals(weaponRarity, gamedataQuality.Common))
                {
                    if(ArrayContains(CommonModList, preemModStyleType))
                    {
                        isUnlocked = true;
                    }
                    else{
                        isUnlocked = false;
                    }
                }
                else{

                    if(Equals(weaponRarity, gamedataQuality.Uncommon))
                    {
                        if(ArrayContains(UncommonModList, preemModStyleType))
                        {
                            isUnlocked = true;
                        }
                        else{
                            isUnlocked = false;
                        }
                    }
                    else{

                        if(Equals(weaponRarity, gamedataQuality.Rare))
                        {
                            if(ArrayContains(RareModList, preemModStyleType))
                            {
                                isUnlocked = true;
                            }
                            else{
                                isUnlocked = false;
                            }
                        }
                        else{

                            if(Equals(weaponRarity, gamedataQuality.Epic))
                            {
                                if(ArrayContains(EpicModList, preemModStyleType))
                                {
                                    isUnlocked = true;
                                }
                                else{
                                    isUnlocked = false;
                                }
                            }
                            else{
                                if(Equals(weaponRarity, gamedataQuality.Legendary))
                                {
                                    if(ArrayContains(LegendaryModList, preemModStyleType))
                                    {
                                        isUnlocked = true;
                                    }
                                    else{
                                        isUnlocked = false;
                                    }
                                }
                            }
                        }
                    }
                }

            }
            else{
                return true;
            }
        
        }

        return isUnlocked;
    }

    public func DetermineAmountOfModsAllowed(player: ref<PlayerPuppet>) -> Int32
    {
        let preemSettings: ref<PreemModSettings> = new PreemModSettings();
        if(Equals(preemSettings.ModAmountMode, PreemWeaponsmithProgressionModAmountStyle.CraftingLevel))
        {
            let modsAllowed: Int32 = 1;
            let playerCraftingLevel: Float = Cast<Float>(this.devSystem.GetProficiencyLevel(player, gamedataProficiencyType.Crafting));
            modsAllowed += FloorF(playerCraftingLevel / 4.0);
            return FloorF(ClampF((Cast<Float>(modsAllowed)),1.0,6.0));
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

    public final static func GetUnlockedWeaponTrueCraftsman() -> array<PreemModStyleType>
    {
        let weaponTrueCraftsmanList: array<PreemModStyleType>;
        let preemSettings: ref<PreemModSettings> = new PreemModSettings();
        if(Equals(preemSettings.ModUnlockPerk1, PreemWeaponsmithModUnlockPerks.TrueCraftsman))
        {
            for mod in PreemModUnlocker.GetTier1ModStyles() {
                ArrayPush(weaponTrueCraftsmanList, mod);
            }
        }

        if(Equals(preemSettings.ModUnlockPerk2, PreemWeaponsmithModUnlockPerks.TrueCraftsman))
        {
            for mod in PreemModUnlocker.GetTier2ModStyles() {
                ArrayPush(weaponTrueCraftsmanList, mod);
            }
        }

        if(Equals(preemSettings.ModUnlockPerk3, PreemWeaponsmithModUnlockPerks.TrueCraftsman))
        {
            for mod in PreemModUnlocker.GetTier3ModStyles() {
                ArrayPush(weaponTrueCraftsmanList, mod);
            }
        }

        return weaponTrueCraftsmanList;
    }

    public final static func GetUnlockedWeaponGreaseMonkey() -> array<PreemModStyleType>
    {
        let weaponGreaseMonkeyList: array<PreemModStyleType>;

        let preemSettings: ref<PreemModSettings> = new PreemModSettings();
        if(Equals(preemSettings.ModUnlockPerk1, PreemWeaponsmithModUnlockPerks.GreaseMonkey))
        {
            for mod in PreemModUnlocker.GetTier1ModStyles() {
                ArrayPush(weaponGreaseMonkeyList, mod);
            }
        }

        if(Equals(preemSettings.ModUnlockPerk2, PreemWeaponsmithModUnlockPerks.GreaseMonkey))
        {
            for mod in PreemModUnlocker.GetTier2ModStyles() {
                ArrayPush(weaponGreaseMonkeyList, mod);
            }
        }

        if(Equals(preemSettings.ModUnlockPerk3, PreemWeaponsmithModUnlockPerks.GreaseMonkey))
        {
            for mod in PreemModUnlocker.GetTier3ModStyles() {
                ArrayPush(weaponGreaseMonkeyList, mod);
            }
        }

        return weaponGreaseMonkeyList;
    }

    public final static func GetUnlockedWeaponEdgerunnerArtisan() -> array<PreemModStyleType>
    {
        let weaponEdgeRunnerList: array<PreemModStyleType>;

        let preemSettings: ref<PreemModSettings> = new PreemModSettings();
        if(Equals(preemSettings.ModUnlockPerk1, PreemWeaponsmithModUnlockPerks.EdgerunnerArtisan))
        {
            for mod in PreemModUnlocker.GetTier1ModStyles() {
                ArrayPush(weaponEdgeRunnerList, mod);
            }
        }

        if(Equals(preemSettings.ModUnlockPerk2, PreemWeaponsmithModUnlockPerks.EdgerunnerArtisan))
        {
            for mod in PreemModUnlocker.GetTier2ModStyles() {
                ArrayPush(weaponEdgeRunnerList, mod);
            }
        }

        if(Equals(preemSettings.ModUnlockPerk3, PreemWeaponsmithModUnlockPerks.EdgerunnerArtisan))
        {
            for mod in PreemModUnlocker.GetTier3ModStyles() {
                ArrayPush(weaponEdgeRunnerList, mod);
            }
        }

        return weaponEdgeRunnerList;
    }

    public final static func GetUnlockedCommonModList() -> array<PreemModStyleType>
    {
        let CommonModList: array<PreemModStyleType>;

        for mod in PreemModUnlocker.GetCommonModStyles() {
            ArrayPush(CommonModList, mod);
        }

        return CommonModList;
    }

    public final static func GetUnlockedUncommonModList() -> array<PreemModStyleType>
    {
        let UncommonModList: array<PreemModStyleType>;

        for mod in PreemModUnlocker.GetCommonModStyles() {
            ArrayPush(UncommonModList, mod);
        }
        
        for mod in PreemModUnlocker.GetUncommonModStyles() {
            ArrayPush(UncommonModList, mod);
        }

        return UncommonModList;
    }

    public final static func GetUnlockedRareModList() -> array<PreemModStyleType>
    {
        let RareModList: array<PreemModStyleType>;

        for mod in PreemModUnlocker.GetCommonModStyles() {
            ArrayPush(RareModList, mod);
        }
        
        for mod in PreemModUnlocker.GetUncommonModStyles() {
            ArrayPush(RareModList, mod);
        }

        for mod in PreemModUnlocker.GetRareModStyles() {
            ArrayPush(RareModList, mod);
        }

        return RareModList;
    }

    public final static func GetUnlockedEpicModList() -> array<PreemModStyleType>
    {
        let EpicModList: array<PreemModStyleType>;

        for mod in PreemModUnlocker.GetCommonModStyles() {
            ArrayPush(EpicModList, mod);
        }
        
        for mod in PreemModUnlocker.GetUncommonModStyles() {
            ArrayPush(EpicModList, mod);
        }

        for mod in PreemModUnlocker.GetRareModStyles() {
            ArrayPush(EpicModList, mod);
        }

        for mod in PreemModUnlocker.GetEpicModStyles() {
            ArrayPush(EpicModList, mod);
        }

        return EpicModList;
    }

    public final static func GetUnlockedLegendaryModList() -> array<PreemModStyleType>
    {
        let LegendaryModList: array<PreemModStyleType>;

        for mod in PreemModUnlocker.GetCommonModStyles() {
            ArrayPush(LegendaryModList, mod);
        }
        
        for mod in PreemModUnlocker.GetUncommonModStyles() {
            ArrayPush(LegendaryModList, mod);
        }

        for mod in PreemModUnlocker.GetRareModStyles() {
            ArrayPush(LegendaryModList, mod);
        }

        for mod in PreemModUnlocker.GetEpicModStyles() {
            ArrayPush(LegendaryModList, mod);
        }

        for mod in PreemModUnlocker.GetLegendaryModStyles() {
            ArrayPush(LegendaryModList, mod);
        }

        return LegendaryModList;
    }

    

    public final static func GetPreemModUnlockReqDescription(preemModStyleType: PreemModStyleType) -> String
    {
        let preemSettings: ref<PreemModSettings> = new PreemModSettings();
        let unlockReqDescription: String = "";

        if(Equals(preemSettings.ModUnlockMode, PreemWeaponsmithProgressionModUnlockStyle.CraftingPerks))
        {

            unlockReqDescription = "\nPERK REQUIRED:\n";

            let trueCraftsmanStyleList: array<PreemModStyleType>;
            let greaseMonkeyStyleList: array<PreemModStyleType>;
            let edgeRunnerStyleList: array<PreemModStyleType>;
            trueCraftsmanStyleList = PreemModUnlocker.GetUnlockedWeaponTrueCraftsman();
            greaseMonkeyStyleList = PreemModUnlocker.GetUnlockedWeaponGreaseMonkey();
            edgeRunnerStyleList = PreemModUnlocker.GetUnlockedWeaponEdgerunnerArtisan();

            if(ArrayContains(trueCraftsmanStyleList, preemModStyleType))
            {
                unlockReqDescription += "True Craftsman";
            }
            else{
                    if(ArrayContains(greaseMonkeyStyleList, preemModStyleType))
                    {
                        unlockReqDescription += "Grease Monkey";
                    }
                    else{
                        if(ArrayContains(edgeRunnerStyleList, preemModStyleType))
                        {
                            unlockReqDescription += "Edgerunner Artisan";
                        }
                        else{
                            unlockReqDescription = "";
                        }
                    }
            }
        }
        else{

            if(Equals(preemSettings.ModUnlockMode, PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints))
            {
                unlockReqDescription = "\nBlUEPRINT QUALITY REQUIRED:\n";

                let CommonModList: array<PreemModStyleType>;
                let UncommonModList: array<PreemModStyleType>;
                let RareModList: array<PreemModStyleType>;
                let EpicModList: array<PreemModStyleType>;
                let LegendaryModList: array<PreemModStyleType>;
                CommonModList = PreemModUnlocker.GetCommonModStyles();
                UncommonModList = PreemModUnlocker.GetUncommonModStyles();
                RareModList = PreemModUnlocker.GetRareModStyles();
                EpicModList = PreemModUnlocker.GetEpicModStyles();
                LegendaryModList = PreemModUnlocker.GetLegendaryModStyles();

                if(ArrayContains(CommonModList, preemModStyleType))
                {
                    unlockReqDescription += "Common";
                }
                else{
                        if(ArrayContains(UncommonModList, preemModStyleType))
                        {
                            unlockReqDescription += "Uncommon";
                        }
                        else{
                            if(ArrayContains(RareModList, preemModStyleType))
                            {
                                unlockReqDescription += "Rare";
                            }
                            else{
                                if(ArrayContains(EpicModList, preemModStyleType))
                                {
                                    unlockReqDescription += "Epic";
                                }
                                else{
                                    if(ArrayContains(LegendaryModList, preemModStyleType))
                                    {
                                        unlockReqDescription += "Legendary";
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

        return unlockReqDescription;
    }

    public final static func GetTier1ModStyles() -> array<PreemModStyleType>
    {
        let tier1ModList: array<PreemModStyleType>;

        ArrayPush(tier1ModList, PreemModStyleType.Barrel_Recoil);
        ArrayPush(tier1ModList, PreemModStyleType.Barrel_RecoilY);
        ArrayPush(tier1ModList, PreemModStyleType.Barrel_Silencer);
        ArrayPush(tier1ModList, PreemModStyleType.Mag_Chemical);
        ArrayPush(tier1ModList, PreemModStyleType.Mag_Electric);
        ArrayPush(tier1ModList, PreemModStyleType.Mag_Thermal);
        ArrayPush(tier1ModList, PreemModStyleType.Handle_RubberizedGrip);
        ArrayPush(tier1ModList, PreemModStyleType.Blade_Chem);
        ArrayPush(tier1ModList, PreemModStyleType.Blade_Shock);
        ArrayPush(tier1ModList, PreemModStyleType.Blade_Thermal);
        return tier1ModList;
    }

    public final static func GetTier2ModStyles() -> array<PreemModStyleType>
    {
        let tier2ModList: array<PreemModStyleType>;

        ArrayPush(tier2ModList, PreemModStyleType.Barrel_Power);
        ArrayPush(tier2ModList, PreemModStyleType.Barrel_Smart);
        ArrayPush(tier2ModList, PreemModStyleType.Barrel_Tech);
        ArrayPush(tier2ModList, PreemModStyleType.Trigger_Charge);
        ArrayPush(tier2ModList, PreemModStyleType.Trigger_ChargeFullAuto);
        ArrayPush(tier2ModList, PreemModStyleType.Mag_Extended);
        ArrayPush(tier2ModList, PreemModStyleType.Handle_Dash);
        ArrayPush(tier2ModList, PreemModStyleType.Blade_CritDamage);
        ArrayPush(tier2ModList, PreemModStyleType.Blade_CritChance);
        return tier2ModList;
    }

    public final static func GetTier3ModStyles() -> array<PreemModStyleType>
    {
        let tier3ModList: array<PreemModStyleType>;

        ArrayPush(tier3ModList, PreemModStyleType.Barrel_ExtraBarrel);
        ArrayPush(tier3ModList, PreemModStyleType.Barrel_Turbo);
        ArrayPush(tier3ModList, PreemModStyleType.Barrel_SmartMultiTarget);
        ArrayPush(tier3ModList, PreemModStyleType.Barrel_SmartRangeTarget);
        ArrayPush(tier3ModList, PreemModStyleType.Trigger_InstaBurst);
        ArrayPush(tier3ModList, PreemModStyleType.Trigger_UltraAction);
        ArrayPush(tier3ModList, PreemModStyleType.Mag_Bleed);
        ArrayPush(tier3ModList, PreemModStyleType.Handle_Leap);
        ArrayPush(tier3ModList, PreemModStyleType.Blade_Bleed);
        return tier3ModList;
    }

    public final static func GetCommonModStyles() -> array<PreemModStyleType>
    {
        let CommonTierModList: array<PreemModStyleType>;
        return CommonTierModList;
    }

    public final static func GetUncommonModStyles() -> array<PreemModStyleType>
    {
        let UncommonTierModList: array<PreemModStyleType>;

        ArrayPush(UncommonTierModList, PreemModStyleType.Barrel_Recoil);
        ArrayPush(UncommonTierModList, PreemModStyleType.Barrel_RecoilY);
        ArrayPush(UncommonTierModList, PreemModStyleType.Barrel_Silencer);
        ArrayPush(UncommonTierModList, PreemModStyleType.Mag_Extended);
        ArrayPush(UncommonTierModList, PreemModStyleType.Trigger_Burst);
        ArrayPush(UncommonTierModList, PreemModStyleType.Trigger_SemiAuto);
        ArrayPush(UncommonTierModList, PreemModStyleType.Trigger_FullAuto);
        ArrayPush(UncommonTierModList, PreemModStyleType.Handle_RubberizedGrip);
        return UncommonTierModList;
    }

    public final static func GetRareModStyles() -> array<PreemModStyleType>
    {
        let RareTierModList: array<PreemModStyleType>;
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Chemical);
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Electric);
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Thermal);
        ArrayPush(RareTierModList, PreemModStyleType.Blade_Chem);
        ArrayPush(RareTierModList, PreemModStyleType.Blade_Shock);
        ArrayPush(RareTierModList, PreemModStyleType.Blade_Thermal);
        ArrayPush(RareTierModList, PreemModStyleType.Mag_Bleed);
        ArrayPush(RareTierModList, PreemModStyleType.Blade_Bleed);
        return RareTierModList;
    }

    public final static func GetEpicModStyles() -> array<PreemModStyleType>
    {
        let EpicTierModList: array<PreemModStyleType>;
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_Power);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_Smart);
        ArrayPush(EpicTierModList, PreemModStyleType.Barrel_Tech);
        ArrayPush(EpicTierModList, PreemModStyleType.Trigger_Charge);
        ArrayPush(EpicTierModList, PreemModStyleType.Trigger_ChargeFullAuto);
        ArrayPush(EpicTierModList, PreemModStyleType.Blade_CritDamage);
        ArrayPush(EpicTierModList, PreemModStyleType.Blade_CritChance);
        return EpicTierModList;
    }

    public final static func GetLegendaryModStyles() -> array<PreemModStyleType>
    {
        let LegendaryTierModList: array<PreemModStyleType>;

        ArrayPush(LegendaryTierModList, PreemModStyleType.Barrel_ExtraBarrel);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Barrel_Turbo);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Barrel_SmartMultiTarget);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Barrel_SmartRangeTarget);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Trigger_InstaBurst);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Trigger_UltraAction);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Handle_Leap);
        ArrayPush(LegendaryTierModList, PreemModStyleType.Handle_Dash);
        return LegendaryTierModList;
    }

}