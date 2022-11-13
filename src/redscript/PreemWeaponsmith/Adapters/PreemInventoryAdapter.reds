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
    return wrappedMethod(slotID); //|| slotID == t"AttachmentSlots.PreemBarrelMod01" || slotID == t"AttachmentSlots.PreemBarrelMod02" || slotID == t"AttachmentSlots.PreemTriggerMod01" || slotID == t"AttachmentSlots.PreemTriggerMod02" || slotID == t"AttachmentSlots.PreemMagazineMod01" || slotID == t"AttachmentSlots.PreemMagazineMod02" || slotID == t"AttachmentSlots.PreemBladeMod01" || slotID == t"AttachmentSlots.PreemBladeMod02" || slotID == t"AttachmentSlots.PreemHandleMod01" || slotID == t"AttachmentSlots.PreemHandleMod02";
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
    return wrappedMethod(slotID); //|| slotID == t"AttachmentSlots.PreemBarrelMod01" || slotID == t"AttachmentSlots.PreemBarrelMod02" || slotID == t"AttachmentSlots.PreemTriggerMod01" || slotID == t"AttachmentSlots.PreemTriggerMod02" || slotID == t"AttachmentSlots.PreemMagazineMod01" || slotID == t"AttachmentSlots.PreemMagazineMod02" || slotID == t"AttachmentSlots.PreemBladeMod01" || slotID == t"AttachmentSlots.PreemBladeMod02" || slotID == t"AttachmentSlots.PreemHandleMod01" || slotID == t"AttachmentSlots.PreemHandleMod02";
  }

// @wrapMethod(RPGManager)
// public final static func GetAttachmentSlotIDs() -> array<TweakDBID> {
//     let result = wrappedMethod();
//     ArrayPush(result, t"AttachmentSlots.PreemBarrelMod03");
//     return result;
// }

// @wrapMethod(InventoryUtils)
// public final static func IsPart(attachmentSlotID: TweakDBID) -> Bool {
//      return wrappedMethod(attachmentSlotID) || attachmentSlotID == t"AttachmentSlots.PreemBarrelMod03";
// }

// @replaceMethod(InventoryDataManagerV2)
// public final func GetPlayerInventoryPartsDataForItem(item: ItemID, slotIDs: array<TweakDBID>) -> array<wref<gameItemData>> {
//     let availableMuzzles: array<wref<ItemPartListElement_Record>>;
//     let availableScopes: array<wref<ItemPartListElement_Record>>;
//     let canBeInstalled: Bool;
//     let currentItemRecord: wref<Item_Record>;
//     let currentPartStaticData: wref<Item_Record>;
//     let currentShardQuality: gamedataQuality;
//     let innerItemData: InnerItemData;
//     let inventoryItems: array<wref<gameItemData>>;
//     let itemQuality: gamedataQuality;
//     let itemType: gamedataItemType;
//     let j: Int32;
//     let matchAnySlot: Bool;
//     let outputItems: array<wref<gameItemData>>;
//     let parts: array<InnerItemData>;
//     let shardData: array<wref<gameItemData>>;
//     let shardType: CName;
//     let shouldAdd: Bool;
//     let slotID: TweakDBID;
//     let slotPartList: array<wref<SlotItemPartListElement_Record>>;
//     let weaponRecord: wref<WeaponItem_Record>;
//     let tempItems: array<wref<gameItemData>> = this.GetPlayerInventoryItems();
//     let i: Int32 = 0;
//     while i < ArraySize(tempItems) {
//       currentItemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(tempItems[i].GetID()));
//       if IsDefined(currentItemRecord) && currentItemRecord.IsPart() {
//         matchAnySlot = false;
//         ArrayClear(parts);
//         tempItems[i].GetItemParts(parts);
//         if ArraySize(parts) > 0 {
//           parts;
//         };
//         innerItemData = parts[0];
//         currentPartStaticData = InnerItemData.GetStaticData(innerItemData);
//         j = 0;
//         while j < ArraySize(slotIDs) {
//           if this.PlacementSlotsContains(currentPartStaticData, slotIDs[j]) {
//             matchAnySlot = true;
//             break;
//           };
//           j += 1;
//         };
//         if matchAnySlot {
//           ArrayPush(inventoryItems, tempItems[i]);
//         };
//       };
//       i += 1;
//     };
//     if Equals(RPGManager.GetItemCategory(item), gamedataItemCategory.Weapon) {
//       weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(item));
//       if GameInstance.GetTransactionSystem(this.m_Player.GetGame()).UseAlternativeCyberware() && weaponRecord.GetSlotPartList2Count() > 0 {
//         weaponRecord.SlotPartList2(slotPartList);
//       } else {
//         weaponRecord.SlotPartList(slotPartList);
//       };
//       i = 0;
//       while i < ArraySize(slotPartList) {
//         slotID = slotPartList[i].Slot().GetID();
//         if slotID == t"AttachmentSlots.PowerModule" || slotID == t"AttachmentSlots.PreemBarrelMod03" {
//           slotPartList[i].ItemPartList(availableMuzzles);
//         } else {
//           if slotID == t"AttachmentSlots.Scope" {
//             slotPartList[i].ItemPartList(availableScopes);
//           };
//         };
//         i += 1;
//       };
//       i = ArraySize(inventoryItems) - 1;
//       while i >= 0 {
//         itemType = inventoryItems[i].GetItemType();
//         if Equals(itemType, gamedataItemType.Prt_Scope) || Equals(itemType, gamedataItemType.Prt_Muzzle) || Equals(itemType, gamedataItemType.Prt_HandgunMuzzle) || Equals(itemType, gamedataItemType.Prt_RifleMuzzle) {
//           canBeInstalled = false;
//           j = 0;
//           while j < ArraySize(availableMuzzles) {
//             if inventoryItems[i].GetID() == availableMuzzles[j].Item().GetID() {
//               canBeInstalled = true;
//             };
//             j += 1;
//           };
//           j = 0;
//           while j < ArraySize(availableScopes) {
//             if inventoryItems[i].GetID() == availableScopes[j].Item().GetID() {
//               canBeInstalled = true;
//             };
//             j += 1;
//           };
//           if !canBeInstalled {
//             ArrayRemove(inventoryItems, inventoryItems[i]);
//           };
//         };
//         i -= 1;
//       };
//     };
//     if GameInstance.GetTransactionSystem(this.m_Player.GetGame()).HasTag(this.m_Player, n"Cyberdeck", item) {
//       i = 0;
//       while i < ArraySize(inventoryItems) {
//         shouldAdd = true;
//         itemQuality = RPGManager.GetItemDataQuality(inventoryItems[i]);
//         shardType = TweakDBInterface.GetCName(ItemID.GetTDBID(inventoryItems[i].GetID()) + t".shardType", n"None");
//         if NotEquals(shardType, n"None") {
//           if ItemModificationSystem.HasBetterShardInstalled(this.m_Player, item, inventoryItems[i].GetID()) {
//           } else {
//             j = 0;
//             while j < ArraySize(shardData) {
//               if Equals(shardType, TweakDBInterface.GetCName(ItemID.GetTDBID(shardData[j].GetID()) + t".shardType", n"None")) {
//                 currentShardQuality = RPGManager.GetItemDataQuality(shardData[j]);
//                 if currentShardQuality < itemQuality {
//                   shardData[j] = inventoryItems[i];
//                 };
//                 shouldAdd = false;
//                 break;
//               };
//               j += 1;
//             };
//             if shouldAdd {
//               ArrayPush(shardData, inventoryItems[i]);
//             };
//           };
//         };
//         if shouldAdd {
//           ArrayPush(shardData, inventoryItems[i]);
//         };
//         i += 1;
//       };
//       inventoryItems = shardData;
//     };
//     i = 0;
//     while i < ArraySize(inventoryItems) {
//       ArrayPush(outputItems, inventoryItems[i]);
//       i += 1;
//     };
//     return outputItems;
// }