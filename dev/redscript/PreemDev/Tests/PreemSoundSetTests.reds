// PreemSoundSets.Patch with the mod's fill table, on hand-made sound sets. Expected events come
// from the event map (notes/audioware-sounds.md): the 2.2.5 archive gives wea_pla_liberty the
// Lexington's auto loop and stop, and the Lexington has its own in vanilla 2.5.
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.Audio.*

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public class PreemSoundSetTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "SoundSets";
  }

  private func Set(name: CName) -> ref<audioPlayerWeaponSettings> {
    let settings = new audioPlayerWeaponSettings();
    settings.name = name;
    return settings;
  }

  private func Entries(a: ref<audioAudioMetadata>, b: ref<audioAudioMetadata>) -> array<ref<audioAudioMetadata>> {
    let entries: array<ref<audioAudioMetadata>>;
    ArrayPush(entries, a);
    ArrayPush(entries, b);
    return entries;
  }

  private cb func Test_LibertyGetsLexingtonAutoLoop() {
    let liberty = this.Set(n"wea_pla_liberty");
    let lexington = this.Set(n"wea_pla_lexington");
    lexington.autoFireSound = n"w_gun_pistol_power_lexington_fire_auto";
    lexington.autoFireStop = n"w_gun_pistol_power_lexington_fire_auto_stop";
    PreemSoundSets.Patch(this.Entries(liberty, lexington), PreemSoundSets.Fills());
    this.ExpectCName("Liberty autoFireSound", liberty.autoFireSound, n"w_gun_pistol_power_lexington_fire_auto");
    this.ExpectCName("Liberty autoFireStop", liberty.autoFireStop, n"w_gun_pistol_power_lexington_fire_auto_stop");
    this.ExpectCName("Lexington autoFireSound untouched", lexington.autoFireSound, n"w_gun_pistol_power_lexington_fire_auto");
  }

  private func ExpectAuto(setName: CName, loop: CName, stop: CName) {
    let settings = this.Set(setName);
    let entries: array<ref<audioAudioMetadata>>;
    ArrayPush(entries, settings);
    PreemSoundSets.Patch(entries, PreemSoundSets.Fills());
    this.ExpectCName(NameToString(setName) + " autoFireSound", settings.autoFireSound, loop);
    this.ExpectCName(NameToString(setName) + " autoFireStop", settings.autoFireStop, stop);
  }

  // One set per borrowed source (event map); Metel is in the ep1 metadata.
  private cb func Test_AutoLoopPerSource() {
    this.ExpectAuto(n"wea_pla_unity", n"w_gun_pistol_power_lexington_fire_auto", n"w_gun_pistol_power_lexington_fire_auto_stop");
    this.ExpectAuto(n"wea_pla_metel", n"w_gun_rifle_power_ajax_fire_auto", n"w_gun_rifle_power_ajax_fire_auto_stop");
    this.ExpectAuto(n"wea_pla_burya", n"w_gun_revol_tech_quasar_fire_auto", n"w_gun_revol_tech_quasar_fire_auto_stop");
    this.ExpectAuto(n"wea_pla_carnage", n"w_gun_rifle_power_pozhar_fire_auto", n"w_gun_rifle_power_pozhar_fire_auto_stop");
    this.ExpectAuto(n"wea_pla_ashura", n"w_gun_smg_smart_sidewinder_fire_auto", n"w_gun_smg_smart_sidewinder_fire_auto_stop");
  }

  // The event map: auto loop + stop on 23 plain sound sets, plus 13 plain gap sets (Phase 3 gate).
  private cb func Test_AutoFillCount() {
    let count = 0;
    for fill in PreemSoundSets.Fills() {
      if Equals(fill.field, n"autoFireSound") || Equals(fill.field, n"autoFireStop") {
        if !StrContains(NameToString(fill.setName), "_suppressor") { count += 1; }
      }
    }
    this.ExpectInt32("plain auto fills", count, 72);
  }

  private func ExpectBurst(setName: CName, burst: CName) {
    let settings = this.Set(setName);
    let entries: array<ref<audioAudioMetadata>>;
    ArrayPush(entries, settings);
    PreemSoundSets.Patch(entries, PreemSoundSets.Fills());
    this.ExpectCName(NameToString(setName) + " burstFireSound", settings.burstFireSound, burst);
  }

  // One set per borrowed source (event map); Hercules is in the ep1 metadata.
  private cb func Test_BurstPerSource() {
    this.ExpectBurst(n"wea_pla_ajax", n"w_gun_rifle_power_masamune_fire_burst");
    this.ExpectBurst(n"wea_pla_lexington", n"w_gun_pistol_smart_chao_fire_burst");
    this.ExpectBurst(n"wea_pla_dian", n"w_gun_smg_smart_shingen_fire_burst");
    this.ExpectBurst(n"wea_pla_pulsar", n"w_gun_smg_tech_senkoh_fire_burst");
    this.ExpectBurst(n"wea_pla_hercules", n"w_gun_ticon_fire_burst");
  }

  // The event map: burst on 44 plain sound sets, plus the Toygun (gap).
  private cb func Test_BurstFillCount() {
    let count = 0;
    for fill in PreemSoundSets.Fills() {
      if Equals(fill.field, n"burstFireSound") && !StrContains(NameToString(fill.setName), "_suppressor") { count += 1; }
    }
    this.ExpectInt32("plain burst fills", count, 45);
  }

  private func Patched(setName: CName) -> ref<audioPlayerWeaponSettings> {
    let settings = this.Set(setName);
    let entries: array<ref<audioAudioMetadata>>;
    ArrayPush(entries, settings);
    PreemSoundSets.Patch(entries, PreemSoundSets.Fills());
    return settings;
  }

  // One set per borrowed source (event map).
  private cb func Test_ChargeStartPerSource() {
    this.ExpectCName("wea_pla_ajax chargeStartSound", this.Patched(n"wea_pla_ajax").chargeStartSound, n"w_gun_revol_tech_quasar_charge");
    this.ExpectCName("wea_pla_crusher chargeStartSound", this.Patched(n"wea_pla_crusher").chargeStartSound, n"w_gun_rifle_tech_achilles_charge_start");
    this.ExpectCName("wea_pla_igla chargeStartSound", this.Patched(n"wea_pla_igla").chargeStartSound, n"w_gun_shotgun_tech_satara_charge");
  }

  // Grit (ep1) has its own charge start; only its charge-ready sound is filled.
  private cb func Test_GritChargeReady() {
    let grit = this.Patched(n"wea_pla_grit");
    this.ExpectCName("wea_pla_grit chargeReadySound", grit.chargeReadySound, n"w_gun_revol_tech_quasar_charge");
    this.ExpectCName("wea_pla_grit chargeStartSound", grit.chargeStartSound, n"None");
  }

  private cb func Test_DefenderPerfectChargePerk() {
    let perk = this.Patched(n"wea_pla_defender").perfectChargePerkSounds;
    this.ExpectCName("Defender perfectChargeChargingSound", perk.perfectChargeChargingSound, n"w_gun_rifle_tech_achilles_perk_perfect_charge_charge");
    this.ExpectCName("Defender perfectChargeChargedSound", perk.perfectChargeChargedSound, n"w_gun_rifle_tech_achilles_perk_perfect_charge_ready");
    this.ExpectCName("Defender perfectChargeShootingSound", perk.perfectChargeShootingSound, n"w_gun_rifle_tech_achilles_perk_perfect_charge_shoot");
  }

  // The event map: charge start on 43 plain sound sets, plus Borg4a and the Toygun (gaps).
  private cb func Test_ChargeStartFillCount() {
    let count = 0;
    for fill in PreemSoundSets.Fills() {
      if Equals(fill.field, n"chargeStartSound") && !StrContains(NameToString(fill.setName), "_suppressor") { count += 1; }
    }
    this.ExpectInt32("plain charge start fills", count, 45);
  }

  // Suppressed sets (wea_pla_*_suppressor) borrow the suppressed events where a source has them
  // (event map); Liberty Dex's suppressed burst is the Chao's plain one.
  private cb func Test_SuppressedPerSource() {
    let liberty = this.Patched(n"wea_pla_liberty_suppressor");
    this.ExpectCName("liberty_suppressor autoFireSound", liberty.autoFireSound, n"w_gun_pistol_power_lexington_fire_suppressor_auto");
    this.ExpectCName("liberty_suppressor autoFireStop", liberty.autoFireStop, n"w_gun_pistol_power_lexington_fire_suppressor_auto_stop");
    this.ExpectCName("grad_suppressor autoFireSound", this.Patched(n"wea_pla_grad_suppressor").autoFireSound, n"w_gun_revol_power_overture_fire_suppressor_auto");
    this.ExpectCName("ajax_suppressor burstFireSound", this.Patched(n"wea_pla_ajax_suppressor").burstFireSound, n"w_gun_rifle_power_masamune_fire_suppressor_burst");
    this.ExpectCName("liberty_dex_suppressor burstFireSound", this.Patched(n"wea_pla_liberty_dex_suppressor").burstFireSound, n"w_gun_pistol_smart_chao_fire_burst");
    this.ExpectCName("kyubi_suppressor chargeStartSound", this.Patched(n"wea_pla_kyubi_suppressor").chargeStartSound, n"w_gun_rifle_tech_achilles_charge_start");
    this.ExpectCName("nue_suppressor perfectChargeShootingSound", this.Patched(n"wea_pla_nue_suppressor").perfectChargePerkSounds.perfectChargeShootingSound, n"w_gun_revol_tech_quasar_perk_perfect_charge_shoot");
  }

  // The event map: 54 fills on the 18 suppressed sets (auto 14, burst 16, charge start 18, perk 6),
  // plus the Masamune suppressed auto loop + stop (gap).
  private cb func Test_SuppressedFillCount() {
    let count = 0;
    for fill in PreemSoundSets.Fills() {
      if StrContains(NameToString(fill.setName), "_suppressor") { count += 1; }
    }
    this.ExpectInt32("suppressed fills", count, 56);
  }

  // Gaps 2.2.5 also had (Phase 3 gate): one set per donor, from notes/audioware-sounds.md
  // "Gap fills".
  private cb func Test_GapFillsPerDonor() {
    let achilles = this.Patched(n"wea_pla_achilles");
    this.ExpectCName("achilles autoFireSound", achilles.autoFireSound, n"w_gun_rifle_power_copperhead_fire_auto");
    this.ExpectCName("achilles autoFireStop", achilles.autoFireStop, n"w_gun_rifle_power_copperhead_fire_auto_stop");
    this.ExpectCName("chao autoFireSound", this.Patched(n"wea_pla_chao").autoFireSound, n"w_gun_pistol_smart_kappa_fire_auto");
    this.ExpectCName("crusher autoFireSound", this.Patched(n"wea_pla_crusher").autoFireSound, n"w_gun_rifle_power_pozhar_fire_auto");
    this.ExpectCName("kenshin autoFireSound", this.Patched(n"wea_pla_kenshin").autoFireSound, n"w_gun_revol_tech_quasar_fire_auto");
    this.ExpectCName("masamune_suppressor autoFireSound", this.Patched(n"wea_pla_masamune_suppressor").autoFireSound, n"w_gun_rifle_power_ajax_fire_suppressor_auto");
    this.ExpectCName("senkoh autoFireSound", this.Patched(n"wea_pla_senkoh").autoFireSound, n"w_gun_smg_power_pulsar_fire_auto");
    this.ExpectCName("shingen autoFireSound", this.Patched(n"wea_pla_shingen").autoFireSound, n"w_gun_warden_fire_auto");
    this.ExpectCName("silverhand autoFireSound", this.Patched(n"wea_pla_silverhand").autoFireSound, n"w_gun_revol_power_overture_fire_auto");
    this.ExpectCName("ticon_reed autoFireStop", this.Patched(n"wea_pla_ticon_reed").autoFireStop, n"w_gun_pistol_power_lexington_fire_suppressor_auto_stop");
    this.ExpectCName("borg4a chargeStartSound", this.Patched(n"wea_pla_borg4a").chargeStartSound, n"w_gun_smg_tech_senkoh_charge");
    let toygun = this.Patched(n"wea_pla_toygun");
    this.ExpectCName("toygun burstFireSound", toygun.burstFireSound, n"w_gun_pistol_smart_chao_fire_burst");
    this.ExpectCName("toygun chargeStartSound", toygun.chargeStartSound, n"w_gun_revol_tech_quasar_charge");
  }

  // The event map's 191 fills plus the 31 gap fills.
  private cb func Test_TotalFillCount() {
    let fills = PreemSoundSets.Fills();
    this.ExpectInt32("all fills", ArraySize(fills), 222);
  }

  // The rule itself, with a two-row fill list of its own: a field that already holds an event
  // keeps it, an empty one is set, and a set with another name is left alone.
  private cb func Test_FilledFieldIsKept() {
    let liberty = this.Set(n"wea_pla_liberty");
    liberty.autoFireSound = n"some_patch_sound";
    let other = this.Set(n"wea_pla_not_a_set");
    let fills: array<PreemSoundFill>;
    let loop: PreemSoundFill;
    loop.setName = n"wea_pla_liberty";
    loop.field = n"autoFireSound";
    loop.event = n"loop_event";
    let stop: PreemSoundFill;
    stop.setName = n"wea_pla_liberty";
    stop.field = n"autoFireStop";
    stop.event = n"stop_event";
    ArrayPush(fills, loop);
    ArrayPush(fills, stop);
    let count = PreemSoundSets.Patch(this.Entries(liberty, other), fills);
    this.ExpectCName("Liberty autoFireSound kept", liberty.autoFireSound, n"some_patch_sound");
    this.ExpectCName("Liberty autoFireStop filled", liberty.autoFireStop, n"stop_event");
    this.ExpectCName("other set untouched", other.autoFireStop, n"None");
    this.ExpectInt32("fields set", count, 1);
  }
}
