// PreemWeaponAlteration.EvolutionStatModifiers: the stat modifiers an evolution variant gets on top
// of its original groups, so only DPS and headshot damage follow the new evolution (decisions log
// 2026-10-27). Worked out by hand from the vanilla 2.5 records: the class group
// Items.Base_<Evolution>_<Class>_Mult_Stats holds the DPS penalty (Smart x0.8, Tech x0.9) and the
// Smart handgun (-0.15) and sniper (-1.0) headshot penalties; Items.Base_Smart_Stats holds Smart's
// -0.5 headshot, which the Smart barrel brings to a new Smart variant. Fixture lists are short
// versions of real weapons' groups (Lexington, Chao, Nekomata, Overture, Defender, an NPC HMG).
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public class PreemVariantStatTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "VariantStats";
  }

  private func ExpectIds(label: String, actual: array<TweakDBID>, expected: array<TweakDBID>) {
    this.ExpectInt32(label + ": count", ArraySize(actual), ArraySize(expected));
    let i = 0;
    while i < ArraySize(expected) && i < ArraySize(actual) {
      this.ExpectTweakDBID(label + ": " + IntToString(i), actual[i], expected[i]);
      i += 1;
    }
  }

  private func Mods(groups: array<TweakDBID>, from: gamedataWeaponEvolution, to: gamedataWeaponEvolution) -> array<TweakDBID> {
    return PreemWeaponAlteration.EvolutionStatModifiers(groups, from, to);
  }

  private cb func Test_PowerHandgunToSmart() {
    let groups: array<TweakDBID> = [t"Items.Base_Handgun_RPG_Stats", t"Items.Base_Power_Stats", t"Items.Base_Power_Handgun_Mult_Stats"];
    this.ExpectIds("Lexington to Smart", this.Mods(groups, gamedataWeaponEvolution.Power, gamedataWeaponEvolution.Smart),
      [t"AttackModifier.SmartWeaponDPSReduction", t"Items.Base_Smart_Handgun_Mult_Stats_inline1"]);
  }

  private cb func Test_SmartHandgunToPower() {
    let groups: array<TweakDBID> = [t"Items.Base_Smart_Stats", t"Items.Base_Smart_Handgun_Mult_Stats", t"Items.Base_Chao_Damage_Stats"];
    this.ExpectIds("Chao to Power", this.Mods(groups, gamedataWeaponEvolution.Smart, gamedataWeaponEvolution.Power),
      [t"PreemWeaponsmith.UndoSmartDPSReduction", t"PreemWeaponsmith.UndoSmartHeadshotPenalty", t"PreemWeaponsmith.UndoSmartHandgunHeadshotPenalty"]);
  }

  private cb func Test_SmartHandgunToTech() {
    let groups: array<TweakDBID> = [t"Items.Base_Smart_Stats", t"Items.Base_Smart_Handgun_Mult_Stats"];
    this.ExpectIds("Chao to Tech", this.Mods(groups, gamedataWeaponEvolution.Smart, gamedataWeaponEvolution.Tech),
      [t"PreemWeaponsmith.UndoSmartDPSReduction", t"AttackModifier.TechWeaponDPSReduction", t"PreemWeaponsmith.UndoSmartHeadshotPenalty", t"PreemWeaponsmith.UndoSmartHandgunHeadshotPenalty"]);
  }

  private cb func Test_SmartShotgunToPower() {
    let groups: array<TweakDBID> = [t"Items.Base_Smart_Stats", t"Items.Base_Smart_Shotgun_Mult_Stats"];
    this.ExpectIds("Smart shotgun to Power", this.Mods(groups, gamedataWeaponEvolution.Smart, gamedataWeaponEvolution.Power),
      [t"PreemWeaponsmith.UndoSmartDPSReduction", t"PreemWeaponsmith.UndoSmartHeadshotPenalty"]);
  }

  private cb func Test_TechSniperToSmart() {
    let groups: array<TweakDBID> = [t"Items.Base_Tech_Sniper_Stats", t"Items.Base_Tech_Sniper_Rifle_Mult_Stats"];
    this.ExpectIds("Nekomata to Smart", this.Mods(groups, gamedataWeaponEvolution.Tech, gamedataWeaponEvolution.Smart),
      [t"PreemWeaponsmith.UndoTechDPSReduction", t"AttackModifier.SmartWeaponDPSReduction", t"Items.Base_Smart_Sniper_Rifle_Mult_Stats_inline1"]);
  }

  private cb func Test_TechSniperToPower() {
    let groups: array<TweakDBID> = [t"Items.Base_Tech_Sniper_Stats", t"Items.Base_Tech_Sniper_Rifle_Mult_Stats"];
    this.ExpectIds("Nekomata to Power", this.Mods(groups, gamedataWeaponEvolution.Tech, gamedataWeaponEvolution.Power),
      [t"PreemWeaponsmith.UndoTechDPSReduction"]);
  }

  // No vanilla Smart revolver or Smart/Tech LMG: revolvers take the Smart handgun headshot penalty.
  private cb func Test_PowerRevolverToSmartAndTech() {
    let groups: array<TweakDBID> = [t"Items.Base_Power_Stats", t"Items.Base_Power_Revolver_Mult_Stats"];
    this.ExpectIds("Overture to Smart", this.Mods(groups, gamedataWeaponEvolution.Power, gamedataWeaponEvolution.Smart),
      [t"AttackModifier.SmartWeaponDPSReduction", t"Items.Base_Smart_Handgun_Mult_Stats_inline1"]);
    this.ExpectIds("Overture to Tech", this.Mods(groups, gamedataWeaponEvolution.Power, gamedataWeaponEvolution.Tech),
      [t"AttackModifier.TechWeaponDPSReduction"]);
  }

  private cb func Test_PowerLmgToSmartAndTech() {
    let groups: array<TweakDBID> = [t"Items.Base_Power_Lightmachinegun_Mult_Stats", t"Items.Base_Power_Stats"];
    this.ExpectIds("Defender to Smart", this.Mods(groups, gamedataWeaponEvolution.Power, gamedataWeaponEvolution.Smart),
      [t"AttackModifier.SmartWeaponDPSReduction"]);
    this.ExpectIds("Defender to Tech", this.Mods(groups, gamedataWeaponEvolution.Power, gamedataWeaponEvolution.Tech),
      [t"AttackModifier.TechWeaponDPSReduction"]);
  }

  private cb func Test_NoClassGroupGetsNothing() {
    let groups: array<TweakDBID> = [t"Items.Base_HMG_Damage_Stats", t"Items.Base_Power_Stats"];
    let none: array<TweakDBID>;
    this.ExpectIds("NPC HMG to Smart", this.Mods(groups, gamedataWeaponEvolution.Power, gamedataWeaponEvolution.Smart), none);
  }

  // The undo records cancel vanilla's penalties exactly.
  private cb func Test_UndoRecordsCancelVanilla() {
    this.ExpectBool("Smart DPS undo x penalty = 1", this.IsOne(this.Value(t"PreemWeaponsmith.UndoSmartDPSReduction") * this.Value(t"AttackModifier.SmartWeaponDPSReduction")), true);
    this.ExpectBool("Tech DPS undo x penalty = 1", this.IsOne(this.Value(t"PreemWeaponsmith.UndoTechDPSReduction") * this.Value(t"AttackModifier.TechWeaponDPSReduction")), true);
    this.ExpectFloat("Smart headshot undo", this.Value(t"PreemWeaponsmith.UndoSmartHeadshotPenalty"), -this.Value(t"Items.Base_Smart_Stats_inline1"));
    this.ExpectFloat("Smart handgun headshot undo", this.Value(t"PreemWeaponsmith.UndoSmartHandgunHeadshotPenalty"), -this.Value(t"Items.Base_Smart_Handgun_Mult_Stats_inline1"));
    this.ExpectFloat("Smart sniper headshot undo", this.Value(t"PreemWeaponsmith.UndoSmartSniperHeadshotPenalty"), -this.Value(t"Items.Base_Smart_Sniper_Rifle_Mult_Stats_inline1"));
  }

  // A real variant keeps its original groups and gets the modifiers appended.
  private cb func Test_VariantKeepsGroupsAndGetsModifiers() {
    let base = t"Items.Preset_Lexington_Default";
    let variant = t"Items.Preset_Lexington_Default_PreemSmart";
    this.ExpectIds("Lexington Smart variant groups", this.Ids(variant + t".statModifierGroups"), this.Ids(base + t".statModifierGroups"));
    let mods = this.Ids(base + t".statModifiers");
    ArrayPush(mods, t"AttackModifier.SmartWeaponDPSReduction");
    ArrayPush(mods, t"Items.Base_Smart_Handgun_Mult_Stats_inline1");
    this.ExpectIds("Lexington Smart variant modifiers", this.Ids(variant + t".statModifiers"), mods);
  }

  private func Ids(flatId: TweakDBID) -> array<TweakDBID> {
    let flat = TweakDBInterface.GetFlat(flatId);
    let ids: array<TweakDBID>;
    if Equals(VariantTypeName(flat), n"array:TweakDBID") {
      ids = FromVariant(flat);
    }
    return ids;
  }

  private func Value(modifier: TweakDBID) -> Float {
    return TweakDBInterface.GetFloat(modifier + t".value", 0.0);
  }

  private func IsOne(x: Float) -> Bool {
    return AbsF(x - 1.0) < 0.0001;
  }
}
