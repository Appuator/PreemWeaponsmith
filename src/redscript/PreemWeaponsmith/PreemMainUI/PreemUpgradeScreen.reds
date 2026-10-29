module PreemCrafting.PreemUI
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
import PreemCrafting.Core.*
import Codeware.UI.*

// The Preem slot frame on the crafting screen's Upgrades tab (SPEC §2.1): a one-row strip under
// the two comparison tooltips, showing the selected weapon's installed Preem mods. The tab also
// lists every other owned weapon and max-tier iconics, which vanilla leaves out.
@addField(UpgradingScreenController)
private let _preemFrame: ref<PreemSlotFrame>;

@wrapMethod(UpgradingScreenController)
public func Init(craftingGameController: wref<CraftingMainGameController>) -> Void {
  wrappedMethod(craftingGameController);
  let details = inkWidgetRef.Get(this.m_itemDetailsContainer) as inkCompoundWidget;
  if !IsDefined(details) {
    return;
  }
  // The details container stretches its children, so a filling canvas holds the sized strip:
  // centred, between the comparison tooltips and the UPGRADE button (the details area ends below
  // the button, so the strip is moved up from its bottom edge).
  let area = new inkCanvas();
  area.SetName(n"preemUpgradeArea");
  area.SetAnchor(inkEAnchor.Fill);
  area.Reparent(details);
  let container = new inkCanvas();
  container.SetName(n"preemUpgradeFrame");
  container.SetAnchor(inkEAnchor.BottomCenter);
  container.SetAnchorPoint(new Vector2(0.5, 0.0));
  container.SetSize(new Vector2(1100.0, 210.0));
  container.SetTranslation(new Vector2(0.0, -380.0));
  container.Reparent(area);
  this._preemFrame = PreemSlotFrame.Create(PreemUpgradeScreenHost.Create(this), container);
  PreemCraftingSystem.GetInstance(craftingGameController.GetPlayer().GetGame()).ForgetLastApplied();
}

@addMethod(UpgradingScreenController)
public func GetPreemFrame() -> ref<PreemSlotFrame> {
  return this._preemFrame;
}

@addMethod(UpgradingScreenController)
public func GetPreemGameController() -> wref<CraftingMainGameController> {
  return this.m_craftingGameController;
}

// The selected owned weapon, or null.
@addMethod(UpgradingScreenController)
public func GetPreemSelectedItem() -> wref<gameItemData> {
  if this.m_selectedItemData.Empty {
    return null;
  }
  return InventoryItemData.GetGameItemData(this.m_selectedItemData);
}

// The weapons Preem added to the tab's list (GetPreemMissingListItems) since the list was last
// rebuilt; everything else in it was listed by the game or an upgrade mod.
@addField(UpgradingScreenController)
private let _preemAddedItems: array<ItemID>;

// Whether the hold button upgrades the item; otherwise it only applies Preem mods. The upgrade
// list decides: vanilla lists iconics below max tier, and a mod that changes what can be upgraded
// (Upgrade Weapons Unlocked: every weapon up to ++, minus what its "Only to plus" limit blocks)
// lists those instead. Not vanilla's IsUpgradable: that also says no for missing ingredients and
// never checks for an iconic.
@addMethod(UpgradingScreenController)
public func IsPreemUpgradable(item: wref<gameItemData>) -> Bool {
  if !IsDefined(item) || ArrayContains(this._preemAddedItems, item.GetID()) {
    return false;
  }
  let listed = this.m_dataSource.GetArray();
  for entry in listed {
    let data = entry as ItemCraftingData;
    if IsDefined(data) && data.inventoryItem.ID == item.GetID() {
      return true;
    }
  }
  return false;
}

// The rarity that decides the unlocked mods: after the upgrade when there is one (SPEC §2.1).
@addMethod(UpgradingScreenController)
public func GetPreemWeaponQuality() -> gamedataQuality {
  let item = this.GetPreemSelectedItem();
  if !IsDefined(item) {
    return gamedataQuality.Invalid;
  }
  return this.IsPreemUpgradable(item) ? this.GetPreemQualityAfterUpgrade(item) : RPGManager.GetItemQuality(item);
}

@if(!ModuleExists("UpgradeWeaponsUnlocked"))
@addMethod(UpgradingScreenController)
public func GetPreemQualityAfterUpgrade(item: wref<gameItemData>) -> gamedataQuality {
  return RPGManager.GetNextItemQuality(item);
}

// Upgrade Weapons Unlocked moves a weapon one step (Rare, Rare+, Epic, ...): the rarity goes up
// only from a + item, and never past Legendary (its CraftingSystem.UpgradeItem).
@if(ModuleExists("UpgradeWeaponsUnlocked"))
@addMethod(UpgradingScreenController)
public func GetPreemQualityAfterUpgrade(item: wref<gameItemData>) -> gamedataQuality {
  let quality = RPGManager.GetItemQuality(item);
  if RPGManager.GetItemPlus(item) > 0.0 && NotEquals(quality, gamedataQuality.Legendary) {
    return RPGManager.GetNextItemQuality(item);
  }
  return quality;
}

// Selecting a weapon shows its slot frame (ranged or melee) with the mods it already has.
@addMethod(UpgradingScreenController)
public func ShowPreemModsForSelection() -> Void {
  let item = this.GetPreemSelectedItem();
  if !IsDefined(this._preemFrame) || !IsDefined(item) {
    return;
  }
  let meleeTypes = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();
  if ArrayContains(meleeTypes, item.GetItemType()) {
    this._preemFrame.SetWeaponPreemFrameToMelee();
  } else {
    this._preemFrame.SetWeaponPreemFrameToRanged();
  }
  let preem = PreemCraftingSystem.GetInstance(this.m_craftingGameController.GetPlayer().GetGame());
  this._preemFrame.ShowInstalledMods(preem.GetShownMods(item));
}

@wrapMethod(UpgradingScreenController)
private final func UpdateItemPreviewPanel(const selectedItem: script_ref<InventoryItemData>) -> Void {
  wrappedMethod(selectedItem);
  // Vanilla shows nothing for an item it can't upgrade (max tier, and the non-iconic weapons it
  // counts as maxed); the mod lists them for their Preem mods, so show the item and its mods (the
  // hold button is set up by the apply step).
  let item = InventoryItemData.GetGameItemData(selectedItem);
  if !Deref(selectedItem).Empty && IsDefined(item) && !this.IsPreemUpgradable(item) {
    inkWidgetRef.SetVisible(this.m_itemDetailsContainer, true);
    this.m_selectedItemData = Deref(selectedItem);
    this.UpdateTooltipData();
    this.SetItemNames();
  }
  this.ShowPreemModsForSelection();
  this.RefreshPreemButton();
}

// The hold button: UPGRADE for an iconic below max tier (vanilla's cost and checks, and the chosen
// mods must be allowed together), APPLY for the items the mod adds (no cost, no ingredients; only
// the mods are checked).
@addMethod(UpgradingScreenController)
public func RefreshPreemButton() -> Void {
  let item = this.GetPreemSelectedItem();
  if !IsDefined(item) || !IsDefined(this._preemFrame) {
    return;
  }
  let preem = PreemCraftingSystem.GetInstance(this.m_craftingGameController.GetPlayer().GetGame());
  let record = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(item.GetID()));
  let evolution = IsDefined(record) && IsDefined(record.Evolution()) ? record.Evolution().Type() : gamedataWeaponEvolution.Invalid;
  let modsAllowed = preem.CanInstallMods(this._preemFrame.GetSlottedMods(), evolution, this.GetPreemWeaponQuality());
  let upgradable = this.IsPreemUpgradable(item);
  if upgradable {
    this.m_isCraftable = this.IsUpgradable(this.m_selectedItemData, false) && modsAllowed;
    this.m_progressButtonController.PreemSetLabel(GetLocalizedText("UI-Crafting-Upgrade"));
  } else {
    this.m_isCraftable = modsAllowed;
    this.m_progressButtonController.PreemSetLabel("APPLY");
    inkWidgetRef.SetVisible(this.m_ingredientsListContainer, false);
    inkWidgetRef.SetVisible(this.m_arrowComparison, false);
  }
  inkWidgetRef.SetVisible(this.m_blockedText, upgradable && !this.m_isCraftable);
  this.m_progressButtonController.SetAvaibility(this.m_isCraftable ? EProgressBarState.Available : EProgressBarState.Blocked);
}

// Finishing the hold: an upgradable iconic is upgraded by vanilla and gets the chosen mods after
// (CraftingSystem.UpgradeItem wrap). The items the mod adds only get the mods: vanilla's upgrade
// would charge for them and raise their tier, and vanilla never lists them, so it isn't called.
@wrapMethod(UpgradingScreenController)
protected cb func OnHoldFinished(evt: ref<ProgressBarFinishedProccess>) -> Bool {
  let item = this.GetPreemSelectedItem();
  if !this.m_isPanelOpen || !IsDefined(item) || !IsDefined(this._preemFrame) {
    return wrappedMethod(evt);
  }
  let gi = this.m_craftingGameController.GetPlayer().GetGame();
  let preem = PreemCraftingSystem.GetInstance(gi);
  if this.IsPreemUpgradable(item) {
    preem.SetUpgradeMods(item.GetID(), this._preemFrame.GetSlottedMods());
    return wrappedMethod(evt);
  }
  if !this.m_isCraftable {
    return false;
  }
  preem.ApplyModList(gi, item, this._preemFrame.GetSlottedMods());
  this.PlaySound(n"Item", n"OnCrafted");
  return true;
}

@addMethod(ProgressBarButton)
public func PreemSetLabel(text: String) -> Void {
  inkTextRef.SetText(this.m_craftingLabel, text);
}

// Vanilla lists iconic weapons below max tier. Add the player's other weapons (the types Preem
// mods fit) and max-tier iconics, each once.
@wrapMethod(UpgradingScreenController)
private final func GetUpgradableList() -> array<ref<IScriptable>> {
  let list = wrappedMethod();
  ArrayClear(this._preemAddedItems);
  for wrapper in this.GetPreemMissingListItems(list) {
    ArrayPush(list, wrapper);
  }
  return list;
}

// The weapons the Upgrades tab should list for their Preem mods and doesn't yet: every owned weapon
// of a type Preem mods fit that isn't in the list already. Each one goes in _preemAddedItems, so it
// gets APPLY, not UPGRADE (IsPreemUpgradable).
@addMethod(UpgradingScreenController)
public func GetPreemMissingListItems(listed: array<ref<IScriptable>>) -> array<ref<IScriptable>> {
  let listedIDs: array<ItemID>;
  for entry in listed {
    let data = entry as ItemCraftingData;
    if IsDefined(data) {
      ArrayPush(listedIDs, data.inventoryItem.ID);
    }
  }
  let missing: array<ref<IScriptable>>;
  let types = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
  for melee in PreemCraftingSystem.GetMeleeWeaponsItemsTypeList() {
    ArrayPush(types, melee);
  }
  for itemType in types {
    for inventoryItem in this.m_inventoryManager.GetPlayerItemsByType(itemType) {
      let item = InventoryItemData.GetGameItemData(inventoryItem);
      if IsDefined(item) && !ArrayContains(listedIDs, inventoryItem.ID) {
        let wrapper = new ItemCraftingData();
        wrapper.inventoryItem = inventoryItem;
        wrapper.isUpgradable = false;
        wrapper.isNew = this.m_craftingGameController.GetScriptableSystem().IsInventoryItemNew(inventoryItem.ID);
        ArrayPush(missing, wrapper);
        ArrayPush(listedIDs, inventoryItem.ID);
        ArrayPush(this._preemAddedItems, inventoryItem.ID);
        this.m_inventoryManager.GetOrCreateInventoryItemSortData(wrapper.inventoryItem, this.m_craftingGameController.GetScriptableSystem());
      }
    }
  }
  return missing;
}

// A mod that replaces GetUpgradableList without calling the method it wraps (Upgrade Weapons
// Unlocked does) skips ours when its wrap is the outer one, and redscript picks the order, not us.
// The list is completed here instead, after vanilla has filled the data source; with our wrap run,
// nothing is missing.
@wrapMethod(UpgradingScreenController)
public func RefreshListViewContent(opt inventoryItemData: InventoryItemData) -> Void {
  ArrayClear(this._preemAddedItems);
  wrappedMethod(inventoryItemData);
  let listed = this.m_dataSource.GetArray();
  let missing = this.GetPreemMissingListItems(listed);
  if ArraySize(missing) == 0 {
    return;
  }
  let wasEmpty = this.IsEmptyData();
  for wrapper in missing {
    this.m_dataSource.AppendItem(wrapper);
  }
  if wasEmpty {
    // Vanilla hid the panel for an empty list (HideContent); show it again for the added weapons.
    inkWidgetRef.SetVisible(this.m_progressBarContainer, true);
    inkWidgetRef.SetVisible(this.m_progressButtonContainer, true);
    let selection = inventoryItemData.Empty ? this.m_selectedItemData : inventoryItemData;
    this.UpdateItemPreviewPanel(selection);
  }
}

// The Upgrades tab as a PreemSlotFrame host.
public class PreemUpgradeScreenHost extends PreemSlotFrameHost {
  private let m_screen: wref<UpgradingScreenController>;

  public static func Create(screen: ref<UpgradingScreenController>) -> ref<PreemUpgradeScreenHost> {
    let host = new PreemUpgradeScreenHost();
    host.m_screen = screen;
    return host;
  }

  public func GetGameController() -> wref<inkGameController> { return this.m_screen.GetPreemGameController(); }
  public func GetPlayer() -> wref<PlayerPuppet> { return this.m_screen.GetPreemGameController().GetPreemPlayer(); }
  public func GetTooltipsManager() -> wref<gameuiTooltipsManager> { return this.m_screen.GetPreemGameController().GetPreemTooltipsManager(); }
  public func GetWeaponQuality() -> gamedataQuality { return this.m_screen.GetPreemWeaponQuality(); }
  public func ClearPreemMods() -> Void { this.m_screen.GetPreemFrame().ClearSlots(); }
  public func OnPreemModsChanged() -> Void { this.m_screen.RefreshPreemButton(); }
  public func IsModAllowed(mod: ref<PreemMod>) -> Bool { return PreemCraftingSystem.IsModAllowedOnOwnedWeapon(mod.modStyleType); }
  public func UseStripLayout() -> Bool { return true; }
}
