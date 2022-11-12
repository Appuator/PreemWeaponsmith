module PreemCrafting.CraftingSystem.PreemModMaker
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModInstaller.*

public class PreemModMaker
{

    public static func GetModsFromClassType(classType: PreemModClassType) -> array<ref<PreemMod>>
    {
        let preemModList: array<ref<PreemMod>>;

        switch classType {
            case PreemModClassType.Barrel:
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_ExtraBarrel));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Recoil));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Smart));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Tech));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_RecoilY));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Turbo));
                //ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Barrel_Atomizer));
                break;
            case PreemModClassType.Trigger:
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Trigger_SemiAuto));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Trigger_FullAuto));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Trigger_Burst));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Trigger_Charge));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Trigger_ChargeFullAuto));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Trigger_InstaBurst));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Trigger_UltraAction));
                break;
            case PreemModClassType.Mag:
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Thermal));  
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Electric));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Chemical));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Extended));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Bleed));
                break;
            case PreemModClassType.Blade:
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Blade_Chem));  
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Blade_Shock));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Blade_Thermal));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Blade_Bleed));
                break;
            case PreemModClassType.Handle:
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Handle_RubberizedGrip));
                break;
        }

        return preemModList;
    }

    public static func GetModFromModStyleType(modStyleType: PreemModStyleType) -> ref<PreemMod>
    {
        let newMod = new PreemMod();
        newMod.modStyleType = modStyleType;
        newMod.SetDescription("a description of what the mod does");
        newMod.SetAdditionalDescription("fluff description");

        switch modStyleType {

            case PreemModStyleType.Barrel_ExtraBarrel:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Xtra Barrel");
                newMod.SetDescription("x2 to weapon projectiles per shot,\n reduces fire rate by 30%");
                newMod.SetAdditionalDescription("Thanks to Militech's top engineers, the equation for \"how to get the most lead down range\" has been solved. +1 barrel = x2 lead");
                break;

            case PreemModStyleType.Barrel_Recoil:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Compensator Barrel");
                newMod.SetDescription("Reduces recoil by 60%");
                newMod.SetAdditionalDescription("The integral compensator system by Arasaka is equipped with our blowback-absorption technology used in our very own superior weapons.\n\nWhen it comes precision, you can always trust Arasaka.");
                break;

            case PreemModStyleType.Barrel_Smart:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Smart Barrel");
                newMod.SetDescription("Gives Smart gun capabilites");
                newMod.SetAdditionalDescription("Kang Tao's Smart-Link ensures there is NO human error. And our privacy policy assures users that Kang Tao is NOT monitoring their personal Smart-Link feeds, other than for quality assurance of course");
                break;

            case PreemModStyleType.Barrel_Tech:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Tech Barrel");
                newMod.AddRequiredMod(PreemModStyleType.Trigger_Charge);
                newMod.SetDescription("Gives Tech gun capabilites");
                newMod.SetAdditionalDescription("In collaboration with some of the world's top militaries, Militech's Tech Weapons System uses electromagnetic forces to fire rounds beyond any power level conventional weapons could reach. Militech is also not liable for any collateral damage the user will most likely cause.");
                break;
            case PreemModStyleType.Barrel_RecoilY:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Vented Barrel");
                newMod.SetDescription("Eliminates horizontal recoil");
                newMod.SetAdditionalDescription("By re-routing the expelled gases during fire Arasaka has eliminated any trajectory variance on the x-axis, and developed another flawless weapons system.");
                break;
            case PreemModStyleType.Barrel_Turbo:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Turbo Barrel");
                newMod.SetDescription("increases fire rate by 30%");
                newMod.SetAdditionalDescription("Arasaka has developed the coolest barrel on the market, literally. Our super-cooling technology allows the user to push their weapons past the usual manufacturer's factory limits");
                break;
            case PreemModStyleType.Barrel_Atomizer:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Atomizer Barrel");
                newMod.SetDescription("a description of what the mod does");
                newMod.SetAdditionalDescription("fluff description");
                break;

            //////Trigger Mods

            case PreemModStyleType.Trigger_FullAuto:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Full-Auto Fire");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Burst);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Charge);
                newMod.SetDescription("Makes weapon fire Full-Auto");
                newMod.SetAdditionalDescription("The ting goes SKRRRAHH! PAP,PAP KA-KA-KA! SKIDIKI-PAP-PAP! PU-PU-PUDRRRR-BOOM! SKYA! DU-DU-KU-KU-DUN-DUN! POOM POOM!");                
                break;

            case PreemModStyleType.Trigger_SemiAuto:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Semi-Auto Fire");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Burst);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Charge);
                newMod.SetDescription("Makes weapon fire Semi-Auto");
                newMod.SetAdditionalDescription("If you don't know what Semi-Auto means, you probably shouldn't be making this weapon");
                break;

            case PreemModStyleType.Trigger_Burst:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Burst Fire");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Charge);
                newMod.SetDescription("Makes weapon fire 3-round bursts");
                newMod.SetAdditionalDescription("They say good things come in threes. The guy you're shooting this at would probably disagree");
                break;
            case PreemModStyleType.Trigger_Charge:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Tech Trigger");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Burst);
                newMod.AddRequiredMod(PreemModStyleType.Barrel_Tech);
                newMod.SetDescription("Makes weapon Charge fire");
                newMod.SetAdditionalDescription("In collaboration with some of the world's top militaries, Militech's Tech Weapons System uses electromagnetic forces to fire rounds beyond any power level conventional weapons could reach.\n\n Militech is also not liable for any collateral damage the user will most likely cause.");
                break;
            case PreemModStyleType.Trigger_ChargeFullAuto:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Tech Full-Auto");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Burst);
                newMod.AddRequiredMod(PreemModStyleType.Trigger_Charge);
                newMod.SetRequiredEvolution(gamedataWeaponEvolution.Tech);
                newMod.SetDescription("Makes weapon fire full-auto after charge");
                newMod.SetAdditionalDescription("Arasaka has greatly improved upon the rudimentary designs of our competitor's Tech Weapons System technology, allowing the weapon to charge the next round using the energy generated from firing the first");
                break;
            case PreemModStyleType.Trigger_InstaBurst:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Insta-Burst");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Charge);
                newMod.AddRequiredMod(PreemModStyleType.Trigger_Burst);
                newMod.SetDescription("Makes weapon bursts fire almost instantly");
                newMod.SetAdditionalDescription("We at Militech have heard your feedback. Our burst-fire weapons will now come with an option to toggle off the safety-setting limiting burst-cycle times for our more... impatient customers");
                break;
            case PreemModStyleType.Trigger_UltraAction:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Ultra-Action");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Charge);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Burst);
                newMod.AddRequiredMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.SetDescription("Fire as fast as you can pull the trigger");
                newMod.SetAdditionalDescription("An innovation based on previous double-action trigger methods, Malorian Arms presents the Ultra-Action trigger. Allowing our users the ability operate their weapon's firing mechanism as fast as their body, or implants, allow");
                break;

            ////////Mag

            case PreemModStyleType.Mag_Thermal:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Thermal Rounds");
                newMod.AddIncompatMod(PreemModStyleType.Mag_Chemical);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Electric);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Bleed);
                newMod.SetDescription("Gives weapon 25% chance to cause Burn");
                newMod.SetAdditionalDescription("Many fail to recognize the art of warfare, but not Tsunami. Our customers deserve a weapon that allows them to truly express themselves.\n\n That is why we have made our Elemental Rounds available to all weapons manufacturers, after paying the proper licensing fees first, of course");
                break;

            case PreemModStyleType.Mag_Electric:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Shock Rounds");
                newMod.AddIncompatMod(PreemModStyleType.Mag_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Chemical);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Bleed);
                newMod.SetDescription("Gives weapon 25% chance to cause Electrocute");
                newMod.SetAdditionalDescription("Many fail to recognize the art of warfare, but not Tsunami. Our customers deserve a weapon that allows them to truly express themselves.\n\n That is why we have made our Elemental Rounds available to all weapons manufacturers, after paying the proper licensing fees first, of course");
                break;

            case PreemModStyleType.Mag_Chemical:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Chemical Rounds");
                newMod.AddIncompatMod(PreemModStyleType.Mag_Electric);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Bleed);
                newMod.SetDescription("Gives weapon 25% chance to cause Poison");
                newMod.SetAdditionalDescription("Many fail to recognize the art of warfare, but not Tsunami. Our customers deserve a weapon that allows them to truly express themselves.\n\n That is why we have made our Elemental Rounds available to all weapons manufacturers, after paying the proper licensing fees first, of course");
                break;
            case PreemModStyleType.Mag_Bleed:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Shredder Rounds");
                newMod.AddIncompatMod(PreemModStyleType.Mag_Electric);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Chemical);
                newMod.SetDescription("Gives weapon 25% chance to cause Bleed");
                newMod.SetAdditionalDescription("Many fail to recognize the art of warfare, but not Tsunami. Our customers deserve a weapon that allows them to truly express themselves.\n\n That is why we have made our Elemental Rounds available to all weapons manufacturers, after paying the proper licensing fees first, of course");
                break;
            case PreemModStyleType.Mag_Extended:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Extended Mag");
                newMod.SetDescription("Gives weapon 50% extra ammo in the clip");
                newMod.SetAdditionalDescription("Nothing revolutionary here. A larger mag means more bullets. Go figure.");
                break;
            
            /////Blade

            case PreemModStyleType.Blade_Chem:
                newMod.preemClassType = PreemModClassType.Blade;
                newMod.SetModName(n"Chem Blade");
                newMod.AddIncompatMod(PreemModStyleType.Blade_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Blade_Shock);
                newMod.AddIncompatMod(PreemModStyleType.Blade_Bleed);
                newMod.SetDescription("Gives weapon 25% chance to cause Poison");
                newMod.SetAdditionalDescription("In collaboration with Tsunami, Kendachi brings their cutting-edge Elemental Rounds technology to the cutting edge of your blade.");
                break;

            case PreemModStyleType.Blade_Shock:
                newMod.preemClassType = PreemModClassType.Blade;
                newMod.SetModName(n"Shock Blade");
                newMod.AddIncompatMod(PreemModStyleType.Blade_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Blade_Chem);
                newMod.AddIncompatMod(PreemModStyleType.Blade_Bleed);
                newMod.SetDescription("Gives weapon 25% chance to cause Electrocute");
                newMod.SetAdditionalDescription("In collaboration with Tsunami, Kendachi brings their cutting-edge Elemental Rounds technology to the cutting edge of your blade.");
                break;

            case PreemModStyleType.Blade_Thermal:
                newMod.preemClassType = PreemModClassType.Blade;
                newMod.SetModName(n"Thermal Blade");
                newMod.AddIncompatMod(PreemModStyleType.Blade_Shock);
                newMod.AddIncompatMod(PreemModStyleType.Blade_Chem);
                newMod.AddIncompatMod(PreemModStyleType.Blade_Bleed);
                newMod.SetDescription("Gives weapon 25% chance to cause Burn");
                newMod.SetAdditionalDescription("In collaboration with Tsunami, Kendachi brings their cutting-edge Elemental Rounds technology to the cutting edge of your blade.");
                break;
            case PreemModStyleType.Blade_Bleed:
                newMod.preemClassType = PreemModClassType.Blade;
                newMod.SetModName(n"Sharp Blade");
                newMod.AddIncompatMod(PreemModStyleType.Blade_Shock);
                newMod.AddIncompatMod(PreemModStyleType.Blade_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Blade_Chem);
                newMod.SetDescription("Gives weapon 25% chance to cause Bleed");
                newMod.SetAdditionalDescription("In collaboration with Tsunami, Kendachi brings their cutting-edge Elemental Rounds technology to the cutting edge of your blade.");
                break;


            //////Handle

            case PreemModStyleType.Handle_RubberizedGrip:
                newMod.preemClassType = PreemModClassType.Handle;
                newMod.SetModName(n"RubberizedGrip");
                newMod.SetDescription("adds +1 hit to a weapon's combo");
                newMod.SetAdditionalDescription("The material used in Kendachi's rubberized grip helps users keep their weapon in hand so they mantain the upper hand in battle.");
                break;

            default:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"TestMod1");
        }

        return newMod;
    }

    public static func GetFullDescriptionFromPreemMod(preemMod: ref<PreemMod>) -> String
    {
        let fulldesc: String = "";

        fulldesc += preemMod.GetDescription();
        fulldesc += "\n";


        if(ArraySize(preemMod.requiredMods) > 0)
        {
            fulldesc += "\nREQUIRED MODS:\n";

            for mod in preemMod.requiredMods
            {
                fulldesc += NameToString(PreemModMapper.GetModNameFromPreemModStyleType(mod));
                fulldesc += "\n";
            }
        }

        if(ArraySize(preemMod.incompatMods) > 0)
        {
            fulldesc += "\nINCOMPATIBLE MODS:\n";

            for mod in preemMod.incompatMods
            {
                fulldesc += NameToString(PreemModMapper.GetModNameFromPreemModStyleType(mod));
                fulldesc += "\n";
            }
        }

        if(NotEquals(preemMod.GetAdditionalDescription(),""))
        {
            fulldesc += "\nDetails:\n";
            fulldesc += preemMod.GetAdditionalDescription();
        }
        
        return fulldesc;
    }   
}