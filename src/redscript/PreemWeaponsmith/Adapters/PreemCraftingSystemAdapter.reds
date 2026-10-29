module PreemCrafting.Adapters.CraftingSystemAdapter
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
import PreemCrafting.CraftingSystem.ModInstaller.*

@addMethod(CraftingSystem)
public final func InstallPreemMod(preemMod: ref<PreemMod>, craftedItem: wref<gameItemData>, modInstaller: ref<PreemModMapper>, slotID: TweakDBID) -> Void {
    this.InstallPreemPart(modInstaller.GetGameModFromPreemMod(preemMod), craftedItem, slotID);
  }

// Gives the player one of this part and queues its install in the slot (a part already there is
// replaced, and the game deletes it). Also installs the Silencer's hidden muzzle part (ADR 0002).
@addMethod(CraftingSystem)
public final func InstallPreemPart(gameMod: ItemID, craftedItem: wref<gameItemData>, slotID: TweakDBID) -> Void {
    let itemModificationSystem: wref<ItemModificationSystem>;
    let transactionSystem: ref<TransactionSystem>;
    let player: wref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      transactionSystem = GameInstance.GetTransactionSystem(this.GetGameInstance());
    };

    let installPartRequest: ref<InstallItemPart>;
    installPartRequest = new InstallItemPart();
    installPartRequest.Set(player, craftedItem.GetID(), gameMod, slotID);

    itemModificationSystem = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"ItemModificationSystem") as ItemModificationSystem;
    transactionSystem.GiveItem(player, gameMod, 1);
    itemModificationSystem.QueueRequest(installPartRequest);
  }

// Takes the Preem mod out of a slot and deletes it (mods cost nothing, so nothing is refunded;
// SPEC §2.1). Same steps as ItemModificationSystem.RemoveItemPart, which would put the mod back
// in the inventory; done directly so the returned mod item can be removed at once.
@addMethod(CraftingSystem)
public final func RemovePreemMod(item: wref<gameItemData>, slotID: TweakDBID) -> Void {
  let player: wref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
  if !IsDefined(player) || !IsDefined(item) || !item.HasPartInSlot(slotID) {
    return;
  }
  let transactionSystem = GameInstance.GetTransactionSystem(this.GetGameInstance());
  let part: InnerItemData;
  item.GetItemPart(part, slotID);
  let partID = InnerItemData.GetItemID(part);
  transactionSystem.RemovePart(player, item.GetID(), slotID, true);
  transactionSystem.RemoveItem(player, partID, 1);
  let uninstall = new PartUninstallRequest();
  uninstall.owner = player;
  uninstall.itemID = item.GetID();
  uninstall.partID = partID;
  let container = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
  container.Get(n"EquipmentSystem").QueueRequest(uninstall);
  container.Get(n"UIInventoryScriptableSystem").QueueRequest(uninstall);
}

// An upgrade keeps the item (same ItemID; vanilla raises its WasItemUpgraded stat), so the Preem
// mods chosen on the Upgrades tab go on afterwards (PreemCraftingSystem.SetUpgradeMods).
@wrapMethod(CraftingSystem)
private final func UpgradeItem(owner: wref<GameObject>, itemID: ItemID) -> Void {
  wrappedMethod(owner, itemID);
  let itemData = GameInstance.GetTransactionSystem(this.GetGameInstance()).GetItemData(owner, itemID);
  PreemCraftingSystem.GetInstance(this.GetGameInstance()).ApplyUpgradeMods(this.GetGameInstance(), itemData);
}

// A mod that replaces UpgradeItem without calling the method it wraps (Upgrade Weapons Unlocked
// does) skips ours above when its wrap is the outer one. The Upgrades tab's request handler calls
// UpgradeItem and then tells the screen the upgrade is done; if the chosen mods are still waiting
// by then, put them on now and tell the screen again so it shows them. With our wrap run, nothing
// is waiting.
@wrapMethod(CraftingSystem)
private final func OnUpgradeItemRequest(request: ref<UpgradeItemRequest>) -> Void {
  wrappedMethod(request);
  let preem = PreemCraftingSystem.GetInstance(this.GetGameInstance());
  if !preem.HasUpgradeMods(request.itemID) {
    return;
  }
  let itemData = GameInstance.GetTransactionSystem(this.GetGameInstance()).GetItemData(request.owner, request.itemID);
  preem.ApplyUpgradeMods(this.GetGameInstance(), itemData);
  this.UpdateBlackboard(CraftingCommands.UpgradingFinished, request.itemID);
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

    preemCraftingSystem = PreemCraftingSystem.GetInstance(this.GetGameInstance());
    preemCraftingSystem.GetModList(modList);

    for mod in modList
    {
      ArrayPush(modTypeList, mod.modStyleType);
    }


    newItemRecord = PreemCraftingSystem.GetCraftRecord(itemRecord, modTypeList);

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
