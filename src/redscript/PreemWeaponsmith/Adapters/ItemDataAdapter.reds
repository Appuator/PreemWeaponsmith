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