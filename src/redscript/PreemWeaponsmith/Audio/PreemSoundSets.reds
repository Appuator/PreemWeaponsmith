// Fire-mode sounds (SPEC §6, ADR 0001). The game's weapon audio plays a weapon's single shot,
// auto-fire loop and stop, burst and charge sounds from that weapon's sound set
// (audioPlayerWeaponSettings in cooked_metadata.audio_metadata). Many sets leave the fields for
// fire modes the weapon never had empty; trigger mods give it those modes, so the fills below
// point the empty fields at other weapons' existing events (the 2.2.5 archive's choices, listed
// in notes/audioware-sounds.md "Event map"), except that every Tech weapon that isn't a pistol
// borrows Pozhar's auto loop (Phase 3 gate). Only empty fields are ever set.
// A weapon with a silencer attached plays its sound group's silenced set
// (audioWeaponSettingsGroup.playerSilenced); with none it plays nothing, so the fills also link
// groups that have none to a donor set (notes/silencer-sounds.md). Those rows name the group and
// the field playerSilenced.
module PreemCrafting.Audio

public struct PreemSoundFill {
  public let setName: CName;
  public let field: CName;
  public let event: CName;
}

public abstract class PreemSoundSets {
  public static func Fills() -> array<PreemSoundFill> {
    return [
      PreemSoundSets.Fill(n"wea_pla_ashura", n"autoFireSound", n"w_gun_smg_smart_sidewinder_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_ashura", n"autoFireStop", n"w_gun_smg_smart_sidewinder_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_burya", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_burya", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_carnage", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_carnage", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_grad", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_grad", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_grit", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_grit", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_igla", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_igla", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_kolac", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_kolac", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_kyubi", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_kyubi", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_liberty", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_liberty", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_liberty_dex", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_liberty_dex", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_metel", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_metel", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_nekomata", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_nekomata", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_nova", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_nova", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_nue", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_nue", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_omaha", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_omaha", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_palica", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_palica", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_rasetsu", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_rasetsu", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_satara", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_satara", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_sor22", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_sor22", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_tactician", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_tactician", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_testera", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_testera", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_unity", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_unity", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_zhuo", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_zhuo", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_ajax", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_ashura", n"burstFireSound", n"w_gun_smg_tech_senkoh_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_borg4a", n"burstFireSound", n"w_gun_ticon_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_burya", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_carnage", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_copperhead", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_crusher", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_defender", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_dian", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_grad", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_grit", n"burstFireSound", n"w_gun_ticon_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_guillotine", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_hercules", n"burstFireSound", n"w_gun_ticon_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_hmg_militech", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_kappa", n"burstFireSound", n"w_gun_pistol_smart_chao_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_kolac", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_kyubi", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_lexington", n"burstFireSound", n"w_gun_pistol_smart_chao_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_liberty", n"burstFireSound", n"w_gun_pistol_smart_chao_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_liberty_dex", n"burstFireSound", n"w_gun_pistol_smart_chao_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_ma70", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_metel", n"burstFireSound", n"w_gun_ticon_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_nekomata", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_nova", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_nue", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_omaha", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_overture", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_palica", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_pozhar", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_pulsar", n"burstFireSound", n"w_gun_smg_tech_senkoh_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_quasar", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_rasetsu", n"burstFireSound", n"w_gun_ticon_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_saratoga", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_satara", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_sidewinder", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_silverhand", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_slaught-o-matic", n"burstFireSound", n"w_gun_pistol_smart_chao_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_sor22", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_tactician", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_testera", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_umbra", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_unity", n"burstFireSound", n"w_gun_pistol_smart_chao_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_warden", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_zhuo", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_ajax", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_ashura", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_carnage", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_chao", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_chao_voodoo", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_copperhead", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_crusher", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_defender", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_defender", n"perfectChargeChargedSound", n"w_gun_rifle_tech_achilles_perk_perfect_charge_ready"),
      PreemSoundSets.Fill(n"wea_pla_defender", n"perfectChargeChargingSound", n"w_gun_rifle_tech_achilles_perk_perfect_charge_charge"),
      PreemSoundSets.Fill(n"wea_pla_defender", n"perfectChargeShootingSound", n"w_gun_rifle_tech_achilles_perk_perfect_charge_shoot"),
      PreemSoundSets.Fill(n"wea_pla_dian", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_grad", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_grit", n"chargeReadySound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_guillotine", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_hercules", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_hmg_militech", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_igla", n"chargeStartSound", n"w_gun_shotgun_tech_satara_charge"),
      PreemSoundSets.Fill(n"wea_pla_kappa", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_kolac", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_kyubi", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_lexington", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_liberty", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_liberty_dex", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_ma70", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_masamune", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_metel", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_nova", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_nue", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_osprey", n"chargeStartSound", n"w_gun_shotgun_tech_satara_charge"),
      PreemSoundSets.Fill(n"wea_pla_overture", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_palica", n"chargeStartSound", n"w_gun_shotgun_tech_satara_charge"),
      PreemSoundSets.Fill(n"wea_pla_pozhar", n"chargeStartSound", n"w_gun_shotgun_tech_satara_charge"),
      PreemSoundSets.Fill(n"wea_pla_pulsar", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_saratoga", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_shingen", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_sidewinder", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_slaught-o-matic", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_sor22", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_tactician", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_testera", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_umbra", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_unity", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_warden", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_yukimura", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_yukimura_preset", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_zhuo", n"chargeStartSound", n"w_gun_shotgun_tech_satara_charge"),
      PreemSoundSets.Fill(n"wea_pla_ajax_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_ajax_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_copperhead_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_copperhead_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_defender_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_defender_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_defender_suppressor", n"perfectChargeChargedSound", n"w_gun_rifle_tech_achilles_perk_perfect_charge_ready"),
      PreemSoundSets.Fill(n"wea_pla_defender_suppressor", n"perfectChargeChargingSound", n"w_gun_rifle_tech_achilles_perk_perfect_charge_charge"),
      PreemSoundSets.Fill(n"wea_pla_defender_suppressor", n"perfectChargeShootingSound", n"w_gun_rifle_tech_achilles_perk_perfect_charge_shoot"),
      PreemSoundSets.Fill(n"wea_pla_grad_suppressor", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_grad_suppressor", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_grad_suppressor", n"burstFireSound", n"w_gun_smg_tech_senkoh_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_grad_suppressor", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_guillotine_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_guillotine_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_kyubi_suppressor", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_kyubi_suppressor", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_kyubi_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_kyubi_suppressor", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_lexington_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_lexington_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_liberty_dex_suppressor", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_liberty_dex_suppressor", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_liberty_dex_suppressor", n"burstFireSound", n"w_gun_pistol_smart_chao_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_liberty_dex_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_liberty_suppressor", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_liberty_suppressor", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_liberty_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_liberty_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_masamune_suppressor", n"chargeStartSound", n"w_gun_pistol_tech_kenshin_charge"),
      PreemSoundSets.Fill(n"wea_pla_nova_suppressor", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_nova_suppressor", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_nova_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_nova_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_nue_suppressor", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_nue_suppressor", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_nue_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_nue_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_nue_suppressor", n"perfectChargeChargedSound", n"w_gun_revol_tech_quasar_perk_perfect_charge_ready"),
      PreemSoundSets.Fill(n"wea_pla_nue_suppressor", n"perfectChargeChargingSound", n"w_gun_revol_tech_quasar_perk_perfect_charge_charge"),
      PreemSoundSets.Fill(n"wea_pla_nue_suppressor", n"perfectChargeShootingSound", n"w_gun_revol_tech_quasar_perk_perfect_charge_shoot"),
      PreemSoundSets.Fill(n"wea_pla_overture_suppressor", n"burstFireSound", n"w_gun_smg_tech_senkoh_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_overture_suppressor", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      PreemSoundSets.Fill(n"wea_pla_pulsar_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_pulsar_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_saratoga_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_saratoga_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_umbra_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_umbra_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_unity_suppressor", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_unity_suppressor", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_unity_suppressor", n"burstFireSound", n"w_gun_rifle_power_masamune_fire_suppressor_burst"),
      PreemSoundSets.Fill(n"wea_pla_unity_suppressor", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      PreemSoundSets.Fill(n"wea_pla_warden_suppressor", n"chargeStartSound", n"w_gun_rifle_tech_achilles_charge_start"),
      // Gaps 2.2.5 also had (Phase 3 gate; donors in notes/audioware-sounds.md "Gap fills").
      PreemSoundSets.Fill(n"wea_pla_achilles", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_achilles", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_borg4a", n"chargeStartSound", n"w_gun_smg_tech_senkoh_charge"),
      PreemSoundSets.Fill(n"wea_pla_chao", n"autoFireSound", n"w_gun_pistol_smart_kappa_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_chao", n"autoFireStop", n"w_gun_pistol_smart_kappa_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_chao_voodoo", n"autoFireSound", n"w_gun_pistol_smart_kappa_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_chao_voodoo", n"autoFireStop", n"w_gun_pistol_smart_kappa_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_crusher", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_crusher", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_kenshin", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_kenshin", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_kenshin_chaos", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_kenshin_chaos", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_masamune", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_masamune", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_masamune_suppressor", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_masamune_suppressor", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_senkoh", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_senkoh", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_senkoh_prototype", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_senkoh_prototype", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_shingen", n"autoFireSound", n"w_gun_warden_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_shingen", n"autoFireStop", n"w_gun_warden_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_silverhand", n"autoFireSound", n"w_gun_revol_power_overture_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_silverhand", n"autoFireStop", n"w_gun_revol_power_overture_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_ticon", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_ticon", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_ticon_reed", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_suppressor_auto"),
      PreemSoundSets.Fill(n"wea_pla_ticon_reed", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_suppressor_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_toygun", n"burstFireSound", n"w_gun_pistol_smart_chao_fire_burst"),
      PreemSoundSets.Fill(n"wea_pla_toygun", n"chargeStartSound", n"w_gun_revol_tech_quasar_charge"),
      // Silenced sets: the Grad's own suppressed set (the 2.2.5 archive's link for wea_set_grad;
      // Panam's Grad already plays it unsilenced).
      PreemSoundSets.Fill(n"wea_set_grad", n"playerSilenced", n"wea_pla_grad_suppressor"),
      PreemSoundSets.Fill(n"wea_set_grad_panam", n"playerSilenced", n"wea_pla_grad_suppressor"),
      // The other groups without one: the 2.2.5 archive's donors; where 2.2.5 had none, a group
      // whose plain set is already suppressed keeps it (Nova Hitman, Unity Dex, Warden Boris) and
      // the Chopper HMG borrows the Defender LMG's (notes/silencer-sounds.md "Donors").
      PreemSoundSets.Fill(n"wea_set_achilles", n"playerSilenced", n"wea_pla_kyubi_suppressor"),
      PreemSoundSets.Fill(n"wea_set_ashura", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_borg4a", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_burya", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_carnage", n"playerSilenced", n"wea_pla_grad_suppressor"),
      PreemSoundSets.Fill(n"wea_set_chao", n"playerSilenced", n"wea_pla_masamune_suppressor"),
      PreemSoundSets.Fill(n"wea_set_chao_voodoo", n"playerSilenced", n"wea_pla_lexington_suppressor"),
      PreemSoundSets.Fill(n"wea_set_crusher", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_dian", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_grit", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_hercules", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_hmg", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_igla", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_kappa", n"playerSilenced", n"wea_pla_lexington_suppressor"),
      PreemSoundSets.Fill(n"wea_set_kenshin", n"playerSilenced", n"wea_pla_masamune_suppressor"),
      PreemSoundSets.Fill(n"wea_set_kenshin_chaos", n"playerSilenced", n"wea_pla_masamune_suppressor"),
      PreemSoundSets.Fill(n"wea_set_kolac", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_ma70", n"playerSilenced", n"wea_pla_defender_suppressor"),
      PreemSoundSets.Fill(n"wea_set_metel", n"playerSilenced", n"wea_pla_grad_suppressor"),
      PreemSoundSets.Fill(n"wea_set_nekomata", n"playerSilenced", n"wea_pla_grad_suppressor"),
      PreemSoundSets.Fill(n"wea_set_nova_suppressor", n"playerSilenced", n"wea_pla_nova_suppressor"),
      PreemSoundSets.Fill(n"wea_set_omaha", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_osprey", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_palica", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_pozhar", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_quasar", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_rasetsu", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_satara", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_senkoh", n"playerSilenced", n"wea_pla_masamune_suppressor"),
      PreemSoundSets.Fill(n"wea_set_senkoh_prototype", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_shingen", n"playerSilenced", n"wea_pla_masamune_suppressor"),
      PreemSoundSets.Fill(n"wea_set_sidewinder", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_silverhand", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_slaught", n"playerSilenced", n"wea_pla_lexington_suppressor"),
      PreemSoundSets.Fill(n"wea_set_sor22", n"playerSilenced", n"wea_pla_kyubi_suppressor"),
      PreemSoundSets.Fill(n"wea_set_special_flak_cannon", n"playerSilenced", n"wea_pla_defender_suppressor"),
      PreemSoundSets.Fill(n"wea_set_tactician", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_testera", n"playerSilenced", n"wea_pla_nue_suppressor"),
      PreemSoundSets.Fill(n"wea_set_ticon", n"playerSilenced", n"wea_pla_masamune_suppressor"),
      PreemSoundSets.Fill(n"wea_set_ticon_reed", n"playerSilenced", n"wea_pla_masamune_suppressor"),
      PreemSoundSets.Fill(n"wea_set_unity_dex", n"playerSilenced", n"wea_pla_unity_suppressor"),
      PreemSoundSets.Fill(n"wea_set_warden", n"playerSilenced", n"wea_pla_warden_suppressor"),
      PreemSoundSets.Fill(n"wea_set_warden_suppressor", n"playerSilenced", n"wea_pla_warden_suppressor"),
      PreemSoundSets.Fill(n"wea_set_yukimura", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_yukimura_preset", n"playerSilenced", n"wea_pla_ajax_suppressor"),
      PreemSoundSets.Fill(n"wea_set_zhuo", n"playerSilenced", n"wea_pla_nue_suppressor")
    ];
  }

  // Sets each fill's field on the player sound set (or sound group) of that name when the field
  // is empty (for a group's silenced link: IsEmptyLink). Returns the number of fields set.
  public static func Patch(entries: array<ref<audioAudioMetadata>>, fills: array<PreemSoundFill>) -> Int32 {
    let count = 0;
    for entry in entries {
      let settings = entry as audioPlayerWeaponSettings;
      let group = entry as audioWeaponSettingsGroup;
      for fill in fills {
        if IsDefined(settings) && Equals(fill.setName, settings.name) && PreemSoundSets.SetIfEmpty(settings, fill.field, fill.event) {
          count += 1;
        }
        if IsDefined(group) && Equals(fill.setName, group.name) && Equals(fill.field, n"playerSilenced") && PreemSoundSets.IsEmptyLink(group.playerSilenced) {
          group.playerSilenced = fill.event;
          count += 1;
        }
      }
    }
    return count;
  }

  // A silenced link counts as empty when it names no set: None, or a set vanilla 2.5 names but
  // never defines (wea_set_ticon's wea_pla_ticon_suppressor), which also plays nothing.
  private static func IsEmptyLink(link: CName) -> Bool {
    return !IsNameValid(link) || Equals(link, n"wea_pla_ticon_suppressor");
  }

  private static func Fill(setName: CName, field: CName, event: CName) -> PreemSoundFill {
    let fill: PreemSoundFill;
    fill.setName = setName;
    fill.field = field;
    fill.event = event;
    return fill;
  }

  private static func SetIfEmpty(settings: ref<audioPlayerWeaponSettings>, field: CName, event: CName) -> Bool {
    switch field {
      case n"autoFireSound":
        if IsNameValid(settings.autoFireSound) { return false; }
        settings.autoFireSound = event;
        return true;
      case n"autoFireStop":
        if IsNameValid(settings.autoFireStop) { return false; }
        settings.autoFireStop = event;
        return true;
      case n"burstFireSound":
        if IsNameValid(settings.burstFireSound) { return false; }
        settings.burstFireSound = event;
        return true;
      case n"chargeStartSound":
        if IsNameValid(settings.chargeStartSound) { return false; }
        settings.chargeStartSound = event;
        return true;
      case n"chargeReadySound":
        if IsNameValid(settings.chargeReadySound) { return false; }
        settings.chargeReadySound = event;
        return true;
      case n"perfectChargeChargingSound":
        if IsNameValid(settings.perfectChargePerkSounds.perfectChargeChargingSound) { return false; }
        settings.perfectChargePerkSounds.perfectChargeChargingSound = event;
        return true;
      case n"perfectChargeChargedSound":
        if IsNameValid(settings.perfectChargePerkSounds.perfectChargeChargedSound) { return false; }
        settings.perfectChargePerkSounds.perfectChargeChargedSound = event;
        return true;
      case n"perfectChargeShootingSound":
        if IsNameValid(settings.perfectChargePerkSounds.perfectChargeShootingSound) { return false; }
        settings.perfectChargePerkSounds.perfectChargeShootingSound = event;
        return true;
      default:
        return false;
    }
  }
}

// Applies the fills when the game loads its sound metadata. Codeware's Resource/Ready runs after
// a resource is loaded and before anything uses it.
public class PreemSoundSetService extends ScriptableService {
  private cb func OnLoad() {
    GameInstance.GetCallbackSystem()
      .RegisterCallback(n"Resource/Ready", this, n"OnMetadataReady")
      .AddTarget(ResourceTarget.Path(r"base\\sound\\metadata\\cooked_metadata.audio_metadata"))
      .AddTarget(ResourceTarget.Path(r"ep1\\sound\\metadata\\cooked_metadata.audio_metadata"));
  }

  private cb func OnMetadataReady(event: ref<ResourceEvent>) {
    let metadata = event.GetResource() as audioCookedMetadataResource;
    if !IsDefined(metadata) { return; }
    let count = PreemSoundSets.Patch(metadata.entries, PreemSoundSets.Fills());
    FTLog(s"[PreemWeaponsmith] sound sets: \(count) fields set in \(ResRef.ToString(event.GetPath()))");
  }
}
