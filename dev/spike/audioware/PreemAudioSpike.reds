// Dev only, never shipped or installed by dev-install.ps1. Phase 3 spike (notes/audioware-sounds.md):
// do a weapon's own fire events, posted natively by its weapon audio, reach Audioware's
// AudioEventCallbackSystem? Copy this folder to <game>\r6\scripts\PreemSpike for one run, drive it
// with dev/spike/audioware/spike.lua, then delete the folder again.
//   Game.PreemSpikeSetup()   arms the callbacks, gives a Lexington and equips it
//   Game.PreemSpikeDraw()    draws it
//   Game.PreemSpikeControl() posts two Lexington events from script (control: must be seen)
//   Game.PreemSpikeFire(auto) one shot through AIWeapon.Fire, the game's own shot path
//   Game.PreemSpikeSummary() counts per event name
// Output: FTLog lines starting [PreemSpike] (CET gamelog.log, written when the game exits).

import Audioware.*

public class PreemAudioSpikeSystem extends ScriptableSystem {
  let handlers: array<ref<AudioEventCallbackHandler>>;
  let names: array<CName>;
  let counts: array<Int32>;
  let itemID: ItemID;

  public final func Arm() -> Void {
    if ArraySize(this.handlers) > 0 { return; }
    this.names = [
      n"w_gun_pistol_power_lexington_fire_single",
      n"w_gun_pistol_power_lexington_fire_auto",
      n"w_gun_pistol_power_lexington_fire_auto_stop",
      n"w_gun_pistol_power_lexington_trigger",
      n"w_gun_pistol_power_lexington_equip",
      n"w_gun_pistol_power_lexington_equip_first",
      n"w_gun_pistol_power_lexington_grab",
      n"w_gun_pistol_power_lexington_aim_enter",
      n"w_gun_pistol_power_lexington_mag_tap",
      n"w_gun_pistol_power_lexington_mag_out",
      n"wea_shell_small_shoot",
      n"w_gun_example_equip"
    ];
    let system = GameInstance.GetAudioEventCallbackSystem();
    for name in this.names {
      ArrayPush(this.handlers, system.RegisterCallback(name, this, n"OnAudio"));
      ArrayPush(this.counts, 0);
    }
    FTLog(s"[PreemSpike] armed \(ArraySize(this.handlers)) callbacks, Audioware \(GameInstance.GetAudioSystemExt(this.GetGameInstance()).Version())");
  }

  private cb func OnAudio(event: ref<SoundEvent>) {
    let name = event.PrimaryName();
    let i = ArrayFindFirst(this.names, name);
    if i >= 0 { this.counts[i] += 1; }
    let entity: EntityID;
    let play = event as PlayEvent;
    let oneShot = event as PlayOneShotEvent;
    let stop = event as StopSoundEvent;
    if IsDefined(play) { entity = play.EntityID(); }
    if IsDefined(oneShot) { entity = oneShot.EntityID(); }
    if IsDefined(stop) { entity = stop.EntityID(); }
    FTLog(s"[PreemSpike] event \(NameToString(name)) \(NameToString(event.GetClassName())) on \(this.Owner(entity))");
  }

  private final func Owner(entity: EntityID) -> String {
    let player = GetPlayer(this.GetGameInstance());
    if !EntityID.IsDefined(entity) { return "no entity"; }
    if IsDefined(player) && entity == player.GetEntityID() { return "player"; }
    let weapon = GameObject.GetActiveWeapon(player);
    if IsDefined(weapon) && entity == weapon.GetEntityID() { return "player's weapon"; }
    return "entity " + EntityID.ToDebugString(entity);
  }

  public final func Summary() -> Void {
    let i = 0;
    while i < ArraySize(this.names) {
      FTLog(s"[PreemSpike] count \(NameToString(this.names[i])) = \(this.counts[i])");
      i += 1;
    }
  }
}

public static func PreemSpike(gi: GameInstance) -> ref<PreemAudioSpikeSystem> {
  return GameInstance.GetScriptableSystemsContainer(gi).Get(n"PreemAudioSpikeSystem") as PreemAudioSpikeSystem;
}

public static exec func PreemSpikeSetup(gi: GameInstance) -> Void {
  let player = GetPlayer(gi);
  if !IsDefined(player) { FTLog("[PreemSpike] setup: no player"); return; }
  let spike = PreemSpike(gi);
  spike.Arm();
  spike.itemID = ItemID.FromTDBID(t"Items.Preset_Lexington_Default");
  GameInstance.GetTransactionSystem(gi).GiveItem(player, spike.itemID, 1);
  GameInstance.GetTransactionSystem(gi).GiveItem(player, ItemID.FromTDBID(t"Ammo.HandgunAmmo"), 200);
  let request = new EquipRequest();
  request.owner = player;
  request.itemID = spike.itemID;
  request.slotIndex = 0;
  GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem").QueueRequest(request);
  FTLog("[PreemSpike] setup: gave and equipped Items.Preset_Lexington_Default");
}

public static exec func PreemSpikeDraw(gi: GameInstance) -> Void {
  let player = GetPlayer(gi);
  let draw = new DrawItemRequest();
  draw.owner = player;
  draw.itemID = PreemSpike(gi).itemID;
  GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem").QueueRequest(draw);
  FTLog("[PreemSpike] draw requested");
}

public static exec func PreemSpikeControl(gi: GameInstance) -> Void {
  let player = GetPlayer(gi);
  GameInstance.GetAudioSystem(gi).Play(n"w_gun_pistol_power_lexington_mag_tap");
  GameObject.PlaySoundEvent(player, n"w_gun_pistol_power_lexington_mag_out");
  FTLog("[PreemSpike] control: posted mag_tap (AudioSystem.Play) and mag_out (GameObject.PlaySoundEvent)");
}

public static exec func PreemSpikeFire(gi: GameInstance, auto: Bool) -> Void {
  let player = GetPlayer(gi);
  let weapon = GameObject.GetActiveWeapon(player);
  if !IsDefined(weapon) { FTLog("[PreemSpike] fire: no active weapon"); return; }
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(gi));
  AIWeapon.Fire(player, weapon, now, 1.0, auto ? gamedataTriggerMode.FullAuto : gamedataTriggerMode.SemiAuto);
  FTLog(s"[PreemSpike] fire: AIWeapon.Fire \(TDBID.ToStringDEBUG(ItemID.GetTDBID(weapon.GetItemID()))) auto=\(auto)");
}

public static exec func PreemSpikeSummary(gi: GameInstance) -> Void {
  PreemSpike(gi).Summary();
}
