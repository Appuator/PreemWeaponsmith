module PreemCrafting.Adapters.ItemDataAdapter
import PreemCrafting.Core.*


@addMethod(gameItemData)
public func DoesItemHaveSmartBarrel() -> Bool
{
    let slotID1 = t"AttachmentSlots.PreemBarrelMod01";
    let slotID2 = t"AttachmentSlots.PreemBarrelMod02";
    let slotIDsList: array<TweakDBID>;
    ArrayPush(slotIDsList,slotID1);
    ArrayPush(slotIDsList,slotID2);

    let hasMod = this.DoesItemHavePreemMod(slotIDsList, t"Items.PreemBarrelModSmart");

    return hasMod;
}

@addMethod(gameItemData)
public func DoesItemHavePreemMod(slotIDs: array<TweakDBID>, modID: TweakDBID) -> Bool
{
    let hasMod: Bool = false;
    let ModData1: InnerItemData;
    for slotID in slotIDs{

        if(this.HasPartInSlot(slotID)){
            this.GetItemPart(ModData1,slotID);
        }

        if (ItemID.IsOfTDBID(InnerItemData.GetItemID(ModData1),modID))
        {
            return true;
        }
    }

    return hasMod;
}

@addMethod(gameItemData)
public func DoesItemHaveTechBarrel() -> Bool
{
    let slotID1 = t"AttachmentSlots.PreemBarrelMod01";
    let slotID2 = t"AttachmentSlots.PreemBarrelMod02";
    let slotIDsList: array<TweakDBID>;
    ArrayPush(slotIDsList,slotID1);
    ArrayPush(slotIDsList,slotID2);

    let hasMod = this.DoesItemHavePreemMod(slotIDsList, t"Items.PreemBarrelModTech");

    return hasMod;
}

@addMethod(gameItemData)
public func DoesItemHavePowerBarrel() -> Bool
{
    let slotID1 = t"AttachmentSlots.PreemBarrelMod01";
    let slotID2 = t"AttachmentSlots.PreemBarrelMod02";
    let slotIDsList: array<TweakDBID>;
    ArrayPush(slotIDsList,slotID1);
    ArrayPush(slotIDsList,slotID2);

    let hasMod = this.DoesItemHavePreemMod(slotIDsList, t"Items.PreemBarrelModPower");

    return hasMod;
}

@addMethod(gameItemData)
public func DoesItemHaveSilencer() -> Bool
{
    let slotID1 = t"AttachmentSlots.PreemBarrelMod01";
    let slotID2 = t"AttachmentSlots.PreemBarrelMod02";
    //let slotID3 = t"AttachmentSlots.PowerModule2";
    let slotIDsList: array<TweakDBID>;
    ArrayPush(slotIDsList,slotID1);
    ArrayPush(slotIDsList,slotID2);
    //ArrayPush(slotIDsList,slotID3);

    let hasMod = this.DoesItemHavePreemMod(slotIDsList, t"Items.PreemBarrelModSilencer");

    return hasMod;
}

@addMethod(gameItemData)
public func DoesItemHaveBoosterHandle() -> Bool
{
    let slotID1 = t"AttachmentSlots.PreemHandleMod01";
    let slotID2 = t"AttachmentSlots.PreemHandleMod02";
    let slotIDsList: array<TweakDBID>;
    ArrayPush(slotIDsList,slotID1);
    ArrayPush(slotIDsList,slotID2);

    let hasMod = this.DoesItemHavePreemMod(slotIDsList, t"Items.PreemHandleModBoosterHandle");

    return hasMod;
}

// @addMethod(gameItemData)
// public func DoesItemHaveAtomizerBarrel() -> Bool
// {
//     let slotID1 = t"AttachmentSlots.PreemBarrelMod01";
//     let slotID2 = t"AttachmentSlots.PreemBarrelMod02";
//     let slotIDsList: array<TweakDBID>;
//     ArrayPush(slotIDsList,slotID1);
//     ArrayPush(slotIDsList,slotID2);

//     let hasMod = this.DoesItemHavePreemMod(slotIDsList, t"Items.PreemBarrelModAtomizer");

//     return hasMod;
// }