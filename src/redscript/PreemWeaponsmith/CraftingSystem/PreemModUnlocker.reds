module PreemCrafting.CraftingSystem.PreemModUnlocker
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModInstaller.*

public class PreemModUnlocker
{
    let devSystem: ref<PlayerDevelopmentSystem>;

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
        else{
            return true;
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

    public final static func GetPreemModUnlockReqDescription(preemModStyleType: PreemModStyleType) -> String
    {
        let unlockReqDescription: String = "\nPERK REQUIRED:\n";

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

}