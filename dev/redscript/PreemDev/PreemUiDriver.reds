// Dev only, never shipped. Drives the crafting screen from script, for checks a screenshot then
// confirms (injected mouse input doesn't move the game's own cursor reliably):
//   Game.PreemOpenCrafting()        (PreemDebug.reds) opens the crafting screen
//   Game.PreemUiSelectWeapon(n)     selects the n-th weapon recipe in the list and shows its preview
//   Game.PreemUiOpenSettings()      presses the Preem SETTINGS button
//   Game.PreemUiPressSetting(n)     presses a settings popup button: 0 unlocks, 1 limit, 2 layout
//   Game.PreemUiCloseSettings()     closes the popup
//   Game.PreemUiDump()              logs the settings, the ranged frame's grid shape and which
//                                   frame and button are showing
// A dev wrap records the open crafting screen on PreemDevSystem; it keeps its popup itself. No `module` line (exec functions).

@if(ModuleExists("PreemCrafting.PreemUI"))
import PreemCrafting.PreemUI.*
@if(ModuleExists("PreemCrafting.PreemUI"))
import PreemCrafting.Core.*
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
  let rangedRows = this._preemGridRanged.GetRowCount();
  let rangedColumns = this._preemGridRanged.GetColumnCount();
  return s"unlock \(EnumInt(settings.GetUnlockMode())), limit \(EnumInt(settings.GetLimitMode())), layout \(EnumInt(settings.GetSlotLayout())); ranged grid \(rangedRows)x\(rangedColumns), ranged shown \(this._preemGridRanged.GetRootWidget().IsVisible()), melee shown \(this._preemGridMelee.GetRootWidget().IsVisible()), settings button \(IsDefined(this._preemSettingsButton) && this._preemSettingsButton.GetRootWidget().IsVisible())";
}

@if(ModuleExists("PreemCrafting.PreemUI"))
@addMethod(CraftingMainGameController)
public func PreemDevPressSetting(which: Int32) -> Bool {
  let popup = this._preemSettingsPopup;
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
  if IsDefined(this._preemSettingsPopup) {
    this._preemSettingsPopup.Close();
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
  screen.OnPreemSettingsClicked(null);
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
