module PreemCrafting.PreemUI
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModSlotManager.*
import PreemCrafting.CraftingSystem.PreemModMaker.*
import PreemCrafting.CraftingSystem.ModInstaller.*
import PreemCrafting.CraftingSystem.PreemModUnlocker.*
import Codeware.UI.*

// What a screen that shows a PreemSlotFrame supplies. Each screen (crafting, upgrade) subclasses
// it with a reference to its own game controller; the frame never touches the screen's fields.
public abstract class PreemSlotFrameHost extends IScriptable {
  // The controller popups open on.
  public func GetGameController() -> wref<inkGameController> { return null; }
  public func GetPlayer() -> wref<PlayerPuppet> { return null; }
  public func GetTooltipsManager() -> wref<gameuiTooltipsManager> { return null; }
  // The rarity that decides which mods are unlocked.
  public func GetWeaponQuality() -> gamedataQuality { return gamedataQuality.Invalid; }
  // The slotted mods changed (a mod was picked, or the settings rebuilt the frame).
  public func OnPreemModsChanged() -> Void {}
  // Drop the chosen mods: the frame's slots and whatever the screen keeps of them.
  public func ClearPreemMods() -> Void {}
  // Whether the mod selector offers this mod (a refused one shows disabled).
  public func IsModAllowed(mod: ref<PreemMod>) -> Bool { return true; }
  // One row of slot groups, for a screen with little room (otherwise the settings' slot layout).
  public func UseStripLayout() -> Bool { return false; }
}

// The Preem slot frame (SPEC §2): the ranged and melee slot grids, the mod selector popup a slot
// opens, and the SETTINGS button with its popup. Built into a container widget of the host
// screen; only one grid shows at a time.
public class PreemSlotFrame extends IScriptable {
  private let m_host: ref<PreemSlotFrameHost>;
  private let m_container: wref<inkCompoundWidget>;

  private let _triggerSlot1: ref<PreemModSlot>;
  private let _triggerSlot2: ref<PreemModSlot>;
  private let _barrelSlot1: ref<PreemModSlot>;
  private let _barrelSlot2: ref<PreemModSlot>;
  private let _magSlot1: ref<PreemModSlot>;
  private let _magSlot2: ref<PreemModSlot>;
  private let _bladeSlot1: ref<PreemModSlot>;
  private let _bladeSlot2: ref<PreemModSlot>;
  private let _handleSlot1: ref<PreemModSlot>;
  private let _handleSlot2: ref<PreemModSlot>;

  private let _preemGridRanged: ref<PreemGrid>;
  private let _preemGridMelee: ref<PreemGrid>;
  private let _preemPopupGrid: ref<PreemGrid>;
  private let _preemModSlotManager: ref<PreemModSlotManager>;
  private let _preemModMapper: ref<PreemModMapper>;
  private let _preemModUnlocker: ref<PreemModUnlocker>;
  private let _preemSettingsButton: ref<BasePreemButton>;
  private let _preemSettingsPopup: wref<PreemSettingsPopup>;

  public static func Create(host: ref<PreemSlotFrameHost>, container: wref<inkCompoundWidget>) -> ref<PreemSlotFrame> {
    let frame = new PreemSlotFrame();
    frame.m_host = host;
    frame.m_container = container;
    frame._preemModMapper = new PreemModMapper();
    frame._preemModUnlocker = new PreemModUnlocker();
    frame._preemModSlotManager = new PreemModSlotManager();
    frame.CreateRangedWeaponPreemFrame();
    frame.CreateMeleeWeaponPreemFrame();
    frame.SetWeaponPreemFrameToRanged();
    // A strip has no room for the SETTINGS button; the crafting screen's frame has it.
    if !host.UseStripLayout() {
      frame.CreatePreemSettingsButton();
    }
    return frame;
  }

  public func GetSlottedMods() -> array<ref<PreemMod>> {
    return this._preemModSlotManager.GetCurrentSlottedMods();
  }

  public func ClearSlots() -> Void {
    this._preemModSlotManager.ClearCurrentSlots();
  }

  // Shows the Preem mods an owned item already has (PreemCraftingSystem.GetInstalledMods) in their
  // slots. A Silencer in the muzzle slot (weapons from 2.4.x, ADR 0002) takes the barrel slot the
  // other barrel leaves.
  public func ShowInstalledMods(installed: array<ref<PreemModPlacement>>) -> Void {
    this.ClearSlots();
    let silencer: ref<PreemMod>;
    let barrel1Used = false;
    for placement in installed {
      let slot = placement.slotID;
      if slot == t"AttachmentSlots.PreemBarrelMod01" { this._barrelSlot1.InstallPreemMod(placement.mod); barrel1Used = true; }
      if slot == t"AttachmentSlots.PreemBarrelMod02" { this._barrelSlot2.InstallPreemMod(placement.mod); }
      if slot == t"AttachmentSlots.PowerModule" { silencer = placement.mod; }
      if slot == t"AttachmentSlots.PreemTriggerMod01" { this._triggerSlot1.InstallPreemMod(placement.mod); }
      if slot == t"AttachmentSlots.PreemTriggerMod02" { this._triggerSlot2.InstallPreemMod(placement.mod); }
      if slot == t"AttachmentSlots.PreemMagazineMod01" { this._magSlot1.InstallPreemMod(placement.mod); }
      if slot == t"AttachmentSlots.PreemMagazineMod02" { this._magSlot2.InstallPreemMod(placement.mod); }
      if slot == t"AttachmentSlots.PreemBladeMod01" { this._bladeSlot1.InstallPreemMod(placement.mod); }
      if slot == t"AttachmentSlots.PreemBladeMod02" { this._bladeSlot2.InstallPreemMod(placement.mod); }
      if slot == t"AttachmentSlots.PreemHandleMod01" { this._handleSlot1.InstallPreemMod(placement.mod); }
      if slot == t"AttachmentSlots.PreemHandleMod02" { this._handleSlot2.InstallPreemMod(placement.mod); }
    }
    if IsDefined(silencer) {
      if barrel1Used {
        this._barrelSlot2.InstallPreemMod(silencer);
      } else {
        this._barrelSlot1.InstallPreemMod(silencer);
      }
    }
  }

  public func GetRangedGrid() -> ref<PreemGrid> { return this._preemGridRanged; }
  public func GetMeleeGrid() -> ref<PreemGrid> { return this._preemGridMelee; }
  public func GetSettingsButton() -> ref<BasePreemButton> { return this._preemSettingsButton; }
  public func GetSettingsPopup() -> wref<PreemSettingsPopup> { return this._preemSettingsPopup; }

  // The per-save Preem settings (PreemSettings).
  public func GetPreemSettings() -> ref<PreemSettings> {
    return PreemSettings.GetInstance(this.m_host.GetPlayer().GetGame());
  }

  // The SETTINGS button at the top right of the Preem slot area; opens PreemSettingsPopup.
  protected func CreatePreemSettingsButton() -> Void {
    let button = BasePreemButton.Create();
    button.SetText("SETTINGS");
    button.ToggleAnimations(true);
    button.ToggleSounds(true);
    let root = button.GetRootWidget();
    root.SetSize(new Vector2(220.0, 64.0));
    root.SetAnchor(inkEAnchor.TopRight);
    root.SetAnchorPoint(new Vector2(1.0, 0.0));
    root.SetMargin(new inkMargin(0.0, 10.0, 10.0, 0.0));
    button.RegisterToCallback(n"OnBtnClick", this, n"OnPreemSettingsClicked");
    button.Reparent(this.m_container);
    this._preemSettingsButton = button;
  }

  public cb func OnPreemSettingsClicked(widget: wref<inkWidget>) -> Bool {
    this._preemSettingsPopup = PreemSettingsPopup.Show(this.m_host.GetGameController(), this, this.GetPreemSettings());
  }

  // Applies changed settings at once: the chosen mods are cleared (the limit or unlocks may no
  // longer allow them), both slot frames are rebuilt (the layout picks the grid shape), the frame
  // that was showing stays, and the host refreshes (the craft button).
  public func ApplyPreemSettings() -> Void {
    let meleeShown = this._preemGridMelee.GetRootWidget().IsVisible();
    this.m_host.ClearPreemMods();
    this.m_container.RemoveChild(this._preemGridRanged.GetRootWidget());
    this.m_container.RemoveChild(this._preemGridMelee.GetRootWidget());
    this.CreateRangedWeaponPreemFrame();
    this.CreateMeleeWeaponPreemFrame();
    if meleeShown {
      this.SetWeaponPreemFrameToMelee();
    } else {
      this.SetWeaponPreemFrameToRanged();
    }
    // Recreate the button so it sits above the rebuilt frames (reparenting the removed one left it
    // hidden).
    if IsDefined(this._preemSettingsButton) {
      this.m_container.RemoveChild(this._preemSettingsButton.GetRootWidget());
      this.CreatePreemSettingsButton();
    }
    this.m_host.OnPreemModsChanged();
  }

  public func CreateRangedWeaponPreemFrame() -> Void
  {
    let preemSettings = this.GetPreemSettings();
    if this.m_host.UseStripLayout()
    {
      // BasePreemGrid divides the width by the row count and the height by the column count, so
      // this gives the 133 x 100 cells of the 6x8 layout's bottom row.
      this._preemGridRanged = PreemGrid.Create(new Vector2(133.33,800.0),new Vector2(1,8));
    }
    else if(Equals(preemSettings.GetSlotLayout(), PreemWeaponsmithModSlotPosition.BelowWeapon))
    {
      this._preemGridRanged = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(6,8));
    }
    else{
      this._preemGridRanged = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(3,4));
    }

    this._preemGridRanged.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
    this.CreateUIPreemSlotsForRanged();
    this._preemGridRanged.Reparent(this.m_container);
  }

  public func CreateMeleeWeaponPreemFrame() -> Void
  {
    // Strip: the 3x4 layout's 266-wide cells in one row, 100 tall like the ranged strip (see
    // CreateRangedWeaponPreemFrame); 200-tall cells centred the groups 50 lower, onto the button.
    if this.m_host.UseStripLayout()
    {
      this._preemGridMelee = PreemGrid.Create(new Vector2(266.67,400.0),new Vector2(1,4));
    }
    else
    {
      this._preemGridMelee = PreemGrid.Create(new Vector2(800.0,800.0),new Vector2(3,4));
    }

    this._preemGridMelee.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
    this.CreateUIPreemSlotsForMelee();
    this._preemGridMelee.Reparent(this.m_container);
  }

  public func SetWeaponPreemFrameToRanged() -> Void
  {
    this._preemGridRanged.SetVisible(true);
    this._preemGridMelee.SetVisible(false);
    this._preemGridRanged.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
    this._preemGridMelee.UnregisterFromCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
    this.SetRangedSlotsOnPreemModSlotManager();
  }

  public func SetWeaponPreemFrameToMelee() -> Void
  {
    this._preemGridRanged.SetVisible(false);
    this._preemGridMelee.SetVisible(true);
    this._preemGridRanged.UnregisterFromCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
    this._preemGridMelee.RegisterToCallback(n"OnPreemSlotClicked", this, n"OnPreemSlotClickedCallBack");
    this.SetMeleeSlotsOnPreemModSlotManager();
  }

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

  public func CreatePreemModItemFromPreemMod(preemMod: ref<PreemMod>) -> ref<PreemModItem>
  {
    let item = PreemModItem.Create();
    let isUnlocked: Bool = true;
    item.SetName(preemMod.GetModName());

    let itemData = preemMod;
    if(IsDefined(this._preemModUnlocker))
    {
      let settings = this.GetPreemSettings();
      let player = this.m_host.GetPlayer();
      this._preemModUnlocker.SetModes(settings.GetUnlockMode(), settings.GetLimitMode());
      this._preemModUnlocker.SetDevSystem(player);
      this._preemModUnlocker.SetWeaponQuality(this.m_host.GetWeaponQuality());
      isUnlocked = this._preemModUnlocker.DetermineModUnlocked(preemMod.modStyleType, player);
      itemData.setIsUnlocked(isUnlocked);
    }

    if !this.m_host.IsModAllowed(preemMod)
    {
      isUnlocked = false;
      itemData.setIsUnlocked(false);
    }

    item.SetModData(itemData);
    item.SetDisabled(!isUnlocked);

    item.preemModSlotManager = this._preemModSlotManager;

    return item;
  }

  public cb func OnPreemSlotClickedCallBack(widget: wref<inkWidget>) -> Bool
  {
    if IsDefined(this._preemModSlotManager)
    {
      this._preemPopupGrid = this.CreatePreemPopupGrid(this._preemModSlotManager.GetCurrentlySelectedPreemSlot().GetSlotData().preemClassType);
      PreemModSelectorPopup.Show(this.m_host.GetGameController(),this._preemPopupGrid,this.m_host.GetTooltipsManager());
    }
  }

  public cb func OnPreemModSelectedCallBack(widget: wref<inkWidget>) -> Bool
  {
    this.m_host.OnPreemModsChanged();
  }

  protected func CreateUIPreemSlotsForRanged()
  {
    let preemSettings = this.GetPreemSettings();
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

    // AddSlot puts a slot in the row of the current orientation, so set it before adding the slots.
    let magGroup =  PreemSlotClassGroup.Create();
    if this.m_host.UseStripLayout() || Equals(preemSettings.GetSlotLayout(), PreemWeaponsmithModSlotPosition.BelowWeapon)
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

    if this.m_host.UseStripLayout()
    {
      this._preemGridRanged.AddClassGroup(magGroup, 0, 0);
      this._preemGridRanged.AddClassGroup(triggerGroup, 0, 3);
      this._preemGridRanged.AddClassGroup(barrelGroup, 0, 6);
    }
    else if(Equals(preemSettings.GetSlotLayout(), PreemWeaponsmithModSlotPosition.BelowWeapon))
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

  protected func CreateUIPreemSlotsForMelee()
  {
    let preemSettings = this.GetPreemSettings();
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

    if this.m_host.UseStripLayout()
    {
      this._preemGridMelee.AddClassGroup(bladeGroup, 0, 2);
      this._preemGridMelee.AddClassGroup(handleGroup, 0, 0);
    }
    else if(Equals(preemSettings.GetSlotLayout(), PreemWeaponsmithModSlotPosition.BelowWeapon))
    {
      this._preemGridMelee.AddClassGroup(bladeGroup, 2, 2);
      this._preemGridMelee.AddClassGroup(handleGroup, 2, 0);
    }
    else{
      this._preemGridMelee.AddClassGroup(bladeGroup, 1, 2);
      this._preemGridMelee.AddClassGroup(handleGroup, 1, 0);
    }
  }

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

  protected func SetMeleeSlotsOnPreemModSlotManager()
  {
    let modSlots: array<ref<PreemModSlot>>;
    ArrayPush(modSlots,this._bladeSlot1);
    ArrayPush(modSlots,this._bladeSlot2);
    ArrayPush(modSlots,this._handleSlot1);
    ArrayPush(modSlots,this._handleSlot2);
    this._preemModSlotManager.SetModSlotList(modSlots);
  }

  protected cb func OnPreemModHoverOverCallBack(evt: ref<inkPointerEvent>) -> Bool {
    let itemTooltipData = new MaterialTooltipData();
    let hoveredMod = this._preemModSlotManager.GetHoveredPreemMod();
    itemTooltipData.Title = NameToString(hoveredMod.GetModName());
    itemTooltipData.preemModDescription = PreemModMaker.GetFullDescriptionFromPreemMod(hoveredMod, this.GetPreemSettings().GetUnlockMode());
    this.m_host.GetTooltipsManager().ShowTooltipAtWidget(n"materialTooltip", this._preemPopupGrid.GetContainer(), itemTooltipData, gameuiETooltipPlacement.RightTop);
  }

  protected cb func OnPreemModHoverOutCallBack(evt: ref<inkPointerEvent>) -> Bool {
    this.m_host.GetTooltipsManager().HideTooltips();
  }
}
