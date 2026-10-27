// Dev only, never shipped. Drives the crafting screen from script, for checks a screenshot then
// confirms (injected mouse input doesn't move the game's own cursor reliably):
//   Game.PreemOpenCrafting()        (PreemDebug.reds) opens the crafting screen
//   Game.PreemUiSelectWeapon(n)     selects the n-th weapon recipe in the list and shows its preview
//   Game.PreemUiOpenSettings()      presses the Preem SETTINGS button
//   Game.PreemUiPressSetting(n)     presses a settings popup button: 0 unlocks, 1 limit, 2 layout
//   Game.PreemUiCloseSettings()     closes the popup
//   Game.PreemUiNextTab()           switches tab (Crafting <-> Upgrades) like the tab arrows
//   Game.PreemUiSelectUpgrade(n)    selects the n-th item in the Upgrades list
//   Game.PreemUiSelectUpgradeTestItem()  selects the last PreemCraftTest weapon there
//   Game.PreemUiDumpUpgrade()       logs the selected item, how the tab treats it, and its slotted
//                                   and installed Preem mods
//   Game.PreemUiDump()              logs the settings, the ranged frame's grid shape and which
//                                   frame and button are showing
// A dev wrap records the open crafting screen on PreemDevSystem; it keeps its popup itself. No `module` line (exec functions).

@if(ModuleExists("PreemCrafting.PreemUI"))
import PreemCrafting.PreemUI.*
@if(ModuleExists("PreemCrafting.PreemUI"))
import PreemCrafting.Core.*
@if(ModuleExists("PreemCrafting.PreemUI"))
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
import PreemDev.*

@if(ModuleExists("PreemCrafting.PreemUI"))
@wrapMethod(CraftingMainGameController)
protected cb func OnInitialize() -> Bool {
  let result = wrappedMethod();
  PreemUiDriver.System(this.GetPlayerControlledObject().GetGame()).craftingScreen = this;
  return result;
}

// Selects the nth weapon recipe in the list (in list order, after the category filter) the way
// a click does (vanilla Select: toggle, select, scroll, preview). Returns its record name, or "".
@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainLogicController)
public func PreemDevSelectWeapon(nth: Int32) -> String {
  let size = this.m_dataView.Size();
  let i = 0u;
  while i < size {
    let recipe = this.m_dataView.GetItem(i) as RecipeData;
    if IsDefined(recipe) && CraftingMainLogicController.IsWeapon(recipe.id.EquipArea().Type()) {
      if nth == 0 {
        this.Select(i);
        return TDBID.ToStringDEBUG(recipe.id.GetID());
      }
      nth -= 1;
    }
    i += 1u;
  }
  return "";
}

@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainGameController)
public func PreemDevSelectWeapon(nth: Int32) -> String {
  return this.m_craftingLogicController.PreemDevSelectWeapon(nth);
}

@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainGameController)
public func PreemDevDump() -> String {
  let settings = this.GetPreemSettings();
  let rangedRows = this._preemFrame.GetRangedGrid().GetRowCount();
  let rangedColumns = this._preemFrame.GetRangedGrid().GetColumnCount();
  return s"unlock \(EnumInt(settings.GetUnlockMode())), limit \(EnumInt(settings.GetLimitMode())), layout \(EnumInt(settings.GetSlotLayout())); ranged grid \(rangedRows)x\(rangedColumns), ranged shown \(this._preemFrame.GetRangedGrid().GetRootWidget().IsVisible()), melee shown \(this._preemFrame.GetMeleeGrid().GetRootWidget().IsVisible()), settings button \(IsDefined(this._preemFrame.GetSettingsButton()) && this._preemFrame.GetSettingsButton().GetRootWidget().IsVisible())";
}

@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainGameController)
public func PreemDevPressSetting(which: Int32) -> Bool {
  let popup = this._preemFrame.GetSettingsPopup();
  if !IsDefined(popup) {
    return false;
  }
  switch which {
    case 0:
      popup.OnUnlockClicked(null);
      break;
    case 1:
      popup.OnLimitClicked(null);
      break;
    default:
      popup.OnLayoutClicked(null);
  }
  return true;
}

@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainGameController)
public func PreemDevCloseSettings() -> Void {
  if IsDefined(this._preemFrame.GetSettingsPopup()) {
    this._preemFrame.GetSettingsPopup().Close();
  }
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public abstract class PreemUiDriver {
  public static func System(gi: GameInstance) -> ref<PreemDevSystem> {
    return GameInstance.GetScriptableSystemsContainer(gi).Get(n"PreemDev.PreemDevSystem") as PreemDevSystem;
  }

  public static func Screen(gi: GameInstance) -> ref<CraftingMainGameController> {
    return PreemUiDriver.System(gi).craftingScreen as CraftingMainGameController;
  }
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiSelectWeapon(gi: GameInstance, nth: Int32) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  FTLog(s"[PreemDev] ui: select weapon \(nth): \(IsDefined(screen) ? screen.PreemDevSelectWeapon(nth) : "no crafting screen open")");
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiOpenSettings(gi: GameInstance) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  if !IsDefined(screen) {
    FTLog("[PreemDev] ui: no crafting screen open");
    return;
  }
  screen.GetPreemFrame().OnPreemSettingsClicked(null);
  FTLog("[PreemDev] ui: settings button pressed");
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiPressSetting(gi: GameInstance, which: Int32) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  FTLog(s"[PreemDev] ui: settings button \(which) pressed: \(IsDefined(screen) && screen.PreemDevPressSetting(which))");
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiCloseSettings(gi: GameInstance) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  if IsDefined(screen) {
    screen.PreemDevCloseSettings();
  }
  FTLog("[PreemDev] ui: settings popup closed");
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiDump(gi: GameInstance) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  FTLog("[PreemDev] ui: " + (IsDefined(screen) ? screen.PreemDevDump() : "no crafting screen open"));
}

// Upgrades tab (Phase 5): switch to it the way the tab arrows do, and select the nth listed item.
@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainGameController)
public func PreemDevNextTab() -> Void {
  this.MoveTab(Direction.Next);
}

@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainGameController)
public func PreemDevSelectUpgrade(nth: Int32) -> String {
  return this.m_upgradingLogicController.PreemDevSelectUpgrade(nth);
}

// Selects the nth item in the Upgrades list (list order) the way a click does. Returns its record
// and the list size, or "" when the list is shorter.
@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(UpgradingScreenController)
public func PreemDevSelectUpgrade(nth: Int32) -> String {
  let size = Cast<Int32>(this.m_dataView.Size());
  if nth >= size {
    return s"none (\(size) listed)";
  }
  this.Select(Cast<Uint32>(nth));
  let data = this.m_dataView.GetItem(Cast<Uint32>(nth)) as ItemCraftingData;
  return TDBID.ToStringDEBUG(ItemID.GetTDBID(data.inventoryItem.ID)) + s" (\(size) listed)";
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiNextTab(gi: GameInstance) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  if IsDefined(screen) {
    screen.PreemDevNextTab();
  }
  FTLog(s"[PreemDev] ui: next tab: \(IsDefined(screen))");
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiSelectUpgrade(gi: GameInstance, nth: Int32) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  FTLog(s"[PreemDev] ui: select upgrade \(nth): \(IsDefined(screen) ? screen.PreemDevSelectUpgrade(nth) : "no crafting screen open")");
}

// Selects the given owned item in the Upgrades list, if listed. Returns its list index, or -1.
@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(UpgradingScreenController)
public func PreemDevSelectUpgradeItem(itemID: ItemID) -> Int32 {
  let size = this.m_dataView.Size();
  let i = 0u;
  while i < size {
    let data = this.m_dataView.GetItem(i) as ItemCraftingData;
    if IsDefined(data) && data.inventoryItem.ID == itemID {
      this.Select(i);
      // An item scrolled out of the virtual list has no spawned controller yet, so Select previews
      // nothing; preview it from its data, as the click on the shown item does.
      this.UpdateItemPreviewPanel(data.inventoryItem);
      return Cast<Int32>(i);
    }
    i += 1u;
  }
  return -1;
}

// The selected item, how the tab treats it, and the Preem mods in the frame's slots next to the
// ones read back from the item.
@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(UpgradingScreenController)
public func PreemDevDump() -> String {
  let item = this.GetPreemSelectedItem();
  if !IsDefined(item) {
    return s"upgrades: nothing selected (\(this.m_dataView.Size()) listed)";
  }
  let frame = this.GetPreemFrame();
  let slotted = "";
  for mod in frame.GetSlottedMods() {
    slotted += (StrLen(slotted) > 0 ? ", " : "") + PreemDebug.StyleName(mod.modStyleType);
  }
  let installed = "";
  for placement in PreemCraftingSystem.GetInstalledMods(item) {
    installed += (StrLen(installed) > 0 ? ", " : "") + PreemDebug.StyleName(placement.mod.modStyleType);
  }
  return s"upgrades: \(TDBID.ToStringDEBUG(ItemID.GetTDBID(item.GetID()))), iconic \(RPGManager.IsItemIconic(item)), max tier \(RPGManager.IsItemMaxTier(item)), upgradable \(this.IsPreemUpgradable(item)), unlock rarity \(EnumInt(this.GetPreemWeaponQuality())); details shown \(inkWidgetRef.IsVisible(this.m_itemDetailsContainer)), ranged frame \(frame.GetRangedGrid().GetRootWidget().IsVisible()), melee frame \(frame.GetMeleeGrid().GetRootWidget().IsVisible()); slotted [\(slotted)], installed [\(installed)]";
}

@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainGameController)
public func PreemDevUpgradeScreen() -> wref<UpgradingScreenController> {
  return this.m_upgradingLogicController;
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiSelectUpgradeTestItem(gi: GameInstance) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  let index = IsDefined(screen) ? screen.PreemDevUpgradeScreen().PreemDevSelectUpgradeItem(PreemDebug.System(gi).lastTestItem) : -1;
  FTLog(s"[PreemDev] ui: select test weapon on the Upgrades tab: index \(index)");
}

@if(ModuleExists("PreemCrafting.PreemUI"))
public static exec func PreemUiDumpUpgrade(gi: GameInstance) -> Void {
  let screen = PreemUiDriver.Screen(gi);
  FTLog("[PreemDev] ui: " + (IsDefined(screen) ? screen.PreemDevUpgradeScreen().PreemDevDump() : "no crafting screen open"));
}
