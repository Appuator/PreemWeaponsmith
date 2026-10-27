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
  container.SetTranslation(new Vector2(0.0, -340.0));
  container.Reparent(area);
  this._preemFrame = PreemSlotFrame.Create(PreemUpgradeScreenHost.Create(this), container);
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

// Whether the hold button upgrades the item (an iconic below max tier); otherwise it only
// applies Preem mods.
@addMethod(UpgradingScreenController)
public func IsPreemUpgradable(item: wref<gameItemData>) -> Bool {
  return IsDefined(item) && RPGManager.IsItemIconic(item) && !RPGManager.IsItemMaxTier(item);
}

// The rarity that decides the unlocked mods: after the upgrade when there is one (SPEC §2.1).
@addMethod(UpgradingScreenController)
public func GetPreemWeaponQuality() -> gamedataQuality {
  let item = this.GetPreemSelectedItem();
  if !IsDefined(item) {
    return gamedataQuality.Invalid;
  }
  return this.IsPreemUpgradable(item) ? RPGManager.GetNextItemQuality(item) : RPGManager.GetItemQuality(item);
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
  this._preemFrame.ShowInstalledMods(PreemCraftingSystem.GetInstalledMods(item));
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
}

// Vanilla lists iconic weapons below max tier. Add the player's other weapons (the types Preem
// mods fit) and max-tier iconics, each once.
@wrapMethod(UpgradingScreenController)
private final func GetUpgradableList() -> array<ref<IScriptable>> {
  let list = wrappedMethod();
  let types = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
  for melee in PreemCraftingSystem.GetMeleeWeaponsItemsTypeList() {
    ArrayPush(types, melee);
  }
  for itemType in types {
    for inventoryItem in this.m_inventoryManager.GetPlayerItemsByType(itemType) {
      let item = InventoryItemData.GetGameItemData(inventoryItem);
      if IsDefined(item) && (!RPGManager.IsItemIconic(item) || RPGManager.IsItemMaxTier(item)) {
        let wrapper = new ItemCraftingData();
        wrapper.inventoryItem = inventoryItem;
        wrapper.isUpgradable = false;
        wrapper.isNew = this.m_craftingGameController.GetScriptableSystem().IsInventoryItemNew(inventoryItem.ID);
        ArrayPush(list, wrapper);
        this.m_inventoryManager.GetOrCreateInventoryItemSortData(wrapper.inventoryItem, this.m_craftingGameController.GetScriptableSystem());
      }
    }
  }
  return list;
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
  public func IsModAllowed(mod: ref<PreemMod>) -> Bool { return PreemCraftingSystem.IsModAllowedOnOwnedWeapon(mod.modStyleType); }
  public func UseStripLayout() -> Bool { return true; }
}
