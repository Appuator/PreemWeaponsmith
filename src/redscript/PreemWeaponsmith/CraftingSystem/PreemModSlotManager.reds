module PreemCrafting.CraftingSystem.ModSlotManager
import PreemCrafting.Core.*
import PreemCrafting.PreemUI.*

public class PreemModSlotManager
{
    protected let slotIDs: array<CName>;

    protected let PreemModSlots: array<ref<PreemModSlot>>;

    public let currSelectedPreemSlot: ref<PreemModSlot>;

    public func CanInstallPreemModInSlot(preemMod: ref<PreemMod>, slot: ref<PreemSlot>) -> Bool 
    {
        let canInstall: Bool = true;

        if !IsDefined(preemMod) || !IsDefined(slot)
        {
            return false;
        }

        if(Equals(preemMod.preemClassType, slot.preemClassType))
        {
            canInstall = true;

            for mod in preemMod.GetRequiredMods()
            {
                if(!ArrayContains(PreemModSlotManager.GetModTypes(this.GetCurrentSlottedMods()), mod))
                {
                    canInstall = false;
                }
            }
        }
        else
        {
            canInstall = false;
        }

        return canInstall;
    }

    public func GetCurrentSlottedMods() -> array<ref<PreemMod>> 
    {
        let modList: array<ref<PreemMod>>;

        for slot in this.PreemModSlots
        {
            let slottedMod = slot.GetSlotData().GetSlottedMod();

            if(IsDefined(slottedMod) && NotEquals(slottedMod.GetModName(),n"None"))
            {
                ArrayPush(modList,slottedMod);
            }
        }

        return modList;
    }

    public func ClearCurrentSlots() -> Void
    {
        let noneMod: ref<PreemMod>;

        for slot in this.PreemModSlots
        {
            slot.InstallPreemMod(noneMod);
        }
    }

    public static func GetModTypes(modList: array<ref<PreemMod>>) -> array<PreemModStyleType>
    {
        let modStyleList: array<PreemModStyleType>;
        for mod in modList
        {
            ArrayPush(modStyleList, mod.modStyleType);
        }

        return modStyleList;
    }

    public func SetCurrentlySelectedPreemSlot( selectedSlot: ref<PreemModSlot>){
        this.currSelectedPreemSlot = selectedSlot;
    }

    public func GetCurrentlySelectedPreemSlot() -> ref<PreemModSlot>{
        return this.currSelectedPreemSlot;
    }

    public func InstallMod(selectedMod: ref<PreemMod>){
        let slotData = this.GetCurrentlySelectedPreemSlot().GetSlotData();
        slotData.InstallMod(selectedMod);

        this.currSelectedPreemSlot.SetSlotData(slotData);
    }

    public func AddModSlot(slot: ref<PreemModSlot>){
        ArrayPush(this.PreemModSlots, slot);
    }

}