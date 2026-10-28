module PreemCrafting.Adapters.ItemModificationAdapter
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*

// Every vanilla part change (the weapon mod screen, stashes, Preem's own queued installs) goes
// through these two. With the Preem Silencer on a weapon, a muzzle brake goes in as its Silenced
// twin (ADR 0002 addendum); a twin or the hidden muzzle part that comes off never stays in the
// inventory: a twin gives back its plain brake, the hidden part is deleted.
@wrapMethod(ItemModificationSystem)
private final func InstallItemPart(obj: ref<GameObject>, itemID: ItemID, partItemID: ItemID, opt slotID: TweakDBID) -> Bool {
  if !IsDefined(obj) || !obj.IsPlayer() {
    return wrappedMethod(obj, itemID, partItemID, slotID);
  }
  let ts = GameInstance.GetTransactionSystem(obj.GetGame());
  let itemData = ts.GetItemData(obj, itemID);
  let previous = PreemMuzzleParts.GetPartItem(itemData);
  let part = partItemID;
  let twin = PreemMuzzleParts.TwinOf(ItemID.GetTDBID(partItemID));
  if TDBID.IsValid(twin) && PreemMuzzleParts.HasPreemSilencer(itemData) {
    ts.RemoveItem(obj, partItemID, 1);
    part = ItemID.FromTDBID(twin);
    ts.GiveItem(obj, part, 1);
  }
  let result = wrappedMethod(obj, itemID, part, slotID);
  if ItemID.IsValid(previous) && PreemMuzzleParts.GetPartItem(itemData) != previous {
    PreemMuzzleParts.TakeBack(obj, previous);
  }
  return result;
}

@wrapMethod(ItemModificationSystem)
private final const func RemoveItemPart(obj: ref<GameObject>, itemID: ItemID, slotID: TweakDBID, shouldUpdateEntity: Bool) -> ItemID {
  let removed = wrappedMethod(obj, itemID, slotID, shouldUpdateEntity);
  if IsDefined(obj) && obj.IsPlayer() {
    return PreemMuzzleParts.TakeBack(obj, removed);
  }
  return removed;
}
