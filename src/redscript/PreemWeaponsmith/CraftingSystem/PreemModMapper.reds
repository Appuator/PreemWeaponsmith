module PreemCrafting.CraftingSystem.ModInstaller
import PreemCrafting.Core.*

public class PreemModMapper
{

    public func GetGameModFromPreemMod(preemMod: ref<PreemMod>) -> ItemID{
        let itemMod: ItemID;
        let gameModID: TweakDBID;
        let preemModStyle: PreemModStyleType;
        preemModStyle = preemMod.modStyleType;
        switch preemModStyle {
            case PreemModStyleType.Barrel_ExtraBarrel:    gameModID = t"Items.PreemBarrelModExtraBarrel";
                break;
            case PreemModStyleType.Barrel_Recoil:    gameModID = t"Items.PreemBarrelModRecoil";
                break;
            case PreemModStyleType.Barrel_Smart:       gameModID = t"Items.PreemBarrelModSmart";
                break;
            case PreemModStyleType.Barrel_Tech:       gameModID = t"Items.PreemBarrelModTech";
                break;
            case PreemModStyleType.Barrel_RecoilY:       gameModID = t"Items.PreemBarrelModRecoilY";
                break;
            case PreemModStyleType.Barrel_Turbo:       gameModID = t"Items.PreemBarrelModTurbo";
                break;
            case PreemModStyleType.Barrel_Atomizer:       gameModID = t"Items.PreemBarrelModAtomizer";
                break;
            //Trigger
            case PreemModStyleType.Trigger_FullAuto:    gameModID = t"Items.PreemTriggerModFullAuto";
                break;
            case PreemModStyleType.Trigger_SemiAuto:    gameModID = t"Items.PreemTriggerModSemiAuto";
                break;
            case PreemModStyleType.Trigger_Burst:    gameModID = t"Items.PreemTriggerModBurst";
                break;
            case PreemModStyleType.Trigger_Charge:    gameModID = t"Items.PreemTriggerModCharge";
                break;
            case PreemModStyleType.Trigger_ChargeFullAuto:    gameModID = t"Items.PreemTriggerModChargeFullAuto";
                break;
            case PreemModStyleType.Trigger_InstaBurst:    gameModID = t"Items.PreemTriggerModInstaBurst";
                break;
            case PreemModStyleType.Trigger_UltraAction:    gameModID = t"Items.PreemTriggerModUltraAction";
                break;
            //Mag
            case PreemModStyleType.Mag_Thermal:    gameModID = t"Items.PreemMagazineModThermalRounds";
                break;
            case PreemModStyleType.Mag_Electric:    gameModID = t"Items.PreemMagazineModElectricalRounds";
                break;
            case PreemModStyleType.Mag_Chemical:    gameModID = t"Items.PreemMagazineModChemicalRounds";
                break;
            case PreemModStyleType.Mag_Extended:    gameModID = t"Items.PreemMagazineModExtendedMag";
                break;
            case PreemModStyleType.Mag_Bleed:       gameModID = t"Items.PreemMagazineModBleedRounds";
                break;
            //Blade
            case PreemModStyleType.Blade_Chem:       gameModID = t"Items.PreemBladeModChemBlade";
                break;
            case PreemModStyleType.Blade_Shock:       gameModID = t"Items.PreemBladeModShockBlade";
                break;
            case PreemModStyleType.Blade_Thermal:       gameModID = t"Items.PreemBladeModThermalBlade";
                break;
            case PreemModStyleType.Blade_Bleed:       gameModID = t"Items.PreemBladeModBleedBlade";
                break;
            //Handle
            case PreemModStyleType.Handle_RubberizedGrip:       gameModID = t"Items.PreemHandleModRubberizedGrip";
                break;
            default:
                gameModID = t"Items.TestMod1";
        }

        itemMod = ItemID.FromTDBID(gameModID);

        return itemMod;
    }

    public func GetGameModSlotFromPreemMod(preemMod: ref<PreemMod>) -> TweakDBID{
        let slotID: TweakDBID;
        let preemModClass: PreemModClassType;

        preemModClass = preemMod.preemClassType;
        switch preemModClass {
            case PreemModClassType.Barrel:    slotID = t"AttachmentSlots.PreemBarrelMod01";
                break;
            case PreemModClassType.Trigger:    slotID = t"AttachmentSlots.PreemTriggerMod01";
                break;
            case PreemModClassType.Mag:    slotID = t"AttachmentSlots.PreemMagazineMod01";
                break;
            case PreemModClassType.Blade:    slotID = t"AttachmentSlots.PreemBladeMod01";
                break;
            case PreemModClassType.Handle:    slotID = t"AttachmentSlots.PreemHandleMod01";
                break;
            default:
                slotID = t"AttachmentSlots.PreemBarrelMod01";
        }
        return slotID;
    }

    public func GetGameModSlotListFromPreemMod(preemMod: ref<PreemMod>) -> array<TweakDBID>{
        let slotIDList: array<TweakDBID>;
        let preemModClass: PreemModClassType;

        preemModClass = preemMod.preemClassType;
        switch preemModClass {
            case PreemModClassType.Barrel:    
            ArrayPush(slotIDList,t"AttachmentSlots.PreemBarrelMod01");
            ArrayPush(slotIDList,t"AttachmentSlots.PreemBarrelMod02");
                break;
            case PreemModClassType.Trigger:    
            ArrayPush(slotIDList,t"AttachmentSlots.PreemTriggerMod01");
            ArrayPush(slotIDList,t"AttachmentSlots.PreemTriggerMod02");
                break;
            case PreemModClassType.Mag:    
            ArrayPush(slotIDList,t"AttachmentSlots.PreemMagazineMod01");
            ArrayPush(slotIDList,t"AttachmentSlots.PreemMagazineMod02");
                break;
            case PreemModClassType.Blade:    
            ArrayPush(slotIDList,t"AttachmentSlots.PreemBladeMod01");
            ArrayPush(slotIDList,t"AttachmentSlots.PreemBladeMod02");
                break;
            case PreemModClassType.Handle:    
            ArrayPush(slotIDList,t"AttachmentSlots.PreemHandleMod01");
            ArrayPush(slotIDList,t"AttachmentSlots.PreemHandleMod02");
                break;
            default:
                ArrayPush(slotIDList,t"AttachmentSlots.PreemBarrelMod01");
                ArrayPush(slotIDList,t"AttachmentSlots.PreemBarrelMod02");
        }
        
        return slotIDList;
    }
}