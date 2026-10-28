// Dev only, never shipped. Live stat reads for the CET console or a -LoadSave run:
//   Game.PreemStatDump("SmartGunHitProbability, SmartGunPlayerProjectileVelocity")
// Waits until a weapon is in hand with its stats ready, then prints one line per stat:
//   [PreemDev] stat <Name> on <record>: item <v>, weapon <v>, player <v>
// item = the item's own stats (gameItemData), weapon = the weapon object in hand (its StatsSystem
// entry), player = the player's value (e.g. HasSmartLink). Names are gamedataStatType names.
// Which weapon: the last test weapon after PreemEquipTest, otherwise whatever is in hand.
// "Ready" means in hand and its DPS reads above 0 on two polls in a row: right after a save loads
// the hand is empty, then every stat reads 0 for about 25 s (HANDOFF §5). Polls every second
// for up to 120 s, then logs a timeout. Like PreemPing, no `module` line (exec function).

import PreemDev.*

public static exec func PreemStatDump(gi: GameInstance, names: String) -> Void {
  let stats: array<gamedataStatType>;
  let labels: array<String>;
  for raw in StrSplit(names, ",") {
    let name = StrReplaceAll(raw, " ", "");
    if StrLen(name) > 0 {
      let value = EnumValueFromString("gamedataStatType", name);
      if value < 0l {
        FTLog("[PreemDev] stat-dump: unknown stat " + name + "; use gamedataStatType names, e.g. DPS");
        return;
      }
      ArrayPush(stats, IntEnum<gamedataStatType>(Cast<Int32>(value)));
      ArrayPush(labels, name);
    }
  }
  if ArraySize(stats) == 0 {
    FTLog("[PreemDev] stat-dump: no stat names given");
    return;
  }
  let poll = new PreemStatDumpPoll();
  poll.gi = gi;
  poll.stats = stats;
  poll.labels = labels;
  FTLog(s"[PreemDev] stat-dump: waiting for the weapon in hand (\(ArraySize(stats)) stats)");
  poll.Schedule();
}

public class PreemStatDumpPoll extends DelayCallback {
  public let gi: GameInstance;
  public let stats: array<gamedataStatType>;
  public let labels: array<String>;
  private let m_polls: Int32;
  private let m_readyPolls: Int32;

  public func Schedule() -> Void {
    GameInstance.GetDelaySystem(this.gi).DelayCallback(this, 1.0, false);
  }

  public func Call() -> Void {
    this.m_polls += 1;
    let weapon = this.WeaponInHand();
    if IsDefined(weapon) && weapon.GetItemData().GetStatValueByType(gamedataStatType.DPS) > 0.0 {
      this.m_readyPolls += 1;
    } else {
      this.m_readyPolls = 0;
    }
    if this.m_readyPolls >= 2 {
      this.Print(weapon);
    } else {
      if this.m_polls >= 120 {
        FTLog("[PreemDev] stat-dump: timed out after 120 s: " + (IsDefined(weapon) ? "the weapon's stats still read 0" : "no weapon in hand (or not the test weapon)"));
      } else {
        this.Schedule();
      }
    }
  }

  private func WeaponInHand() -> ref<WeaponObject> {
    let player = GetPlayer(this.gi);
    if !IsDefined(player) {
      return null;
    }
    let weapon = GameObject.GetActiveWeapon(player);
    if !IsDefined(weapon) {
      return null;
    }
    let system = GameInstance.GetScriptableSystemsContainer(this.gi).Get(n"PreemDev.PreemDevSystem") as PreemDevSystem;
    if IsDefined(system) && system.testItemEquipRequested && weapon.GetItemID() != system.lastTestItem {
      return null;
    }
    return weapon;
  }

  private func Print(weapon: ref<WeaponObject>) -> Void {
    let statsSystem = GameInstance.GetStatsSystem(this.gi);
    let player = GetPlayer(this.gi);
    let record = TDBID.ToStringDEBUG(ItemID.GetTDBID(weapon.GetItemID()));
    let itemData = weapon.GetItemData();
    let i = 0;
    while i < ArraySize(this.stats) {
      let stat = this.stats[i];
      let onItem = itemData.GetStatValueByType(stat);
      let onWeapon = statsSystem.GetStatValue(Cast<StatsObjectID>(weapon.GetEntityID()), stat);
      let onPlayer = statsSystem.GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), stat);
      FTLog(s"[PreemDev] stat \(this.labels[i]) on \(record): item \(onItem), weapon \(onWeapon), player \(onPlayer)");
      i += 1;
    }
    FTLog(s"[PreemDev] stat-dump: done after \(this.m_polls) s");
  }
}
