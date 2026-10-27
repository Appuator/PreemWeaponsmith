module PreemCrafting.PreemUI
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
import PreemCrafting.Core.*
import Codeware.UI.*

// The crafting screen's Preem slot frame (PreemSlotFrame), shown in the weapon preview area.
@addField(CraftingMainGameController)
private let _preemFrame: ref<PreemSlotFrame>;

@wrapMethod(CraftingMainGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();
  let preemRoot: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  let container = preemRoot.GetWidget(n"craftingPanel/inkCanvasWidget2/inkCanvasWidget7/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  this._preemFrame = PreemSlotFrame.Create(PreemCraftingScreenHost.Create(this), container);
}

@addMethod(CraftingMainGameController)
public func GetPreemFrame() -> ref<PreemSlotFrame>
{
  return this._preemFrame;
}

// The per-save Preem settings (PreemSettings).
@addMethod(CraftingMainGameController)
public func GetPreemSettings() -> ref<PreemSettings>
{
  return PreemSettings.GetInstance(this.GetPlayerControlledObject().GetGame());
}

@addMethod(CraftingMainGameController)
public func GetPreemPlayer() -> wref<PlayerPuppet>
{
  return this.m_player;
}

@addMethod(CraftingMainGameController)
public func GetPreemTooltipsManager() -> wref<gameuiTooltipsManager>
{
  return this.m_tooltipsManager;
}

// The selected recipe's rarity decides which mods are unlocked.
@addMethod(CraftingMainGameController)
public func GetPreemWeaponQuality() -> gamedataQuality
{
  return this.m_craftingLogicController.m_selectedRecipe.id.Quality().Type();
}

@wrapMethod(CraftingMainGameController)
protected cb func OnUninitialize() -> Bool {
  let preemCraftingSystem = PreemCraftingSystem.GetInstance(this.m_player.GetGame());
  preemCraftingSystem.ClearMods();
  wrappedMethod();
}

@addMethod(CraftingMainGameController)
public func ProcessPreemModSelection()
{
  let selectedModList: array<ref<PreemMod>>;
  let preemCraftingSystem: wref<PreemCraftingSystem>;
  let craftingSystem: ref<CraftingSystem>;
  let container = GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame());
  craftingSystem = container.Get(n"CraftingSystem") as CraftingSystem;
  preemCraftingSystem = PreemCraftingSystem.GetInstance(this.m_player.GetGame());
  if IsDefined(this._preemFrame)
  {
    selectedModList = this._preemFrame.GetSlottedMods();

    let craftingRecord = this.m_craftingLogicController.m_selectedRecipe.id as WeaponItem_Record;
    if IsDefined(craftingRecord){
      preemCraftingSystem.SetCurrentWeaponEvo(craftingRecord.Evolution().Type());
      preemCraftingSystem.SetCurrentWeaponRarity(craftingRecord.Quality().Type());
    }
    preemCraftingSystem.SetModList(selectedModList);
    this.m_craftingLogicController.UpdateRecipePreviewPanel(this.m_craftingLogicController.m_selectedRecipe);
  }
}

@wrapMethod(CraftingMainGameController)
protected cb func OnCraftingComplete(value: Variant) -> Bool {
  wrappedMethod(value);
  if IsDefined(this._preemFrame)
  {
    this._preemFrame.ClearSlots();
  }
}

@addMethod(CraftingMainGameController)
public func ClearMods() -> Void
{
  let preemCraftingSystem = PreemCraftingSystem.GetInstance(this.m_player.GetGame());
  if IsDefined(this._preemFrame)
  {
    this._preemFrame.ClearSlots();
  }
  preemCraftingSystem.ClearMods();
}


@wrapMethod(CraftingMainLogicController)
private final func OnPressSelectedItem(evt: ref<inkPointerEvent>) -> Void {
    wrappedMethod(evt);
    // Same input check as vanilla, which accepts touch "tap" since 2.5. Crafting tab only: the
    // Upgrades tab (same base class) lists items, not recipes (PreemUpgradeScreen.reds).
    if IsDefined(this as CraftingLogicController) && (evt.IsAction(n"click") || evt.IsAction(n"tap")) {
      this.m_craftingGameController.ClearMods();
      let preemItemType: gamedataItemType;
      let rangedWeaponItemTypeList: array<gamedataItemType>;
      let meleeWeaponItemTypeList: array<gamedataItemType>;
      rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
      meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

      if IsDefined(this.m_currentSelected){
        preemItemType = this.m_currentSelected.m_recipeData.id.ItemType().Type();
        if(ArrayContains(rangedWeaponItemTypeList,preemItemType))
        {
          this.m_craftingGameController.GetPreemFrame().SetWeaponPreemFrameToRanged();
        }
        else{
          if(ArrayContains(meleeWeaponItemTypeList,preemItemType))
          {
            this.m_craftingGameController.GetPreemFrame().SetWeaponPreemFrameToMelee();
          }
        }
      }
    }
}

// The crafting screen as a PreemSlotFrame host.
public class PreemCraftingScreenHost extends PreemSlotFrameHost {
  private let m_screen: wref<CraftingMainGameController>;

  public static func Create(screen: ref<CraftingMainGameController>) -> ref<PreemCraftingScreenHost> {
    let host = new PreemCraftingScreenHost();
    host.m_screen = screen;
    return host;
  }

  public func GetGameController() -> wref<inkGameController> { return this.m_screen; }
  public func GetPlayer() -> wref<PlayerPuppet> { return this.m_screen.GetPreemPlayer(); }
  public func GetTooltipsManager() -> wref<gameuiTooltipsManager> { return this.m_screen.GetPreemTooltipsManager(); }
  public func GetWeaponQuality() -> gamedataQuality { return this.m_screen.GetPreemWeaponQuality(); }
  public func OnPreemModsChanged() -> Void { this.m_screen.ProcessPreemModSelection(); }
  public func ClearPreemMods() -> Void { this.m_screen.ClearMods(); }
}

@addField(MaterialTooltipData)
public let preemModDescription: String;

@wrapMethod(MaterialTooltip)
public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    wrappedMethod(tooltipData);
    // let priceReducted: Bool;
    let messageData: ref<MaterialTooltipData> = tooltipData as MaterialTooltipData;

    
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_Price HAlign \(inkTextRef.GetHorizontalAlignment(this.m_Price))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_Price VAlign \(inkTextRef.GetVerticalAlignment(this.m_Price))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_Price Anchor \(inkTextRef.GetAnchor(this.m_Price))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_Price HAlignWidget \(inkWidgetRef.GetHAlign(this.m_Price))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_Price VAlignWidget \(inkWidgetRef.GetVAlign(this.m_Price))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_Price AnchorWidget \(inkWidgetRef.GetAnchor(this.m_Price))");
    

    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_BasePrice HAlign \(inkTextRef.GetHorizontalAlignment(this.m_BasePrice))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_BasePrice VAlign \(inkTextRef.GetVerticalAlignment(this.m_BasePrice))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_BasePrice Anchor \(inkTextRef.GetAnchor(this.m_BasePrice))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_BasePrice style \(inkTextRef.GetFontStyle(this.m_BasePrice))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_BasePrice HAlignWidget \(inkWidgetRef.GetHAlign(this.m_BasePrice))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_BasePrice VAlignWidget \(inkWidgetRef.GetVAlign(this.m_BasePrice))");
    // LogChannel(n"DEBUG", s"PreemUI Tooltip:: m_BasePrice AnchorWidget \(inkWidgetRef.GetAnchor(this.m_BasePrice))");

    if NotEquals(messageData.preemModDescription, "")
     {
      inkTextRef.SetFontSize(this.m_Price, 32);
      inkTextRef.SetTintColor(this.m_Price, ThemeColors.ElectricBlue());
      inkTextRef.SetText(this.m_Price, messageData.preemModDescription);
      inkWidgetRef.SetSize(this.m_Price, 500, 800);
      inkWidgetRef.SetSize(this.m_descriptionWrapper, 500, 800);
      inkWidgetRef.SetFitToContent(this.m_descriptionWrapper, true);
      inkWidgetRef.SetVisible(this.m_descriptionWrapper, true);
      inkWidgetRef.SetVisible(this.m_descriptionLine, false);
      inkWidgetRef.SetVisible(this.m_BasePrice, false);
      inkWidgetRef.SetVisible(this.m_titleWrapper, true);
    }
    else{
      inkTextRef.SetFontSize(this.m_Price, 48);
      inkTextRef.SetTintColor(this.m_Price, ThemeColors.Bittersweet());
      inkWidgetRef.SetVisible(this.m_BasePrice, true);
    }
}
