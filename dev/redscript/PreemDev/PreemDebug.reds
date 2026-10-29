// Dev only, never shipped. Crafting debug commands for the CET console (need a loaded save):
//   Game.PreemCraftTest("Items.Preset_Ajax_Default", "Barrel_Smart, Trigger_FullAuto")
//     Gives the player the record CraftItem would craft for these mods
//     (PreemCraftingSystem.GetCraftRecord) and installs the mods on it through
//     PreemCraftingSystem.ApplyMods, the same path a real craft takes. Mods are PreemModStyleType
//     names; the install requests finish a moment later.
//   Game.PreemEquipTest()   equips that weapon, so WeaponObject.OnGameAttached applies the
//     trigger mode from its mods.
//   Game.PreemDump()        prints the weapon's record, evolution, trigger modes and installed
//     Preem mods.
//   Game.PreemApplyTest("Barrel_Smart, Trigger_Burst")  applies a mod set to that (owned) weapon
//     through ApplyMods; Game.PreemReadBackTest(label, "PreemBarrelMod01=Barrel_Smart, ...")
//     checks PreemCraftingSystem.GetInstalledMods and the Preem mod items in the inventory.
//   Game.PreemShowSettings() prints the per-save settings (PreemSettings);
//   Game.PreemSetSettings(unlock, limit, layout) sets them (enum values: 0 = Sandbox or On Weapon,
//     1 = Weapon Blueprints or Below Weapon).
// Output goes through FTLog (CET gamelog.log, written when the game exits) with a [PreemDev]
// prefix. Like PreemPing, this file has no `module` line: CET finds exec functions by bare name.
// The commands need the mod; with only the dev code installed they say so.

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.PreemModMaker.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.ModInstaller.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.Core.*
import PreemDev.*
import PreemDev.Addon.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Addons.*

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemCraftTest(gi: GameInstance, record: String, mods: String) -> Void {
  let player = GetPlayer(gi);
  if !IsDefined(player) {
    FTLog("[PreemDev] craft-test: no player; load a save first");
    return;
  }
  let base = TweakDBInterface.GetItemRecord(TDBID.Create(record));
  if !IsDefined(base) {
    FTLog("[PreemDev] craft-test: no item record " + record);
    return;
  }
  let modList: array<ref<PreemMod>>;
  let styles: array<PreemModStyleType>;
  if StrLen(StrReplaceAll(mods, " ", "")) > 0 {
    for name in StrSplit(mods, ",") {
      let mod = PreemDebug.ModByName(StrReplaceAll(name, " ", ""));
      if !IsDefined(mod) {
        FTLog("[PreemDev] craft-test: unknown mod " + name + "; use PreemModStyleType names, e.g. Barrel_Smart");
        return;
      }
      ArrayPush(modList, mod);
      ArrayPush(styles, mod.modStyleType);
    }
  }
  let weapon = base as WeaponItem_Record;
  let evolution = IsDefined(weapon) && IsDefined(weapon.Evolution()) ? weapon.Evolution().Type() : gamedataWeaponEvolution.Invalid;
  if !PreemCraftingSystem.AreModsCompatible(modList, evolution) {
    FTLog("[PreemDev] craft-test: warning: the crafting screen would refuse this mod set (required or incompatible mods)");
  }

  let craftRecord = PreemCraftingSystem.GetCraftRecord(base, styles);
  let itemID = ItemID.FromTDBID(craftRecord.GetID());
  let ts = GameInstance.GetTransactionSystem(gi);
  PreemDebug.System(gi).modStockBeforeApply = PreemDebug.ModStock(gi);
  ts.GiveItem(player, itemID, 1);
  let itemData = ts.GetItemData(player, itemID);
  if !IsDefined(itemData) {
    FTLog("[PreemDev] craft-test: GiveItem gave no item data for " + record);
    return;
  }
  let preem = PreemCraftingSystem.GetInstance(gi);
  if !IsDefined(preem) {
    FTLog("[PreemDev] craft-test: PreemCraftingSystem not found");
    return;
  }
  preem.SetModList(modList);
  preem.ApplyMods(gi, itemData);
  preem.ClearMods();
  PreemDebug.System(gi).lastTestItem = itemID;
  PreemDebug.System(gi).testItemEquipRequested = false;
  FTLog(s"[PreemDev] craft-test: gave \(record) as \(PreemDebug.Describe(craftRecord.GetID(), base.GetID())), installing \(ArraySize(modList)) mods");
}

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemEquipTest(gi: GameInstance) -> Void {
  let player = GetPlayer(gi);
  let itemID = PreemDebug.System(gi).lastTestItem;
  if !IsDefined(player) || !ItemID.IsValid(itemID) {
    FTLog("[PreemDev] equip-test: no player or no test weapon; run PreemCraftTest first");
    return;
  }
  let request = new EquipRequest();
  request.owner = player;
  request.itemID = itemID;
  request.slotIndex = 0;
  GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem").QueueRequest(request);
  PreemDebug.System(gi).testItemEquipRequested = true;
  FTLog("[PreemDev] equip-test: equip requested");
}

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemDump(gi: GameInstance) -> Void {
  let player = GetPlayer(gi);
  let itemID = PreemDebug.System(gi).lastTestItem;
  if !IsDefined(player) || !ItemID.IsValid(itemID) {
    FTLog("[PreemDev] dump: no player or no test weapon; run PreemCraftTest first");
    return;
  }
  let id = ItemID.GetTDBID(itemID);
  let record = TweakDBInterface.GetWeaponItemRecord(id);
  let evolution = IsDefined(record) && IsDefined(record.Evolution()) ? record.Evolution().Type() : gamedataWeaponEvolution.Invalid;
  let primary = IsDefined(record) && IsDefined(record.PrimaryTriggerMode()) ? record.PrimaryTriggerMode().Type() : gamedataTriggerMode.Invalid;
  FTLog("[PreemDev] dump: record " + TDBID.ToStringDEBUG(id) + ", evolution " + PreemDebug.EvolutionName(evolution) + ", record trigger " + PreemDebug.TriggerName(primary));

  // Trigger mode as the equipped weapon object runs it (set by our OnGameAttached wrap).
  let active = GameObject.GetActiveWeapon(player);
  if IsDefined(active) && active.GetItemID() == itemID {
    FTLog("[PreemDev] dump: equipped, current trigger " + PreemDebug.TriggerName(active.GetCurrentTriggerMode().Type()) + ", Preem trigger " + PreemDebug.TriggerName(active.GetTriggerTypeBasedOnPreemMods()));
  } else {
    FTLog("[PreemDev] dump: not the active weapon (run PreemEquipTest to see the trigger mode it runs with)");
  }

  let itemData = GameInstance.GetTransactionSystem(gi).GetItemData(player, itemID);
  let slots = PreemDebug.PreemSlots();
  let installed = 0;
  for slot in slots {
    if IsDefined(itemData) && itemData.HasPartInSlot(slot) {
      let part: InnerItemData;
      itemData.GetItemPart(part, slot);
      FTLog("[PreemDev] dump: mod " + TDBID.ToStringDEBUG(slot) + " = " + PreemDebug.ModNameOf(ItemID.GetTDBID(InnerItemData.GetItemID(part))));
      installed += 1;
    }
  }
  FTLog(s"[PreemDev] dump: \(installed) Preem mods installed");

  // Why a mod might not install: the slot must exist on the item (from its blueprint) and the mod
  // item must be in the player's inventory.
  if IsDefined(itemData) {
    let used: array<TweakDBID>;
    let empty: array<TweakDBID>;
    itemData.GetUsedSlotsOnItem(used);
    itemData.GetEmptySlotsOnItem(empty);
    let preemSlots = 0;
    for slot in slots {
      if ArrayContains(used, slot) || ArrayContains(empty, slot) {
        preemSlots += 1;
      }
    }
    FTLog(s"[PreemDev] dump: item has \(ArraySize(used)) used and \(ArraySize(empty)) empty slots, \(preemSlots) of \(ArraySize(slots)) Preem slots");
  }
  let ts = GameInstance.GetTransactionSystem(gi);
  let mapper = new PreemModMapper();
  for mod in PreemDebug.OfferedMods() {
    let count = ts.GetItemQuantity(player, ItemID.CreateQuery(ItemID.GetTDBID(mapper.GetGameModFromPreemMod(mod))));
    if count > 0 {
      FTLog(s"[PreemDev] dump: inventory has \(count) x \(PreemDebug.StyleName(mod.modStyleType))");
    }
  }
}

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemShowSettings(gi: GameInstance) -> Void {
  let settings = PreemSettings.GetInstance(gi);
  if !IsDefined(settings) {
    FTLog("[PreemDev] settings: PreemSettings system not found");
    return;
  }
  FTLog(s"[PreemDev] settings: unlock \(EnumInt(settings.GetUnlockMode())), limit \(EnumInt(settings.GetLimitMode())), layout \(EnumInt(settings.GetSlotLayout())) (0 = Sandbox / On Weapon, 1 = Weapon Blueprints / Below Weapon)");
}

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemSetSettings(gi: GameInstance, unlock: Int32, limit: Int32, layout: Int32) -> Void {
  let settings = PreemSettings.GetInstance(gi);
  settings.SetUnlockMode(IntEnum<PreemWeaponsmithProgressionModUnlockStyle>(unlock));
  settings.SetLimitMode(IntEnum<PreemWeaponsmithProgressionModAmountStyle>(limit));
  settings.SetSlotLayout(IntEnum<PreemWeaponsmithModSlotPosition>(layout));
  FTLog(s"[PreemDev] settings: set to unlock \(unlock), limit \(limit), layout \(layout)");
}

// Checks the last test weapon against expected values and logs "[PreemCheck] FAIL e2e ..." per
// mismatch (the boot check counts those as failures) or one "[PreemDev] e2e: PASS" line.
// Empty strings skip a field. mods: "PreemBarrelMod01=Barrel_Smart, PreemTriggerMod01=..." must
// match the installed Preem mods exactly. trigger is checked on the equipped weapon object;
// "record" means the weapon record's own primary trigger mode.
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemExpectTest(gi: GameInstance, label: String, record: String, evolution: String, trigger: String, mods: String) -> Void {
  let player = GetPlayer(gi);
  let itemID = PreemDebug.System(gi).lastTestItem;
  if !IsDefined(player) || !ItemID.IsValid(itemID) {
    FTLog("[PreemCheck] FAIL e2e " + label + ": no player or no test weapon");
    return;
  }
  let problems: array<String>;
  let id = ItemID.GetTDBID(itemID);
  if StrLen(record) > 0 && id != TDBID.Create(record) {
    ArrayPush(problems, "record is " + TDBID.ToStringDEBUG(id) + ", expected " + record);
  }
  let weaponRecord = TweakDBInterface.GetWeaponItemRecord(id);
  let actualEvolution = IsDefined(weaponRecord) && IsDefined(weaponRecord.Evolution()) ? weaponRecord.Evolution().Type() : gamedataWeaponEvolution.Invalid;
  if StrLen(evolution) > 0 && NotEquals(PreemDebug.EvolutionName(actualEvolution), evolution) {
    ArrayPush(problems, "evolution is " + PreemDebug.EvolutionName(actualEvolution) + ", expected " + evolution);
  }
  if StrLen(trigger) > 0 {
    let active = GameObject.GetActiveWeapon(player);
    if !IsDefined(active) || active.GetItemID() != itemID {
      ArrayPush(problems, "not the active weapon, can't check trigger " + trigger);
    } else {
      let current = PreemDebug.TriggerName(active.GetCurrentTriggerMode().Type());
      // "record": the weapon record's own primary trigger mode (a weapon without trigger mods).
      if Equals(trigger, "record") && IsDefined(weaponRecord) && IsDefined(weaponRecord.PrimaryTriggerMode()) {
        trigger = PreemDebug.TriggerName(weaponRecord.PrimaryTriggerMode().Type());
      }
      if NotEquals(current, trigger) {
        ArrayPush(problems, "current trigger is " + current + ", expected " + trigger);
      }
    }
  }
  if StrLen(mods) > 0 {
    let itemData = GameInstance.GetTransactionSystem(gi).GetItemData(player, itemID);
    let expected = StrSplit(StrReplaceAll(mods, " ", ""), ",");
    let installed: array<String>;
    for slot in PreemDebug.PreemSlots() {
      if itemData.HasPartInSlot(slot) {
        let part: InnerItemData;
        itemData.GetItemPart(part, slot);
        ArrayPush(installed, StrAfterFirst(TDBID.ToStringDEBUG(slot), ".") + "=" + PreemDebug.ModNameOf(ItemID.GetTDBID(InnerItemData.GetItemID(part))));
      }
    }
    for want in expected {
      if !ArrayContains(installed, want) {
        ArrayPush(problems, "missing mod " + want);
      }
    }
    for have in installed {
      if !ArrayContains(expected, have) {
        ArrayPush(problems, "unexpected mod " + have);
      }
    }
  }
  if ArraySize(problems) == 0 {
    FTLog("[PreemDev] e2e: PASS " + label);
  }
  for problem in problems {
    FTLog("[PreemCheck] FAIL e2e " + label + ": " + problem);
  }
}

// Checks how many items of a record the player's inventory holds (installed parts don't count),
// e.g. a muzzle brake given back or a twin that must never stay there. Counted by record over the
// item list: part items each have their own seed, so ItemID.FromTDBID(record) finds none of them.
// Logs an e2e PASS or FAIL.
public static exec func PreemExpectStock(gi: GameInstance, label: String, record: String, expected: Int32) -> Void {
  let player = GetPlayer(gi);
  if !IsDefined(player) {
    FTLog("[PreemCheck] FAIL e2e " + label + ": no player");
    return;
  }
  let items: array<wref<gameItemData>>;
  GameInstance.GetTransactionSystem(gi).GetItemList(player, items);
  let count = 0;
  for item in items {
    if ItemID.GetTDBID(item.GetID()) == TDBID.Create(record) {
      count += item.GetQuantity();
    }
  }
  if count == expected {
    FTLog("[PreemDev] e2e: PASS " + label);
  } else {
    FTLog(s"[PreemCheck] FAIL e2e \(label): \(count) of \(record) in the inventory, expected \(expected)");
  }
}

// Checks whether the vanilla screens list the muzzle slot of the last test weapon, through the
// three builders they use: the mod screen's UIInventoryItemModsManager (its slot lists), the
// InventoryDataManagerV2 attachment list (slot IDs) and the tooltip builder (one entry more with
// the muzzle slot passed in than without it; only a slot holding a part is listed there). Logs an
// e2e PASS when all three match expectShown.
public static exec func PreemMuzzleSlotUiTest(gi: GameInstance, label: String, expectShown: Bool) -> Void {
  let player = GetPlayer(gi);
  let itemID = PreemDebug.System(gi).lastTestItem;
  let ts = GameInstance.GetTransactionSystem(gi);
  let itemData = ts.GetItemData(player, itemID);
  if !IsDefined(player) || !IsDefined(itemData) {
    FTLog("[PreemCheck] FAIL e2e " + label + ": no player or no test weapon");
    return;
  }
  let muzzle = t"AttachmentSlots.PowerModule";
  // Hold the item: GetModsManager returns a weak reference into it.
  let uiItem = UIInventoryItem.Make(player, itemData);
  let mods: ref<UIInventoryItemModsManager> = uiItem.GetModsManager();
  let modScreen = false;
  let i = 0;
  while i < mods.GetUsedSlotsSize() {
    if mods.GetUsedSlot(i) == muzzle { modScreen = true; }
    i += 1;
  }
  i = 0;
  while i < mods.GetEmptySlotsSize() {
    if mods.GetEmptySlot(i) == muzzle { modScreen = true; }
    i += 1;
  }
  let manager = new InventoryDataManagerV2();
  manager.Initialize(player);
  let attachments: array<ref<InventoryItemAttachments>>;
  let abilities: array<InventoryItemAbility>;
  manager.GetAttachements(player, itemID, itemData, attachments, abilities);
  let list = false;
  for attachment in attachments {
    if attachment.SlotID == muzzle { list = true; }
  }
  let used: array<TweakDBID>;
  let empty: array<TweakDBID>;
  ts.GetUsedSlotsOnItem(player, itemID, used);
  ts.GetEmptySlotsOnItem(player, itemID, empty);
  let withMuzzle: array<ref<MinimalItemTooltipModData>>;
  let withMuzzleDedicated: array<ref<MinimalItemTooltipModAttachmentData>>;
  manager.GetAttachements(player, itemData, used, empty, withMuzzle, withMuzzleDedicated);
  ArrayRemove(used, muzzle);
  ArrayRemove(empty, muzzle);
  let without: array<ref<MinimalItemTooltipModData>>;
  let withoutDedicated: array<ref<MinimalItemTooltipModAttachmentData>>;
  manager.GetAttachements(player, itemData, used, empty, without, withoutDedicated);
  // The tooltip lists only slots that hold a part: an empty muzzle slot counts as not shown.
  let tooltip = ArraySize(withMuzzle) > ArraySize(without);
  let muzzleUsed = itemData.HasPartInSlot(muzzle);
  let detail = s"mod screen \(modScreen), attachment list \(list), tooltip \(tooltip) (\(ArraySize(withMuzzle)) vs \(ArraySize(without)) entries)";
  if Equals(modScreen, expectShown) && Equals(list, expectShown) && Equals(tooltip, expectShown && muzzleUsed) {
    FTLog("[PreemDev] e2e: PASS " + label + ": " + detail);
  } else {
    FTLog(s"[PreemCheck] FAIL e2e \(label): expected shown \(expectShown), got \(detail)");
  }
}

// Runs the stray muzzle-part sweep the crafting screen runs when it opens (PreemMuzzleParts).
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemTakeBackStrayTest(gi: GameInstance) -> Void {
  PreemMuzzleParts.TakeBackStray(GetPlayer(gi));
  FTLog("[PreemDev] stray muzzle parts taken back");
}

// Applies a mod set to the last test weapon, which the player already owns (the upgrade screen's
// case), through PreemCraftingSystem.ApplyMods: mods already in place stay, others are installed,
// Preem mods not in the set come off. "" clears every Preem mod.
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemApplyTest(gi: GameInstance, mods: String) -> Void {
  let player = GetPlayer(gi);
  let itemID = PreemDebug.System(gi).lastTestItem;
  if !IsDefined(player) || !ItemID.IsValid(itemID) {
    FTLog("[PreemDev] apply-test: no player or no test weapon; run PreemCraftTest first");
    return;
  }
  let modList: array<ref<PreemMod>>;
  if StrLen(StrReplaceAll(mods, " ", "")) > 0 {
    for name in StrSplit(mods, ",") {
      let mod = PreemDebug.ModByName(StrReplaceAll(name, " ", ""));
      if !IsDefined(mod) {
        FTLog("[PreemDev] apply-test: unknown mod " + name);
        return;
      }
      ArrayPush(modList, mod);
    }
  }
  PreemDebug.System(gi).modStockBeforeApply = PreemDebug.ModStock(gi);
  let preem = PreemCraftingSystem.GetInstance(gi);
  preem.SetModList(modList);
  preem.ApplyMods(gi, GameInstance.GetTransactionSystem(gi).GetItemData(player, itemID));
  preem.ClearMods();
  FTLog(s"[PreemDev] apply-test: applying \(ArraySize(modList)) mods to the owned test weapon");
}

// Checks PreemCraftingSystem.GetInstalledMods (the read-back seam) on the last test weapon:
// expected is "PreemBarrelMod01=Barrel_Smart, ..." in slot order, "" for none. It also checks
// that the inventory holds as many Preem mod items as before the last PreemCraftTest or
// PreemApplyTest (installed mods are used up; a removed or replaced mod is deleted). Logs "[PreemDev] e2e: PASS <label>" or "[PreemCheck] FAIL e2e" lines.
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemReadBackTest(gi: GameInstance, label: String, expected: String) -> Void {
  let player = GetPlayer(gi);
  let system = PreemDebug.System(gi);
  if !IsDefined(player) || !ItemID.IsValid(system.lastTestItem) {
    FTLog("[PreemCheck] FAIL e2e " + label + ": no player or no test weapon");
    return;
  }
  let actual = "";
  for placement in PreemCraftingSystem.GetInstalledMods(GameInstance.GetTransactionSystem(gi).GetItemData(player, system.lastTestItem)) {
    if StrLen(actual) > 0 {
      actual += ", ";
    }
    actual += StrAfterFirst(TDBID.ToStringDEBUG(placement.slotID), ".") + "=" + PreemDebug.StyleName(placement.mod.modStyleType);
  }
  let problems: array<String>;
  if NotEquals(actual, expected) {
    ArrayPush(problems, "read back [" + actual + "], expected [" + expected + "]");
  }
  let stock = PreemDebug.ModStock(gi);
  if stock != system.modStockBeforeApply {
    ArrayPush(problems, s"\(stock) Preem mod items in the inventory, \(system.modStockBeforeApply) before the last craft or apply");
  }
  if ArraySize(problems) == 0 {
    FTLog("[PreemDev] e2e: PASS " + label);
  }
  for problem in problems {
    FTLog("[PreemCheck] FAIL e2e " + label + ": " + problem);
  }
}

// Opens the crafting screen, as the hub menu's Crafting entry does.
public static exec func PreemOpenCrafting(gi: GameInstance) -> Void {
  let evt = new StartHubMenuEvent();
  evt.SetStartMenu(n"crafting_main");
  GameInstance.GetUISystem(gi).QueueEvent(evt);
  FTLog("[PreemDev] open-crafting: requested");
}

@if(!ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemExpectTest(gi: GameInstance, label: String, record: String, evolution: String, trigger: String, mods: String) -> Void {
  FTLog("[PreemDev] e2e: the mod is not installed");
}

@if(!ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemCraftTest(gi: GameInstance, record: String, mods: String) -> Void {
  FTLog("[PreemDev] craft-test: the mod is not installed");
}

@if(!ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemEquipTest(gi: GameInstance) -> Void {
  FTLog("[PreemDev] equip-test: the mod is not installed");
}

@if(!ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public static exec func PreemDump(gi: GameInstance) -> Void {
  FTLog("[PreemDev] dump: the mod is not installed");
}

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public abstract class PreemDebug {
  public static func System(gi: GameInstance) -> ref<PreemDevSystem> {
    return GameInstance.GetScriptableSystemsContainer(gi).Get(n"PreemDev.PreemDevSystem") as PreemDevSystem;
  }

  // Every slot a Preem mod can sit in (PowerModule: the 2.4.x Silencer, or the hidden muzzle part).
  public static func PreemSlots() -> array<TweakDBID> {
    return [
      t"AttachmentSlots.PreemBarrelMod01", t"AttachmentSlots.PreemBarrelMod02", t"AttachmentSlots.PowerModule",
      t"AttachmentSlots.PreemTriggerMod01", t"AttachmentSlots.PreemTriggerMod02",
      t"AttachmentSlots.PreemMagazineMod01", t"AttachmentSlots.PreemMagazineMod02",
      t"AttachmentSlots.PreemBladeMod01", t"AttachmentSlots.PreemBladeMod02",
      t"AttachmentSlots.PreemHandleMod01", t"AttachmentSlots.PreemHandleMod02"
    ];
  }

  public static func OfferedMods() -> array<ref<PreemMod>> {
    let classes: array<PreemModClassType> = [PreemModClassType.Barrel, PreemModClassType.Trigger, PreemModClassType.Mag, PreemModClassType.Blade, PreemModClassType.Handle];
    let mods: array<ref<PreemMod>>;
    for classType in classes {
      for mod in PreemModMaker.GetModsFromClassType(classType) {
        ArrayPush(mods, mod);
      }
    }
    return mods;
  }

  // A mod by its PreemModStyleType name (e.g. "Barrel_Smart").
  public static func ModByName(name: String) -> ref<PreemMod> {
    for mod in PreemDebug.OfferedMods() {
      if Equals(PreemDebug.StyleName(mod.modStyleType), name) {
        return mod;
      }
    }
    return null;
  }

  // A core style's enum name, or an add-on mod's ID (its style is a runtime value with no name).
  public static func StyleName(style: PreemModStyleType) -> String {
    let id = PreemAddons.IdOf(style);
    if NotEquals(id, n"None") {
      return NameToString(id);
    }
    return EnumValueToString("PreemCrafting.Core.PreemModStyleType", Cast<Int64>(EnumInt(style)));
  }

  // The style name of the mod whose game item this is (cloned records have no debug name).
  // How many Preem mod items (of every offered mod) the player has in the inventory.
  public static func ModStock(gi: GameInstance) -> Int32 {
    let player = GetPlayer(gi);
    let ts = GameInstance.GetTransactionSystem(gi);
    let mapper = new PreemModMapper();
    let total = 0;
    for mod in PreemDebug.OfferedMods() {
      total += ts.GetItemQuantity(player, ItemID.CreateQuery(ItemID.GetTDBID(mapper.GetGameModFromPreemMod(mod))));
    }
    return total;
  }

  public static func ModNameOf(item: TweakDBID) -> String {
    let mapper = new PreemModMapper();
    for mod in PreemDebug.OfferedMods() {
      if ItemID.GetTDBID(mapper.GetGameModFromPreemMod(mod)) == item {
        return PreemDebug.StyleName(mod.modStyleType);
      }
    }
    return TDBID.ToStringDEBUG(item);
  }

  public static func Describe(crafted: TweakDBID, base: TweakDBID) -> String {
    if crafted == base {
      return "itself";
    }
    let evolutions: array<gamedataWeaponEvolution> = [gamedataWeaponEvolution.Smart, gamedataWeaponEvolution.Tech, gamedataWeaponEvolution.Power];
    let suffixes: array<TweakDBID> = [t"_PreemSmart", t"_PreemTech", t"_PreemPower"];
    let i = 0;
    while i < 3 {
      if crafted == base + suffixes[i] {
        return TDBID.ToStringDEBUG(base) + "_Preem" + PreemDebug.EvolutionName(evolutions[i]);
      }
      i += 1;
    }
    return TDBID.ToStringDEBUG(crafted);
  }

  public static func EvolutionName(evolution: gamedataWeaponEvolution) -> String {
    return EnumValueToString("gamedataWeaponEvolution", Cast<Int64>(EnumInt(evolution)));
  }

  public static func TriggerName(mode: gamedataTriggerMode) -> String {
    return EnumValueToString("gamedataTriggerMode", Cast<Int64>(EnumInt(mode)));
  }
}

// Turns the dev test add-on (PreemTestAddon.reds: PreemDev.TestBarrel and PreemDev.TestBarrelPlus) on
// or off for this game session. Off by default and after every game start.
public static exec func PreemTestAddonOn(gi: GameInstance, on: Bool) -> Void {
  PreemTestAddonSwitch.SetOn(on);
  FTLog(s"[PreemDev] test add-on on: \(PreemTestAddonSwitch.IsOn())");
}
