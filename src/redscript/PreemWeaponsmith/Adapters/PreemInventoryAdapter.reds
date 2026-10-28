module PreemCrafting.Adapters.InventoryManagerAdapter
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*


@wrapMethod(InventoryDataManagerV2)
public final func GetAttachmentSlotsForInventory() -> array<TweakDBID>{
  let allowedSlotIDs: array<TweakDBID> = wrappedMethod();
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBarrelMod01");
  ArrayPush(allowedSlotIDs,t"AttachmentSlots.PreemBarrelMod02");
  //ArrayPush(allowedSlotIDs,t"AttachmentSlots.PowerModule2");
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
  //ArrayPush(allowedSlotIDs,t"AttachmentSlots.PowerModule2");
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

// A weapon with no vanilla muzzle has the muzzle slot only for the Silencer's hidden part
// (PreemMuzzleParts.HidesMuzzleSlot): the vanilla mod screen and tooltips leave that slot out, so
// the part is neither shown nor removable there. The part stays in the slot (the sound needs it).
@wrapMethod(UIInventoryItemModsManager)
private final func GetAttachements(owner: wref<GameObject>, inventoryItem: wref<UIInventoryItem>) -> Void {
  if IsDefined(inventoryItem) && PreemMuzzleParts.HidesMuzzleSlot(ItemID.GetTDBID(inventoryItem.GetID())) {
    ArrayRemove(this.m_usedSlots, t"AttachmentSlots.PowerModule");
    ArrayRemove(this.m_emptySlots, t"AttachmentSlots.PowerModule");
  }
  wrappedMethod(owner, inventoryItem);
}

@wrapMethod(InventoryDataManagerV2)
public final func GetAttachements(owner: wref<GameObject>, itemId: ItemID, itemData: wref<gameItemData>, attachments: script_ref<[ref<InventoryItemAttachments>]>, abilities: script_ref<[InventoryItemAbility]>, opt isDryItem: Bool) -> Void {
  wrappedMethod(owner, itemId, itemData, attachments, abilities, isDryItem);
  if PreemMuzzleParts.HidesMuzzleSlot(ItemID.GetTDBID(itemId)) {
    let i = ArraySize(Deref(attachments)) - 1;
    while i >= 0 {
      if Deref(attachments)[i].SlotID == t"AttachmentSlots.PowerModule" {
        ArrayErase(Deref(attachments), i);
      }
      i -= 1;
    }
  }
}

@wrapMethod(InventoryDataManagerV2)
public final func GetAttachements(owner: wref<GameObject>, itemData: wref<gameItemData>, usedSlots: [TweakDBID], emptySlots: [TweakDBID], mods: script_ref<[ref<MinimalItemTooltipModData>]>, dedicatedMods: script_ref<[ref<MinimalItemTooltipModAttachmentData>]>) -> Void {
  if IsDefined(itemData) && PreemMuzzleParts.HidesMuzzleSlot(ItemID.GetTDBID(itemData.GetID())) {
    ArrayRemove(usedSlots, t"AttachmentSlots.PowerModule");
    ArrayRemove(emptySlots, t"AttachmentSlots.PowerModule");
  }
  wrappedMethod(owner, itemData, usedSlots, emptySlots, mods, dedicatedMods);
}
