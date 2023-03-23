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

        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Barrel_Recoil);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Barrel_RecoilY);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Barrel_Silencer);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Mag_Chemical);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Mag_Electric);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Mag_Thermal);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Handle_RubberizedGrip);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Blade_Chem);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Blade_Shock);
        ArrayPush(weaponTrueCraftsmanList, PreemModStyleType.Blade_Thermal);
        return weaponTrueCraftsmanList;
    }

    public final static func GetUnlockedWeaponGreaseMonkey() -> array<PreemModStyleType>
    {
        let weaponGreaseMonkeyList: array<PreemModStyleType>;

        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Barrel_Power);
        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Barrel_Smart);
        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Barrel_Tech);
        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Trigger_Charge);
        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Trigger_ChargeFullAuto);
        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Mag_Extended);
        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Handle_Dash);
        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Blade_CritDamage);
        ArrayPush(weaponGreaseMonkeyList, PreemModStyleType.Blade_CritChance);
        return weaponGreaseMonkeyList;
    }

    public final static func GetUnlockedWeaponEdgerunnerArtisan() -> array<PreemModStyleType>
    {
        let weaponEdgeRunnerList: array<PreemModStyleType>;

        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Barrel_ExtraBarrel);
        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Barrel_Turbo);
        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Barrel_SmartMultiTarget);
        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Barrel_SmartRangeTarget);
        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Trigger_InstaBurst);
        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Trigger_UltraAction);
        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Mag_Bleed);
        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Handle_Leap);
        ArrayPush(weaponEdgeRunnerList, PreemModStyleType.Blade_Bleed);
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

}