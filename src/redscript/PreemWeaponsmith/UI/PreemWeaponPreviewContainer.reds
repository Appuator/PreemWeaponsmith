module PreemCrafting.UI
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
private let _preemGrid: ref<PreemGrid>;

@addField(CraftingMainGameController)
private let _popupGrid: ref<PreemGrid>;

@addField(CraftingMainGameController)
private let _currentPopup: ref<PreemModSelectorPopup>;

@addField(CraftingMainGameController)
private let _preemModSlotManager: ref<PreemModSlotManager>;


// -- Inject text input into CraftingLogicController
@wrapMethod(CraftingMainGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();

  // Insert input
  let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
  let outerContainer: ref<inkCompoundWidget> = root.GetWidget(n"craftingPanel/inkCanvasWidget2/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  this._preemGrid = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(3,4));
  this._preemGrid.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
  this.CreateUISlots();
  this._preemGrid.Reparent(outerContainer);

  //LogChannel(n"DEBUG", s"CraftingUI::\(modSlot1)");
}

@addMethod(CraftingMainGameController)
public func CreatePopupGrid(modClassType: PreemModClassType) -> ref<PreemGrid>
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
  // let button: ref<CustomButton> = widget.GetController() as CustomButton;
  // let buttonName: CName = button.GetName();
  //LogChannel(n"DEBUG", s"PreemUI WeaponContainer::\(buttonName)");

  this._popupGrid = this.CreatePopupGrid(this._preemModSlotManager.GetCurrentlySelectedPreemSlot().GetSlotData().preemClassType);
  this._currentPopup = PreemModSelectorPopup.Create(this._popupGrid);
  this._currentPopup.Show(this);
}

@addMethod(CraftingMainGameController)
public cb func OnPreemModSelectedCallBack(widget: wref<inkWidget>) -> Bool
{ 
  if IsDefined(this._currentPopup)
  {
    this._currentPopup.Close();
  }
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

  preemCraftingSystem.SetModList(selectedModList);
  this.m_craftingLogicController.UpdateRecipePreviewPanel(this.m_craftingLogicController.m_selectedRecipe);
}

@wrapMethod(CraftingMainGameController)
protected cb func OnCraftingComplete(value: Variant) -> Bool {
  let result = wrappedMethod(value);
  this._preemModSlotManager.ClearCurrentSlots();
  return result;
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
public func CreateUISlots()
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

  this.CreateUISlotData();

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

  this._preemGrid.AddClassGroup(magGroup, 1, 0);
  this._preemGrid.AddClassGroup(triggerGroup, 1, 1);
  this._preemGrid.AddClassGroup(barrelGroup, 0, 2);
}

@addMethod(CraftingMainGameController)
public func CreateUISlotData()
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