// Dev only, never shipped. Watches the sound events a weapon's own audio plays, through
// Audioware's AudioEventCallbackSystem (it sees the game's native Wwise events; Phase 3 spike,
// notes/audioware-sounds.md). Compiled only when Audioware is installed. Needs a loaded save:
//   Game.PreemSoundWatch("w_gun_pistol_power_liberty_fire_single, w_gun_pistol_power_lexington_fire_auto")
//     starts counting those event names
//   Game.PreemCraftTest(...) and Game.PreemEquipTest()   (PreemDebug.reds) give and equip a weapon
//   Game.PreemSoundDraw()    draws the PreemCraftTest weapon
//   Game.PreemSoundFire("FullAuto") one shot through AIWeapon.Fire with that requested trigger
//     mode (a gamedataTriggerMode name: SemiAuto, FullAuto, Burst, Charge), the game's own shot path
//   Game.PreemSoundSummary() prints the count per watched name
// Output: FTLog lines starting [PreemDev] sound (CET gamelog.log, written when the game exits).
// Like PreemPing, no `module` line: CET finds exec functions by bare name.
// dev/cet/sound-check.lua drives a whole run.

@if(ModuleExists("Audioware"))
import Audioware.*
import PreemDev.*

@if(ModuleExists("Audioware"))
public class PreemSoundListener extends ScriptableSystem {
  let handlers: array<ref<AudioEventCallbackHandler>>;
  let names: array<CName>;
  let counts: array<Int32>;

  public final func Watch(list: String) -> Void {
    let system = GameInstance.GetAudioEventCallbackSystem();
    for part in StrSplit(list, ",") {
      let name = StringToName(StrReplaceAll(part, " ", ""));
      if !ArrayContains(this.names, name) {
        ArrayPush(this.handlers, system.RegisterCallback(name, this, n"OnSound"));
        ArrayPush(this.names, name);
        ArrayPush(this.counts, 0);
      }
    }
    FTLog(s"[PreemDev] sound: watching \(ArraySize(this.names)) events, Audioware \(GameInstance.GetAudioSystemExt(this.GetGameInstance()).Version())");
  }

  private cb func OnSound(event: ref<SoundEvent>) {
    let play = event as PlayEvent;
    if !IsDefined(play) { return; }
    let i = ArrayFindFirst(this.names, play.EventName());
    if i >= 0 { this.counts[i] += 1; }
    FTLog(s"[PreemDev] sound: \(NameToString(play.EventName())) on \(this.Owner(play.EntityID()))");
  }

  private final func Owner(entity: EntityID) -> String {
    let player = GetPlayer(this.GetGameInstance());
    if !EntityID.IsDefined(entity) { return "no entity"; }
    if IsDefined(player) && entity == player.GetEntityID() { return "player"; }
    let weapon = GameObject.GetActiveWeapon(player);
    if IsDefined(weapon) && entity == weapon.GetEntityID() {
      return "player's weapon " + TDBID.ToStringDEBUG(ItemID.GetTDBID(weapon.GetItemID()));
    }
    return "entity " + EntityID.ToDebugString(entity);
  }

  public final func Summary() -> Void {
    let i = 0;
    while i < ArraySize(this.names) {
      FTLog(s"[PreemDev] sound: count \(NameToString(this.names[i])) = \(this.counts[i])");
      i += 1;
    }
  }
}

@if(ModuleExists("Audioware"))
public static func PreemSoundListenerOf(gi: GameInstance) -> ref<PreemSoundListener> {
  return GameInstance.GetScriptableSystemsContainer(gi).Get(n"PreemSoundListener") as PreemSoundListener;
}

@if(ModuleExists("Audioware"))
public static exec func PreemSoundWatch(gi: GameInstance, names: String) -> Void {
  PreemSoundListenerOf(gi).Watch(names);
}

@if(ModuleExists("Audioware"))
public static exec func PreemSoundDraw(gi: GameInstance) -> Void {
  let player = GetPlayer(gi);
  let dev = GameInstance.GetScriptableSystemsContainer(gi).Get(n"PreemDev.PreemDevSystem") as PreemDevSystem;
  let itemID = dev.lastTestItem;
  if !IsDefined(player) || !ItemID.IsValid(itemID) {
    FTLog("[PreemDev] sound: no test weapon; run PreemCraftTest first");
    return;
  }
  let draw = new DrawItemRequest();
  draw.owner = player;
  draw.itemID = itemID;
  GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem").QueueRequest(draw);
  FTLog("[PreemDev] sound: draw requested");
}

@if(ModuleExists("Audioware"))
public static exec func PreemSoundFire(gi: GameInstance, mode: String) -> Void {
  let player = GetPlayer(gi);
  let weapon = GameObject.GetActiveWeapon(player);
  if !IsDefined(weapon) { FTLog("[PreemDev] sound: fire: no active weapon"); return; }
  let triggerMode = IntEnum<gamedataTriggerMode>(Cast<Int32>(EnumValueFromString("gamedataTriggerMode", mode)));
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(gi));
  AIWeapon.Fire(player, weapon, now, 1.0, triggerMode);
  FTLog(s"[PreemDev] sound: fire \(TDBID.ToStringDEBUG(ItemID.GetTDBID(weapon.GetItemID()))) mode=\(mode)");
}

@if(ModuleExists("Audioware"))
public static exec func PreemSoundSummary(gi: GameInstance) -> Void {
  PreemSoundListenerOf(gi).Summary();
}
