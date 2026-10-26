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
  for name in StrSplit(mods, ",") {
    let mod = PreemDebug.ModByName(StrReplaceAll(name, " ", ""));
    if !IsDefined(mod) {
      FTLog("[PreemDev] craft-test: unknown mod " + name + "; use PreemModStyleType names, e.g. Barrel_Smart");
      return;
    }
    ArrayPush(modList, mod);
    ArrayPush(styles, mod.modStyleType);
  }
  let weapon = base as WeaponItem_Record;
  let evolution = IsDefined(weapon) && IsDefined(weapon.Evolution()) ? weapon.Evolution().Type() : gamedataWeaponEvolution.Invalid;
  if !PreemCraftingSystem.AreModsCompatible(modList, evolution) {
    FTLog("[PreemDev] craft-test: warning: the crafting screen would refuse this mod set (required or incompatible mods)");
  }

  let craftRecord = PreemCraftingSystem.GetCraftRecord(base, styles);
  let itemID = ItemID.FromTDBID(craftRecord.GetID());
  let ts = GameInstance.GetTransactionSystem(gi);
  ts.GiveItem(player, itemID, 1);
  let itemData = ts.GetItemData(player, itemID);
  if !IsDefined(itemData) {
    FTLog("[PreemDev] craft-test: GiveItem gave no item data for " + record);
    return;
  }
  let preem = PreemCraftingSystem.GetInstance(gi);
  preem.SetModList(modList);
  preem.ApplyMods(gi, itemData);
  preem.ClearMods();
  PreemDebug.System(gi).lastTestItem = itemID;
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
  let slots: array<TweakDBID> = [
    t"AttachmentSlots.PreemBarrelMod01", t"AttachmentSlots.PreemBarrelMod02", t"AttachmentSlots.PowerModule",
    t"AttachmentSlots.PreemTriggerMod01", t"AttachmentSlots.PreemTriggerMod02",
    t"AttachmentSlots.PreemMagazineMod01", t"AttachmentSlots.PreemMagazineMod02",
    t"AttachmentSlots.PreemBladeMod01", t"AttachmentSlots.PreemBladeMod02",
    t"AttachmentSlots.PreemHandleMod01", t"AttachmentSlots.PreemHandleMod02"
  ];
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

  public static func StyleName(style: PreemModStyleType) -> String {
    return EnumValueToString("PreemCrafting.Core.PreemModStyleType", Cast<Int64>(EnumInt(style)));
  }

  // The style name of the mod whose game item this is (cloned records have no debug name).
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
