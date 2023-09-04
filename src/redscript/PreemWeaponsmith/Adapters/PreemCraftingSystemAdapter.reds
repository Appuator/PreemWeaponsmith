module PreemCrafting.Adapters.CraftingSystemAdapter
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
import PreemCrafting.CraftingSystem.ModInstaller.*

@addMethod(CraftingSystem)
public final func InstallPreemMod(preemMod: ref<PreemMod>, craftedItem: wref<gameItemData>, modInstaller: ref<PreemModMapper>, slotID: TweakDBID) -> Void {
    let itemModificationSystem: wref<ItemModificationSystem>;
    let transactionSystem: ref<TransactionSystem>;
    let player: wref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      transactionSystem = GameInstance.GetTransactionSystem(this.GetGameInstance());
    };

    let gameMod = modInstaller.GetGameModFromPreemMod(preemMod);

    let installPartRequest: ref<InstallItemPart>;
    installPartRequest = new InstallItemPart();
    installPartRequest.Set(player, craftedItem.GetID(), gameMod, slotID);

    itemModificationSystem = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"ItemModificationSystem") as ItemModificationSystem;
    transactionSystem.GiveItem(player, gameMod, 1);
    itemModificationSystem.QueueRequest(installPartRequest);
  }

@wrapMethod(CraftingSystem)
private final func CraftItem(target: wref<GameObject>, itemRecord: ref<Item_Record>, amount: Int32, opt ammoBulletAmount: Int32) -> wref<gameItemData> {
  let craftedItem: wref<gameItemData>;
  let modList: array<ref<PreemMod>>;
  let modTypeList: array<PreemModStyleType>;
  let preemCraftingSystem: ref<PreemCraftingSystem>;
  let newItemRecord: ref<Item_Record>;
  let rangedWeaponItemTypeList: array<gamedataItemType>;
  let meleeWeaponItemTypeList: array<gamedataItemType>;

  rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
  meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

  if(ArrayContains(rangedWeaponItemTypeList,itemRecord.ItemType().Type()) || ArrayContains(meleeWeaponItemTypeList,itemRecord.ItemType().Type()))
  {

    newItemRecord = itemRecord;
    preemCraftingSystem = PreemCraftingSystem.GetInstance(this.GetGameInstance());
    preemCraftingSystem.GetModList(modList);

    for mod in modList
    {
      ArrayPush(modTypeList, mod.modStyleType);
    }

    
    if(ArrayContains(modTypeList, PreemModStyleType.Barrel_Smart))
    {
      let weaponRecord = itemRecord as WeaponItem_Record;
      let ogEvolution = weaponRecord.Evolution().Type();
      if(NotEquals(ogEvolution, gamedataWeaponEvolution.Smart))
      {
        newItemRecord = TweakDBInterface.GetItemRecord(itemRecord.GetID() + t"_PreemSmart");
        weaponRecord = newItemRecord as WeaponItem_Record;
      }
    }
    else
    {
      if(ArrayContains(modTypeList, PreemModStyleType.Barrel_Tech))
      {
      let weaponRecord = itemRecord as WeaponItem_Record;
      let ogEvolution = weaponRecord.Evolution().Type();
        if(NotEquals(ogEvolution, gamedataWeaponEvolution.Tech))
        {
          newItemRecord = TweakDBInterface.GetItemRecord(itemRecord.GetID() + t"_PreemTech");
          weaponRecord = newItemRecord as WeaponItem_Record;
        }
      }
      else{
          if(ArrayContains(modTypeList, PreemModStyleType.Barrel_Power))
          {
          let weaponRecord = itemRecord as WeaponItem_Record;
          let ogEvolution = weaponRecord.Evolution().Type();
            if(NotEquals(ogEvolution, gamedataWeaponEvolution.Power))
            {
              newItemRecord = TweakDBInterface.GetItemRecord(itemRecord.GetID() + t"_PreemPower");
              weaponRecord = newItemRecord as WeaponItem_Record;
            }
          }
      }
    }

    craftedItem = wrappedMethod(target,newItemRecord,amount,ammoBulletAmount);
    
    if(ArraySize(modList) > 0){
      preemCraftingSystem.ApplyMods(this.GetGameInstance(), craftedItem);
      preemCraftingSystem.ClearMods();
    }
  }
  else{
    craftedItem = wrappedMethod(target,itemRecord,amount,ammoBulletAmount);
  }
  
  return craftedItem;
}


@wrapMethod(CraftingSystem)
 public final const func CanItemBeCrafted(itemData: wref<gameItemData>) -> Bool {
  let wrapresult = wrappedMethod(itemData);
  let preemCraftingSystem = PreemCraftingSystem.GetInstance(this.GetGameInstance());

  let combinedResult: Bool;

  let rangedWeaponItemTypeList: array<gamedataItemType>;
  let meleeWeaponItemTypeList: array<gamedataItemType>;

  rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
  meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

  if(ArrayContains(rangedWeaponItemTypeList,itemData.GetItemType()) || ArrayContains(meleeWeaponItemTypeList,itemData.GetItemType()))
  {
    combinedResult = wrapresult && preemCraftingSystem.CanInstallSelectedPreemMods();
  }
  else{
    combinedResult = wrapresult;
  }
   //LogChannel(n"DEBUG", s"PreemCraftingSystemItemData:: \(preemCraftingSystem.CanInstallSelectedPreemMods())");
  return combinedResult;
}

@wrapMethod(CraftingSystem)
public final const func CanItemBeCrafted(itemRecord: wref<Item_Record>) -> Bool {
    let wrapresult = wrappedMethod(itemRecord);
  let preemCraftingSystem = PreemCraftingSystem.GetInstance(this.GetGameInstance());

  let combinedResult: Bool;

  let rangedWeaponItemTypeList: array<gamedataItemType>;
  let meleeWeaponItemTypeList: array<gamedataItemType>;

  rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
  meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

  if(ArrayContains(rangedWeaponItemTypeList,itemRecord.ItemType().Type()) || ArrayContains(meleeWeaponItemTypeList,itemRecord.ItemType().Type()))
  {
    combinedResult = wrapresult && preemCraftingSystem.CanInstallSelectedPreemMods();
  }
  else{
    combinedResult = wrapresult;
  }

   //LogChannel(n"DEBUG", s"PreemCraftingSystemRecord:: \(preemCraftingSystem.CanInstallSelectedPreemMods())");
  return combinedResult;
  }

@wrapMethod(CraftingSystem)
public final const func EnoughIngredientsForCrafting(itemData: wref<gameItemData>) -> Bool {
  let wrapresult = wrappedMethod(itemData);
  let preemCraftingSystem = PreemCraftingSystem.GetInstance(this.GetGameInstance());
  let combinedResult: Bool;

  let rangedWeaponItemTypeList: array<gamedataItemType>;
  let meleeWeaponItemTypeList: array<gamedataItemType>;

  rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
  meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

  if(ArrayContains(rangedWeaponItemTypeList,itemData.GetItemType()) || ArrayContains(meleeWeaponItemTypeList,itemData.GetItemType()))
  {
    combinedResult = wrapresult && preemCraftingSystem.CanInstallSelectedPreemMods();
  }
  else{
    combinedResult = wrapresult;
  }

  return combinedResult;
}

// @wrapMethod(ItemModificationSystem)
// private final static func GetattachementFromBlueprint(blueprintRecord: wref<ItemBlueprintElement_Record>, out attachments: array<wref<AttachmentSlot_Record>>) -> Void {
//     wrappedMethod(blueprintRecord,attachments);
//     ArrayPush(attachments, TweakDBInterface.GetAttachmentSlotRecord(t"AttachmentSlots.PowerModule"));
//   }