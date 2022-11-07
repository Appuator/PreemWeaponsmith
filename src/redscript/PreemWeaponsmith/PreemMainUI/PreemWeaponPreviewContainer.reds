module PreemCrafting.PreemUI
import PreemCrafting.Codeware.UI.*
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModSlotManager.*
import PreemCrafting.CraftingSystem.PreemModMaker.*


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


@wrapMethod(CraftingMainGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();
  let preemRoot: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  this._preemContainer = preemRoot.GetWidget(n"craftingPanel/inkCanvasWidget2/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  this.CreateRangedWeaponPreemFrame();
  this.CreateMeleeWeaponPreemFrame();

  LogChannel(n"DEBUG", s"CraftingMainGame:: Initialized");
}

@addMethod(CraftingMainGameController)
public func CreateRangedWeaponPreemFrame() -> Void
{
  LogChannel(n"DEBUG", s"CraftingMainGame:: RangedItemSelected");
  // let preemRoot: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  // this._preemContainer = preemRoot.GetWidget(n"craftingPanel/inkCanvasWidget2/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  this._preemGridRanged = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(3,4));
  this._preemGridRanged.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.CreateUIPreemSlotsForRanged();
  this._preemGridRanged.Reparent(this._preemContainer);
}

@addMethod(CraftingMainGameController)
public func CreateMeleeWeaponPreemFrame() -> Void
{
  LogChannel(n"DEBUG", s"CraftingMainGame:: MeleeItemSelected");
  // let preemRoot: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  // this._preemContainer = preemRoot.GetWidget(n"craftingPanel/inkCanvasWidget2/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  this._preemGridMelee = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(3,4));
  this._preemGridMelee.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.CreateUIPreemSlotsForMelee();
  this._preemGridMelee.Reparent(this._preemContainer);
}

@addMethod(CraftingMainGameController)
public func SetWeaponPreemFrameToRanged() -> Void
{
  LogChannel(n"DEBUG", s"CraftingMainGame:: RangedItemSelected");
  this._preemGridRanged.SetVisible(true);
  this._preemGridMelee.SetVisible(false);
  this._preemGridRanged.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this._preemGridMelee.UnregisterFromCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.ClearCurrentPreemSlots();
  this.CreateUIPreemSlotsForRanged();

  // this._preemGridRanged.Reparent(null);
  // this._preemGridMelee.Reparent(null);
  // this.ClearCurrentWeaponPreemFrame();
  // this.CreateRangedWeaponPreemFrame();
  // this._barrelSlot1 = null
  // this._barrelSlot2 = null;
  // this._triggerSlot1 = null;
  // this._triggerSlot2 = null;
  // this._magSlot1 = null;
  // this._magSlot2 = null;
  // this._bladeSlot1 = null;
  // this._bladeSlot2 = null;
  // this._handleSlot1 = null;
  // this._handleSlot1 = null;
}

@addMethod(CraftingMainGameController)
public func SetWeaponPreemFrameToMelee() -> Void
{
  LogChannel(n"DEBUG", s"CraftingMainGame:: MeleeItemSelected");
  this._preemGridRanged.SetVisible(false);
  this._preemGridMelee.SetVisible(true);
  this._preemGridRanged.UnregisterFromCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this._preemGridMelee.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.ClearCurrentPreemSlots();
  this.CreateUIPreemSlotsForMelee();
  // this._preemGridRanged.Reparent(null);
  // this._preemGridMelee.Reparent(null);
  // this._barrelSlot1 = null;
  // this._barrelSlot2 = null;
  // this._triggerSlot1 = null;
  // this._triggerSlot2 = null;
  // this._magSlot1 = null;
  // this._magSlot2 = null;
  // this._bladeSlot1 = null;
  // this._bladeSlot2 = null;
  // this._handleSlot1 = null;
  // this._handleSlot1 = null;
}

@addMethod(CraftingMainGameController)
public func ClearCurrentWeaponPreemFrame() -> Void
{
  LogChannel(n"DEBUG", s"CraftingMainGame:: cleared frame");
  this.ClearMods();
  this._preemModSlotManager = null;
  this._preemGridRanged = null;
  this._preemGridMelee = null;
  this._barrelSlot1 = null;
  this._barrelSlot2 = null;
  this._triggerSlot1 = null;
  this._triggerSlot2 = null;
  this._magSlot1 = null;
  this._magSlot2 = null;
  this._bladeSlot1 = null;
  this._bladeSlot2 = null;
  this._handleSlot1 = null;
  this._handleSlot1 = null;
}

@addMethod(CraftingMainGameController)
public func ClearCurrentPreemSlots() -> Void
{
  LogChannel(n"DEBUG", s"CraftingMainGame:: cleared frame");
  this.ClearMods();
  this._preemModSlotManager = null;
  this._barrelSlot1.Reparent(null);
  this._barrelSlot2.Reparent(null);
  this._triggerSlot1.Reparent(null);
  this._triggerSlot2.Reparent(null);
  this._magSlot1.Reparent(null);
  this._magSlot2.Reparent(null);
  this._bladeSlot1.Reparent(null);
  this._bladeSlot2.Reparent(null);
  this._handleSlot1.Reparent(null);
  this._handleSlot1.Reparent(null);
  this._barrelSlot1 = null;
  this._barrelSlot2 = null;
  this._triggerSlot1 = null;
  this._triggerSlot2 = null;
  this._magSlot1 = null;
  this._magSlot2 = null;
  this._bladeSlot1 = null;
  this._bladeSlot2 = null;
  this._handleSlot1 = null;
  this._handleSlot1 = null;
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
  item.SetName(preemMod.GetModName());

  let itemData = preemMod;
  
  item.SetModData(itemData);
  item.preemModSlotManager = this._preemModSlotManager;

  return item;
}

@addMethod(CraftingMainGameController)
public cb func OnPreemSlotClickedCallBack(widget: wref<inkWidget>) -> Bool
{
  LogChannel(n"DEBUG", s"CraftingUI:: PreemSlotClicked!");
  this._preemPopupGrid = this.CreatePreemPopupGrid(this._preemModSlotManager.GetCurrentlySelectedPreemSlot().GetSlotData().preemClassType);
  PreemModSelectorPopup.Show(this,this._preemPopupGrid);
}

@addMethod(CraftingMainGameController)
public cb func OnPreemModSelectedCallBack(widget: wref<inkWidget>) -> Bool
{ 
  // if IsDefined(this._currentPopup)
  // {
  //   this._currentPopup.Close();
  // }
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
  selectedModList = this._preemModSlotManager.GetCurrentSlottedMods();
  //LogChannel(n"DEBUG", s"PreemUI WeaponContainer::\(selectedModList)");

  let craftingRecord = this.m_craftingLogicController.m_selectedRecipe.id as WeaponItem_Record;
  if IsDefined(craftingRecord){
    preemCraftingSystem.SetCurrentWeaponEvo(craftingRecord.Evolution().Type());
  }
  preemCraftingSystem.SetModList(selectedModList);
  this.m_craftingLogicController.UpdateRecipePreviewPanel(this.m_craftingLogicController.m_selectedRecipe);
}

@wrapMethod(CraftingMainGameController)
protected cb func OnCraftingComplete(value: Variant) -> Bool {
  wrappedMethod(value);
  this._preemModSlotManager.ClearCurrentSlots();
}

@addMethod(CraftingMainGameController)
public func ClearMods() -> Void
{
  let preemCraftingSystem = PreemCraftingSystem.GetInstance(this.m_player.GetGame());
  this._preemModSlotManager.ClearCurrentSlots();
  preemCraftingSystem.ClearMods();
}


// protected cb func OnItemSelect(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Bool {
//     this.UpdateItemPreview(next as CraftableItemLogicController);
//     this.PlaySound(n"Button", n"OnPress");
//   }
@wrapMethod(CraftingMainLogicController)
protected cb func OnItemSelect(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Bool {
    wrappedMethod(previous,next);
    LogChannel(n"DEBUG", s"CraftingMainLogic:: ItemSelected");
    this.m_craftingGameController.ClearMods();
    let itemController: ref<CraftableItemLogicController> = next as CraftableItemLogicController;
    let preemItemType: gamedataItemType;
    let rangedWeaponItemTypeList: array<gamedataItemType>;
    let meleeWeaponItemTypeList: array<gamedataItemType>;
    rangedWeaponItemTypeList = PreemCraftingSystem.GetRangedWeaponsItemsTypeList();
    meleeWeaponItemTypeList = PreemCraftingSystem.GetMeleeWeaponsItemsTypeList();

    if IsDefined(itemController){
      LogChannel(n"DEBUG", s"CraftingMainLogic:: itemController: \(itemController)");
      preemItemType = itemController.m_recipeData.id.ItemType().Type();
      LogChannel(n"DEBUG", s"CraftingMainLogic:: recipeItemType: \(preemItemType)");
      LogChannel(n"DEBUG", s"CraftingMainLogic:: recipeItemType: \(rangedWeaponItemTypeList)");
      LogChannel(n"DEBUG", s"CraftingMainLogic:: recipeItemType: \(meleeWeaponItemTypeList)");
      if(ArrayContains(rangedWeaponItemTypeList,preemItemType))
      {
        LogChannel(n"DEBUG", s"CraftingMainLogic:: RangedItemSelected");
        this.m_craftingGameController.SetWeaponPreemFrameToRanged();
      }
      else{
        if(ArrayContains(meleeWeaponItemTypeList,preemItemType))
        {
          LogChannel(n"DEBUG", s"CraftingMainLogic:: MeleeItemSelected");
          this.m_craftingGameController.SetWeaponPreemFrameToMelee();
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

  this._preemModSlotManager = new PreemModSlotManager();
  this._preemModSlotManager.AddModSlot(this._barrelSlot1);
  this._preemModSlotManager.AddModSlot(this._barrelSlot2);
  this._preemModSlotManager.AddModSlot(this._triggerSlot1);
  this._preemModSlotManager.AddModSlot(this._triggerSlot2);
  this._preemModSlotManager.AddModSlot(this._magSlot1);
  this._preemModSlotManager.AddModSlot(this._magSlot2);

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
  magGroup.SetCurrentOrientation(SlotClassGroupOrientation.Vertical);
  magGroup.SetClassLabel("Mag");
  magGroup.AddSlot(this._magSlot1);
  magGroup.AddSlot(this._magSlot2);
  magGroup.preemModSlotManager = this._preemModSlotManager;

  this._preemGridRanged.AddClassGroup(magGroup, 1, 0);
  this._preemGridRanged.AddClassGroup(triggerGroup, 1, 1);
  this._preemGridRanged.AddClassGroup(barrelGroup, 0, 2);
}

@addMethod(CraftingMainGameController)
protected func CreateUIPreemSlotsForMelee()
{
  this._bladeSlot1 = PreemModSlot.Create();
  this._bladeSlot2 = PreemModSlot.Create();
  this._handleSlot1 = PreemModSlot.Create();
  this._handleSlot2 = PreemModSlot.Create();
  this._bladeSlot1.SetName(n"Slot1Blade");
  this._bladeSlot2.SetName(n"Slot2Blade");
  this._handleSlot1.SetName(n"Slot1Handle");
  this._handleSlot2.SetName(n"Slot2Handle");

  this.CreateUIPreemSlotDataForMelee();

  this._preemModSlotManager = new PreemModSlotManager();
  this._preemModSlotManager.AddModSlot(this._bladeSlot1);
  this._preemModSlotManager.AddModSlot(this._bladeSlot2);
  this._preemModSlotManager.AddModSlot(this._handleSlot1);
  this._preemModSlotManager.AddModSlot(this._handleSlot2);

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

  this._preemGridMelee.AddClassGroup(bladeGroup, 1, 2);
  this._preemGridMelee.AddClassGroup(handleGroup, 1, 0);
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