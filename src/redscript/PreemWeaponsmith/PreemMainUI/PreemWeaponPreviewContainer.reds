module PreemCrafting.PreemUI
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModSlotManager.*
import PreemCrafting.CraftingSystem.PreemModMaker.*
import PreemCrafting.CraftingSystem.ModInstaller.*
import PreemCrafting.CraftingSystem.PreemModUnlocker.*
import Codeware.UI.*


@addField(CraftingMainGameController)
private let _triggerSlot1: ref<PreemModSlot>;         

@addField(CraftingMainGameController)
private let _triggerSlot2: ref<PreemModSlot>;

@addField(CraftingMainGameController)
private let _barrelSlot1: ref<PreemModSlot>;

@addField(CraftingMainGameController)
private let _barrelSlot2: ref<PreemModSlot>;

@addField(CraftingMainGameController)
private let _magSlot1: ref<PreemModSlot>;

@addField(CraftingMainGameController)
private let _magSlot2: ref<PreemModSlot>;

@addField(CraftingMainGameController)
private let _bladeSlot1: ref<PreemModSlot>;         

@addField(CraftingMainGameController)
private let _bladeSlot2: ref<PreemModSlot>;

@addField(CraftingMainGameController)
private let _handleSlot1: ref<PreemModSlot>;

@addField(CraftingMainGameController)
private let _handleSlot2: ref<PreemModSlot>;

@addField(CraftingMainGameController)
private let _preemGridRanged: ref<PreemGrid>;

@addField(CraftingMainGameController)
private let _preemGridMelee: ref<PreemGrid>;

@addField(CraftingMainGameController)
private let _preemPopupGrid: ref<PreemGrid>;

// @addField(CraftingMainGameController)
// private let _currentPopup: ref<PreemModSelectorPopup>;

@addField(CraftingMainGameController)
private let _preemModSlotManager: ref<PreemModSlotManager>;

@addField(CraftingMainGameController)
private let _preemContainer: ref<inkCompoundWidget>;

@addField(CraftingMainGameController)
private let _preemContainer2: ref<inkCompoundWidget>;

@addField(CraftingMainGameController)
private let _preemModMapper: ref<PreemModMapper>;

@addField(CraftingMainGameController)
private let _preemModUnlocker: ref<PreemModUnlocker>;


@wrapMethod(CraftingMainGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();
  this._preemModMapper = new PreemModMapper();
  this._preemModUnlocker = new PreemModUnlocker();
  let preemRoot: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  this._preemContainer = preemRoot.GetWidget(n"craftingPanel/inkCanvasWidget2/inkCanvasWidget7/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  this._preemModSlotManager = new PreemModSlotManager();
  this.CreateRangedWeaponPreemFrame();
  this.CreateMeleeWeaponPreemFrame();
  this.SetWeaponPreemFrameToRanged();
}

@addMethod(CraftingMainGameController)
public func CreateRangedWeaponPreemFrame() -> Void
{
  // let preemRoot: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  // this._preemContainer = preemRoot.GetWidget(n"craftingPanel/inkCanvasWidget2/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  let preemSettings: ref<PreemModSettings> = new PreemModSettings();
  if(Equals(preemSettings.ModSlotPosition, PreemWeaponsmithModSlotPosition.BelowWeapon))
  {
    this._preemGridRanged = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(6,8));
  }
  else{
    this._preemGridRanged = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(3,4));
  }
  
  this._preemGridRanged.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.CreateUIPreemSlotsForRanged();
  this._preemGridRanged.Reparent(this._preemContainer);
}

@addMethod(CraftingMainGameController)
public func CreateMeleeWeaponPreemFrame() -> Void
{
  // let preemRoot: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  // this._preemContainer = preemRoot.GetWidget(n"craftingPanel/inkCanvasWidget2/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  //this._preemGridMelee = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(3,4));
  this._preemGridMelee = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(3,4));

  this._preemGridMelee.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.CreateUIPreemSlotsForMelee();
  this._preemGridMelee.Reparent(this._preemContainer);
}

@addMethod(CraftingMainGameController)
public func SetWeaponPreemFrameToRanged() -> Void
{
  this._preemGridRanged.SetVisible(true);
  this._preemGridMelee.SetVisible(false);
  this._preemGridRanged.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this._preemGridMelee.UnregisterFromCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.SetRangedSlotsOnPreemModSlotManager();
}

@addMethod(CraftingMainGameController)
public func SetWeaponPreemFrameToMelee() -> Void
{
  this._preemGridRanged.SetVisible(false);
  this._preemGridMelee.SetVisible(true);
  this._preemGridRanged.UnregisterFromCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this._preemGridMelee.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.SetMeleeSlotsOnPreemModSlotManager();
}

@wrapMethod(CraftingMainGameController)
protected cb func OnUninitialize() -> Bool {
  let preemCraftingSystem = PreemCraftingSystem.GetInstance(this.m_player.GetGame());
  preemCraftingSystem.ClearMods();
  wrappedMethod();
}


@addMethod(CraftingMainGameController)
public func CreatePreemPopupGrid(modClassType: PreemModClassType) -> ref<PreemGrid>
{
  let grid = PreemGrid.Create(new Vector2(1000,800),new Vector2(5,5));
  grid.SetOpacity(1);
  
  let modItems = this.CreatePreemModItems(modClassType);

  let i = 0;
  let j = 0;
  let c = 0;

  while( i < ArraySize(modItems))
  {
    grid.AddModItem(modItems[i], j, c);
    i += 1;
    c += 1;
    if Equals(c,5)
    {
      j += 1;
      c = 0;
    }
  }

  grid.RegisterToCallback(n"OnPreemModSelected", this, n"OnPreemModSelectedCallBack");
  grid.RegisterToCallback(n"OnHoverOver", this, n"OnPreemModHoverOverCallBack");
  grid.RegisterToCallback(n"OnHoverOut", this, n"OnPreemModHoverOutCallBack");
  return grid;
}

@addMethod(CraftingMainGameController)
public func CreatePreemModItems(modClassType: PreemModClassType) -> array<ref<PreemModItem>>
{
  let selectableMods: array<ref<PreemModItem>>;
  let mods = PreemModMaker.GetModsFromClassType(modClassType);

  for mod in mods
  {
    ArrayPush(selectableMods, this.CreatePreemModItemFromPreemMod(mod));
    
  }

  return selectableMods;
}

@addMethod(CraftingMainGameController)
public func CreatePreemModItemFromPreemMod(preemMod: ref<PreemMod>) -> ref<PreemModItem>
{
  let item = PreemModItem.Create();
  let isUnlocked: Bool = true;
  item.SetName(preemMod.GetModName());

  let itemData = preemMod;
  if(IsDefined(this._preemModUnlocker))
  {
    this._preemModUnlocker.SetDevSystem(this.m_player);
    this._preemModUnlocker.SetWeaponQuality(this.m_craftingLogicController.m_selectedRecipe.id.Quality().Type());    
    isUnlocked = this._preemModUnlocker.DetermineModUnlocked(preemMod.modStyleType, this.m_player);
    itemData.setIsUnlocked(isUnlocked);
  }
  
  item.SetModData(itemData);
  item.SetDisabled(!isUnlocked);

  item.preemModSlotManager = this._preemModSlotManager;

  return item;
}

@addMethod(CraftingMainGameController)
public cb func OnPreemSlotClickedCallBack(widget: wref<inkWidget>) -> Bool
{
  //LogChannel(n"DEBUG", s"CraftingUI:: PreemSlotClicked!");
  if IsDefined(this._preemModSlotManager)
  {
    this._preemPopupGrid = this.CreatePreemPopupGrid(this._preemModSlotManager.GetCurrentlySelectedPreemSlot().GetSlotData().preemClassType);
    PreemModSelectorPopup.Show(this,this._preemPopupGrid,this.m_tooltipsManager);
  }
}

@addMethod(CraftingMainGameController)
public cb func OnPreemModSelectedCallBack(widget: wref<inkWidget>) -> Bool
{ 
  this.ProcessPreemModSelection();
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
  if IsDefined(this._preemModSlotManager)
  {
    selectedModList = this._preemModSlotManager.GetCurrentSlottedMods();
    //LogChannel(n"DEBUG", s"PreemUI WeaponContainer::\(selectedModList)");

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
  if IsDefined(this._preemModSlotManager)
  {
    this._preemModSlotManager.ClearCurrentSlots();
  }
}

@addMethod(CraftingMainGameController)
public func ClearMods() -> Void
{
  let preemCraftingSystem = PreemCraftingSystem.GetInstance(this.m_player.GetGame());
  if IsDefined(this._preemModSlotManager)
  {
    this._preemModSlotManager.ClearCurrentSlots();
  }
  preemCraftingSystem.ClearMods();
}


// protected cb func OnItemSelect(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Bool {
//     this.UpdateItemPreview(next as CraftableItemLogicController);
//     this.PlaySound(n"Button", n"OnPress");
//   }
// @wrapMethod(CraftingMainLogicController)
// protected cb func OnItemSelect(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Bool {
//     wrappedMethod(previous,next);
//     this.m_craftingGameController.ClearMods();
//     let itemController: ref<CraftableItemLogicController> = next as CraftableItemLogicController;
//     let preemItemType: gamedataItemType;
//     let rangedWeaponItemTypeList: array<gamedataItemType>;
//     let meleeWeaponItemTypeList: array<gamedataItemType>;
//     rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
//     meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

//     if IsDefined(itemController){
//       preemItemType = itemController.m_recipeData.id.ItemType().Type();
//       if(ArrayContains(rangedWeaponItemTypeList,preemItemType))
//       {
//         this.m_craftingGameController.SetWeaponPreemFrameToRanged();
//       }
//       else{
//         if(ArrayContains(meleeWeaponItemTypeList,preemItemType))
//         {
//           this.m_craftingGameController.SetWeaponPreemFrameToMelee();
//         }
//       }
//     }
// }

@wrapMethod(CraftingMainLogicController)
private final func OnPressSelectedItem(evt: ref<inkPointerEvent>) -> Void {
    wrappedMethod(evt);
    if evt.IsAction(n"click") {
      this.m_craftingGameController.ClearMods();
      //let itemController: ref<CraftableItemLogicController> = this.m_currentSelected as CraftableItemLogicController;
      let preemItemType: gamedataItemType;
      let rangedWeaponItemTypeList: array<gamedataItemType>;
      let meleeWeaponItemTypeList: array<gamedataItemType>;
      rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
      meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

      if IsDefined(this.m_currentSelected){
        preemItemType = this.m_currentSelected.m_recipeData.id.ItemType().Type();
        if(ArrayContains(rangedWeaponItemTypeList,preemItemType))
        {
          this.m_craftingGameController.SetWeaponPreemFrameToRanged();
        }
        else{
          if(ArrayContains(meleeWeaponItemTypeList,preemItemType))
          {
            this.m_craftingGameController.SetWeaponPreemFrameToMelee();
          }
        }
      }
    }
}

// @wrapMethod(CraftingMainGameController)
// private final func RefreshUI(opt inventoryItemData: InventoryItemData) -> Void {
//   wrappedMethod(inventoryItemData);
//   if(Equals(this.m_mode,CraftingMode.craft)){
//     if(ArrayContains(PreemCraftingSystem.GetRangedWeaponsItemsTypeList(),this.m_craftingLogicController.m_selectedRecipe.id.ItemType().Type()))
//     {
//       this._preemGrid.SetVisible(true);
//     }
//     else{
//       this._preemGrid.SetVisible(false);
//     }
//   }
// }

@addMethod(CraftingMainGameController)
protected func CreateUIPreemSlotsForRanged()
{
  let preemSettings: ref<PreemModSettings> = new PreemModSettings();
  this._barrelSlot1 = PreemModSlot.Create();
  this._barrelSlot2 = PreemModSlot.Create();
  this._triggerSlot1 = PreemModSlot.Create();
  this._triggerSlot2 = PreemModSlot.Create();
  this._magSlot1 = PreemModSlot.Create();
  this._magSlot2 = PreemModSlot.Create();
  this._barrelSlot1.SetName(n"Slot1Barrel");
  this._barrelSlot2.SetName(n"Slot2Barrel");
  this._triggerSlot1.SetName(n"Slot1Trigger");
  this._triggerSlot2.SetName(n"Slot2Trigger");
  this._magSlot1.SetName(n"Slot1Mag");
  this._magSlot2.SetName(n"Slot2Mag");

  this.CreateUIPreemSlotDataForRanged();

  let triggerGroup =  PreemSlotClassGroup.Create();
  triggerGroup.SetCurrentOrientation(SlotClassGroupOrientation.Horizontal);
  triggerGroup.SetClassLabel("Trigger");
  triggerGroup.AddSlot(this._triggerSlot1);
  triggerGroup.AddSlot(this._triggerSlot2);
  triggerGroup.preemModSlotManager = this._preemModSlotManager;

  let barrelGroup =  PreemSlotClassGroup.Create();
  barrelGroup.SetCurrentOrientation(SlotClassGroupOrientation.Horizontal);
  barrelGroup.SetClassLabel("Barrel");
  barrelGroup.AddSlot(this._barrelSlot1);
  barrelGroup.AddSlot(this._barrelSlot2);
  barrelGroup.preemModSlotManager = this._preemModSlotManager;

  let magGroup =  PreemSlotClassGroup.Create();
  if(Equals(preemSettings.ModSlotPosition, PreemWeaponsmithModSlotPosition.BelowWeapon))
  {
    magGroup.SetCurrentOrientation(SlotClassGroupOrientation.Horizontal);
  }
  else{
    magGroup.SetCurrentOrientation(SlotClassGroupOrientation.Vertical);
  }
  magGroup.SetClassLabel("Mag");
  magGroup.AddSlot(this._magSlot1);
  magGroup.AddSlot(this._magSlot2);
  magGroup.preemModSlotManager = this._preemModSlotManager;

  if(Equals(preemSettings.ModSlotPosition, PreemWeaponsmithModSlotPosition.BelowWeapon))
  {
    this._preemGridRanged.AddClassGroup(magGroup, 5, 0);
    this._preemGridRanged.AddClassGroup(triggerGroup, 5, 3);
    this._preemGridRanged.AddClassGroup(barrelGroup, 5, 6);
  }
  else{
    this._preemGridRanged.AddClassGroup(magGroup, 1, 0);
    this._preemGridRanged.AddClassGroup(triggerGroup, 1, 1);
    this._preemGridRanged.AddClassGroup(barrelGroup, 0, 2);
  }
}

@addMethod(CraftingMainGameController)
protected func CreateUIPreemSlotsForMelee()
{
  let preemSettings: ref<PreemModSettings> = new PreemModSettings();
  this._bladeSlot1 = PreemModSlot.Create();
  this._bladeSlot2 = PreemModSlot.Create();
  this._handleSlot1 = PreemModSlot.Create();
  this._handleSlot2 = PreemModSlot.Create();
  this._bladeSlot1.SetName(n"Slot1Blade");
  this._bladeSlot2.SetName(n"Slot2Blade");
  this._handleSlot1.SetName(n"Slot1Handle");
  this._handleSlot2.SetName(n"Slot2Handle");

  this.CreateUIPreemSlotDataForMelee();

  let bladeGroup =  PreemSlotClassGroup.Create();
  bladeGroup.SetCurrentOrientation(SlotClassGroupOrientation.Horizontal);
  bladeGroup.SetClassLabel("Blade");
  bladeGroup.AddSlot(this._bladeSlot1);
  bladeGroup.AddSlot(this._bladeSlot2);
  bladeGroup.preemModSlotManager = this._preemModSlotManager;

  let handleGroup =  PreemSlotClassGroup.Create();
  handleGroup.SetCurrentOrientation(SlotClassGroupOrientation.Horizontal);
  handleGroup.SetClassLabel("Handle");
  handleGroup.AddSlot(this._handleSlot1);
  handleGroup.AddSlot(this._handleSlot2);
  handleGroup.preemModSlotManager = this._preemModSlotManager;

  if(Equals(preemSettings.ModSlotPosition, PreemWeaponsmithModSlotPosition.BelowWeapon))
  {
    this._preemGridMelee.AddClassGroup(bladeGroup, 2, 2);
    this._preemGridMelee.AddClassGroup(handleGroup, 2, 0);
  }
  else{
    this._preemGridMelee.AddClassGroup(bladeGroup, 1, 2);
    this._preemGridMelee.AddClassGroup(handleGroup, 1, 0);
  }
}

@addMethod(CraftingMainGameController)
protected func CreateUIPreemSlotDataForRanged()
{
  let barrelSlot1Data = new PreemSlot();
  let barrelSlot2Data = new PreemSlot();
  let triggerSlot1Data = new PreemSlot();
  let triggerSlot2Data = new PreemSlot();
  let magSlot1Data = new PreemSlot();
  let magSlot2Data = new PreemSlot();
  barrelSlot1Data.SetSlotName(this._barrelSlot1.GetName());
  barrelSlot2Data.SetSlotName(this._barrelSlot2.GetName());
  triggerSlot1Data.SetSlotName(this._triggerSlot1.GetName());
  triggerSlot2Data.SetSlotName(this._triggerSlot2.GetName());
  magSlot1Data.SetSlotName(this._magSlot1.GetName());
  magSlot2Data.SetSlotName(this._magSlot2.GetName());
  barrelSlot1Data.preemClassType = PreemModClassType.Barrel;
  barrelSlot2Data.preemClassType = PreemModClassType.Barrel;
  triggerSlot1Data.preemClassType = PreemModClassType.Trigger;
  triggerSlot2Data.preemClassType = PreemModClassType.Trigger;
  magSlot1Data.preemClassType = PreemModClassType.Mag;
  magSlot2Data.preemClassType = PreemModClassType.Mag;

  this._barrelSlot1.SetSlotData(barrelSlot1Data);
  this._barrelSlot2.SetSlotData(barrelSlot2Data);
  this._triggerSlot1.SetSlotData(triggerSlot1Data);
  this._triggerSlot2.SetSlotData(triggerSlot2Data);
  this._magSlot1.SetSlotData(magSlot1Data);
  this._magSlot2.SetSlotData(magSlot2Data);
}

@addMethod(CraftingMainGameController)
protected func CreateUIPreemSlotDataForMelee()
{
  let bladeSlot1Data = new PreemSlot();
  let bladeSlot2Data = new PreemSlot();
  let handleSlot1Data = new PreemSlot();
  let handleSlot2Data = new PreemSlot();
  bladeSlot1Data.SetSlotName(this._bladeSlot1.GetName());
  bladeSlot2Data.SetSlotName(this._bladeSlot2.GetName());
  handleSlot1Data.SetSlotName(this._handleSlot1.GetName());
  handleSlot2Data.SetSlotName(this._handleSlot2.GetName());
  bladeSlot1Data.preemClassType = PreemModClassType.Blade;
  bladeSlot2Data.preemClassType = PreemModClassType.Blade;
  handleSlot1Data.preemClassType = PreemModClassType.Handle;
  handleSlot2Data.preemClassType = PreemModClassType.Handle;

  this._bladeSlot1.SetSlotData(bladeSlot1Data);
  this._bladeSlot2.SetSlotData(bladeSlot2Data);
  this._handleSlot1.SetSlotData(handleSlot1Data);
  this._handleSlot2.SetSlotData(handleSlot2Data);
}

@addMethod(CraftingMainGameController)
protected func SetRangedSlotsOnPreemModSlotManager()
{
  let modSlots: array<ref<PreemModSlot>>;
  ArrayPush(modSlots,this._barrelSlot1);
  ArrayPush(modSlots,this._barrelSlot2);
  ArrayPush(modSlots,this._triggerSlot1);
  ArrayPush(modSlots,this._triggerSlot2);
  ArrayPush(modSlots,this._magSlot1);
  ArrayPush(modSlots,this._magSlot2);
  this._preemModSlotManager.SetModSlotList(modSlots);
}

@addMethod(CraftingMainGameController)
protected func SetMeleeSlotsOnPreemModSlotManager()
{
  let modSlots: array<ref<PreemModSlot>>;
  ArrayPush(modSlots,this._bladeSlot1);
  ArrayPush(modSlots,this._bladeSlot2);
  ArrayPush(modSlots,this._handleSlot1);
  ArrayPush(modSlots,this._handleSlot2);
  this._preemModSlotManager.SetModSlotList(modSlots);
}

@addMethod(CraftingMainGameController)
protected cb func OnPreemModHoverOverCallBack(evt: ref<inkPointerEvent>) -> Bool {
  let itemTooltipData = new MaterialTooltipData();
  let hoveredMod = this._preemModSlotManager.GetHoveredPreemMod();
  itemTooltipData.Title = NameToString(hoveredMod.GetModName());
  itemTooltipData.preemModDescription = PreemModMaker.GetFullDescriptionFromPreemMod(hoveredMod);
  this.m_tooltipsManager.ShowTooltipAtWidget(n"materialTooltip", this._preemPopupGrid.GetContainer(), itemTooltipData, gameuiETooltipPlacement.RightTop);
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

@addMethod(CraftingMainGameController)
protected cb func OnPreemModHoverOutCallBack(evt: ref<inkPointerEvent>) -> Bool {
  this.m_tooltipsManager.HideTooltips();
}

// @addMethod(CraftingMainGameController)
// public func ChangeWidget(evt: ref<inkPointerEvent>) -> Bool {

// }

// public final static func FromInventoryItemData(itemData: InventoryItemData) -> ref<InventoryTooltipData> {
//     let attachmentName: CName;
//     let attachments: ref<InventoryItemAttachments>;
//     let attachmentsSize: Int32;
//     let i: Int32;
//     let limit: Int32;
//     let outObject: ref<InventoryTooltipData> = new InventoryTooltipData();
//     outObject.itemID = InventoryItemData.GetID(itemData);
//     outObject.isCraftable = false;
//     outObject.qualityStateName = InventoryItemData.GetQuality(itemData);
//     outObject.description = InventoryItemData.GetDescription(itemData);
//     outObject.additionalDescription = InventoryItemData.GetAdditionalDescription(itemData);
//     outObject.isBroken = InventoryItemData.IsBroken(itemData);
//     outObject.isVendorItem = InventoryItemData.IsVendorItem(itemData);
//     outObject.category = InventoryItemData.GetCategoryName(itemData);
//     outObject.quality = NameToString(InventoryItemData.GetQuality(itemData));
//     outObject.levelRequired = InventoryItemData.GetRequiredLevel(itemData);
//     outObject.itemName = InventoryItemData.GetName(itemData);
//     outObject.price = InventoryItemData.GetPrice(itemData);
//     outObject.buyPrice = InventoryItemData.GetBuyPrice(itemData);
//     outObject.FillPrimaryStats(InventoryItemData.GetPrimaryStats(itemData));
//     outObject.FillDetailedStats(InventoryItemData.GetSecondaryStats(itemData));
//     outObject.comparedQuality = InventoryItemData.GetComparedQuality(itemData);
//     outObject.damageType = InventoryItemData.GetDamageType(itemData);
//     outObject.equipArea = InventoryItemData.GetEquipmentArea(itemData);
//     outObject.itemType = InventoryItemData.GetItemType(itemData);
//     outObject.m_HasPlayerSmartGunLink = InventoryItemData.HasPlayerSmartGunLink(itemData);
//     outObject.m_PlayerLevel = InventoryItemData.GetPlayerLevel(itemData);
//     outObject.m_PlayerStrenght = InventoryItemData.GetPlayerStrenght(itemData);
//     outObject.m_PlayerReflexes = InventoryItemData.GetPlayerReflexes(itemData);
//     outObject.m_PlayerStreetCred = InventoryItemData.GetPlayerStreetCred(itemData);
//     outObject.isEquipped = InventoryItemData.IsEquipped(itemData);
//     outObject.isPerkRequired = InventoryItemData.GetIsPerkRequired(itemData);
//     outObject.perkRequiredName = InventoryItemData.GetPerkRequiredName(itemData);
//     attachmentsSize = InventoryItemData.GetAttachmentsSize(itemData);
//     i = 0;
//     limit = attachmentsSize;
//     while i < limit {
//       attachmentName = n"None";
//       attachments = InventoryItemData.GetAttachment(itemData, i);
//       if !InventoryItemData.IsEmpty(attachments.ItemData) {
//         attachmentName = InventoryItemData.GetQuality(attachments.ItemData);
//       };
//       ArrayPush(outObject.attachments, attachmentName);
//       i += 1;
//     };
//     outObject.specialAbilities = InventoryItemData.GetAbilities(itemData);
//     outObject.itemAttachments = InventoryItemData.GetAttachments(itemData);
//     outObject.inventoryItemData = itemData;
//     return outObject;
//   }

//this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", target, this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, false), gameuiETooltipPlacement.RightTop, true);