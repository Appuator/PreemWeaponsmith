// PreemWeaponAlteration.SwapEvolutionStatGroups: the stat groups an evolution variant keeps.
// Expected lists are worked out by hand from the vanilla 2.5 groups (decisions log 2026-10-27):
// the class group Items.Base_<Evolution>_<Class>_Mult_Stats becomes the new evolution's, in place;
// Items.Base_<Evolution>_Stats (and Base_Tech_Sniper_Stats) come off; every other group stays.
// Fixture lists are short versions of real weapons' groups (Lexington, Chao, Nekomata, Overture,
// Defender, an NPC HMG).
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public class PreemVariantStatTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "VariantStats";
  }

  private func ExpectGroups(label: String, actual: array<TweakDBID>, expected: array<TweakDBID>) {
    this.ExpectInt32(label + ": group count", ArraySize(actual), ArraySize(expected));
    let i = 0;
    while i < ArraySize(expected) && i < ArraySize(actual) {
      this.ExpectTweakDBID(label + ": group " + IntToString(i), actual[i], expected[i]);
      i += 1;
    }
  }

  private cb func Test_PowerHandgunToSmart() {
    let groups: array<TweakDBID> = [t"Items.Base_Handgun_RPG_Stats", t"Items.Base_Power_Stats", t"Items.Base_Power_Handgun_Stats", t"Items.Base_Power_Handgun_Mult_Stats", t"Items.Base_Lexington_Damage_Stats"];
    this.ExpectGroups("Lexington to Smart", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Smart),
      [t"Items.Base_Handgun_RPG_Stats", t"Items.Base_Power_Handgun_Stats", t"Items.Base_Smart_Handgun_Mult_Stats", t"Items.Base_Lexington_Damage_Stats"]);
  }

  private cb func Test_SmartHandgunToPower() {
    let groups: array<TweakDBID> = [t"Items.Base_Smart_Stats", t"Items.Base_Smart_Handgun_Mult_Stats", t"Items.Base_Smart_Handgun_No_Sway_Stats", t"Items.Base_Chao_Damage_Stats"];
    this.ExpectGroups("Chao to Power", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Power),
      [t"Items.Base_Power_Handgun_Mult_Stats", t"Items.Base_Smart_Handgun_No_Sway_Stats", t"Items.Base_Chao_Damage_Stats"]);
  }

  private cb func Test_SmartHandgunToTech() {
    let groups: array<TweakDBID> = [t"Items.Base_Smart_Stats", t"Items.Base_Smart_Handgun_Mult_Stats", t"Items.Base_Chao_Damage_Stats"];
    this.ExpectGroups("Chao to Tech", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Tech),
      [t"Items.Base_Tech_Handgun_Mult_Stats", t"Items.Base_Chao_Damage_Stats"]);
  }

  private cb func Test_TechSniperToSmart() {
    let groups: array<TweakDBID> = [t"Items.Base_Tech_Sniper_Stats", t"Items.Base_Tech_Sniper_Rifle_Mult_Stats", t"Items.Base_Nekomata_Technical_Stats"];
    this.ExpectGroups("Nekomata to Smart", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Smart),
      [t"Items.Base_Smart_Sniper_Rifle_Mult_Stats", t"Items.Base_Nekomata_Technical_Stats"]);
  }

  // No vanilla Smart revolver or Smart/Tech LMG: the Preem groups stand in.
  private cb func Test_PowerRevolverToSmartUsesPreemGroup() {
    let groups: array<TweakDBID> = [t"Items.Base_Power_Stats", t"Items.Base_Power_Revolver_Mult_Stats"];
    this.ExpectGroups("Overture to Smart", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Smart),
      [t"PreemWeaponsmith.Smart_Revolver_Mult_Stats"]);
  }

  private cb func Test_PowerRevolverToTech() {
    let groups: array<TweakDBID> = [t"Items.Base_Power_Stats", t"Items.Base_Power_Revolver_Mult_Stats"];
    this.ExpectGroups("Overture to Tech", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Tech),
      [t"Items.Base_Tech_Revolver_Mult_Stats"]);
  }

  private cb func Test_PowerLmgToSmartAndTechUsePreemGroups() {
    let groups: array<TweakDBID> = [t"Items.Base_Power_Lightmachinegun_Mult_Stats", t"Items.Base_Power_Stats"];
    this.ExpectGroups("Defender to Smart", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Smart),
      [t"PreemWeaponsmith.Smart_Lightmachinegun_Mult_Stats"]);
    this.ExpectGroups("Defender to Tech", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Tech),
      [t"PreemWeaponsmith.Tech_Lightmachinegun_Mult_Stats"]);
  }

  private cb func Test_NoClassGroupKeepsTheRest() {
    let groups: array<TweakDBID> = [t"Items.Base_HMG_Damage_Stats", t"Items.Base_Power_Stats"];
    this.ExpectGroups("NPC HMG to Smart", PreemWeaponAlteration.SwapEvolutionStatGroups(groups, gamedataWeaponEvolution.Smart),
      [t"Items.Base_HMG_Damage_Stats"]);
  }

  // The Preem stand-ins exist and carry the evolution's DPS penalty.
  private cb func Test_PreemGroupsHoldTheDpsPenalty() {
    this.ExpectBool("Smart revolver group has SmartWeaponDPSReduction", this.HasModifier(t"PreemWeaponsmith.Smart_Revolver_Mult_Stats", t"AttackModifier.SmartWeaponDPSReduction"), true);
    this.ExpectBool("Smart LMG group has SmartWeaponDPSReduction", this.HasModifier(t"PreemWeaponsmith.Smart_Lightmachinegun_Mult_Stats", t"AttackModifier.SmartWeaponDPSReduction"), true);
    this.ExpectBool("Tech LMG group has TechWeaponDPSReduction", this.HasModifier(t"PreemWeaponsmith.Tech_Lightmachinegun_Mult_Stats", t"AttackModifier.TechWeaponDPSReduction"), true);
  }

  private func HasModifier(group: TweakDBID, modifier: TweakDBID) -> Bool {
    let flat = TweakDBInterface.GetFlat(group + t".statModifiers");
    if NotEquals(VariantTypeName(flat), n"array:TweakDBID") {
      return false;
    }
    let modifiers: array<TweakDBID> = FromVariant(flat);
    return ArrayContains(modifiers, modifier);
  }
}
