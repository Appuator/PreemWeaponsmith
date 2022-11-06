module PreemCrafting.CraftingSystem.PreemModMaker
import PreemCrafting.Core.*

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
                break;
            case PreemModClassType.Mag:
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Thermal));  
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Electric));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Chemical));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Extended));
                ArrayPush(preemModList, PreemModMaker.GetModFromModStyleType(PreemModStyleType.Mag_Bleed));
                break;
        }

        return preemModList;
    }

    public static func GetModFromModStyleType(modStyleType: PreemModStyleType) -> ref<PreemMod>
    {
        let newMod = new PreemMod();
        newMod.modStyleType = modStyleType;

        switch modStyleType {

            case PreemModStyleType.Barrel_ExtraBarrel:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Xtra Barrel");
                break;

            case PreemModStyleType.Barrel_Recoil:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Compensator Barrel");
                break;

            case PreemModStyleType.Barrel_Smart:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Smart Barrel");
                break;

            case PreemModStyleType.Barrel_Tech:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Tech Barrel");
                newMod.AddRequiredMod(PreemModStyleType.Trigger_Charge);
                break;
            case PreemModStyleType.Barrel_RecoilY:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Vented Barrel");
                break;
            case PreemModStyleType.Barrel_Turbo:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Turbo Barrel");
                break;
            case PreemModStyleType.Barrel_Atomizer:
                newMod.preemClassType = PreemModClassType.Barrel;
                newMod.SetModName(n"Atomizer Barrel");
                break;

            //////Trigger Mods

            case PreemModStyleType.Trigger_FullAuto:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Full-Auto Fire");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Burst);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Charge);
                break;

            case PreemModStyleType.Trigger_SemiAuto:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Semi-Auto Fire");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Burst);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Charge);
                break;

            case PreemModStyleType.Trigger_Burst:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Burst Fire");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Charge);
                break;
            case PreemModStyleType.Trigger_Charge:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"Tech Trigger");
                newMod.AddIncompatMod(PreemModStyleType.Trigger_FullAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_SemiAuto);
                newMod.AddIncompatMod(PreemModStyleType.Trigger_Burst);
                newMod.AddRequiredMod(PreemModStyleType.Barrel_Tech);
                break;

            ////////Mag

            case PreemModStyleType.Mag_Thermal:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Thermal Rounds");
                newMod.AddIncompatMod(PreemModStyleType.Mag_Chemical);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Electric);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Bleed);
                break;

            case PreemModStyleType.Mag_Electric:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Shock Rounds");
                newMod.AddIncompatMod(PreemModStyleType.Mag_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Chemical);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Bleed);
                break;

            case PreemModStyleType.Mag_Chemical:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Chemical Rounds");
                newMod.AddIncompatMod(PreemModStyleType.Mag_Electric);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Bleed);
                break;
            case PreemModStyleType.Mag_Bleed:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Shredder Rounds");
                newMod.AddIncompatMod(PreemModStyleType.Mag_Electric);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Thermal);
                newMod.AddIncompatMod(PreemModStyleType.Mag_Chemical);
                break;
            case PreemModStyleType.Mag_Extended:
                newMod.preemClassType = PreemModClassType.Mag;
                newMod.SetModName(n"Extended Mag");
                break;

            default:
                newMod.preemClassType = PreemModClassType.Trigger;
                newMod.SetModName(n"TestMod1");
        }

        return newMod;
    }
}