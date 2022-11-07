module PreemCrafting.Adapters.InventoryManagerAdapter
import PreemCrafting.Core.*


@wrapMethod(InventoryDataManagerV2)
public final func GetAttachmentSlotsForInventory() -> array<TweakDBID>{
  let allowedSlotIDs: array<TweakDBID> = wrappedMethod();
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBarrelMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBarrelMod02");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemTriggerMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemTriggerMod02");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemMagazineMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemMagazineMod02");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBladeMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBladeMod02");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemHandleMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemHandleMod02");
  return allowedSlotIDs;
}

@wrapMethod(InventoryDataManagerV2)
private final func IsAttachmentDedicated(slotID: TweakDBID) -> Bool {
    return wrappedMethod(slotID) || slotID == t"AttachmentSlots.PreemBarrelMod01" || slotID == t"AttachmentSlots.PreemBarrelMod02" || slotID == t"AttachmentSlots.PreemTriggerMod01" || slotID == t"AttachmentSlots.PreemTriggerMod02" || slotID == t"AttachmentSlots.PreemMagazineMod01" || slotID == t"AttachmentSlots.PreemMagazineMod02" || slotID == t"AttachmentSlots.PreemBladeMod01" || slotID == t"AttachmentSlots.PreemBladeMod02" || slotID == t"AttachmentSlots.PreemHandleMod01" || slotID == t"AttachmentSlots.PreemHandleMod02";
}

@wrapMethod(UIInventoryItemModsStaticData)
public final func GetAttachmentSlots(itemType: gamedataItemType) -> array<TweakDBID> {
  let allowedSlotIDs: array<TweakDBID> = wrappedMethod(itemType);
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBarrelMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBarrelMod02");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemTriggerMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemTriggerMod02");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemMagazineMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemMagazineMod02");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBladeMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBladeMod02");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemHandleMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemHandleMod02");
  return allowedSlotIDs;
}

@wrapMethod(UIInventoryItemModsStaticData)
public final func IsAttachmentDedicated(slotID: TweakDBID) -> Bool {
    return wrappedMethod(slotID) || slotID == t"AttachmentSlots.PreemBarrelMod01" || slotID == t"AttachmentSlots.PreemBarrelMod02" || slotID == t"AttachmentSlots.PreemTriggerMod01" || slotID == t"AttachmentSlots.PreemTriggerMod02" || slotID == t"AttachmentSlots.PreemMagazineMod01" || slotID == t"AttachmentSlots.PreemMagazineMod02" || slotID == t"AttachmentSlots.PreemBladeMod01" || slotID == t"AttachmentSlots.PreemBladeMod02" || slotID == t"AttachmentSlots.PreemHandleMod01" || slotID == t"AttachmentSlots.PreemHandleMod02";
  }