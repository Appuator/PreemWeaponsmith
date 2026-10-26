// Fire-mode sounds (SPEC §6, ADR 0001). The game's weapon audio plays a weapon's single shot,
// auto-fire loop and stop, burst and charge sounds from that weapon's sound set
// (audioPlayerWeaponSettings in cooked_metadata.audio_metadata). Many sets leave the fields for
// fire modes the weapon never had empty; trigger mods give it those modes, so the fills below
// point the empty fields at other weapons' existing events (the 2.2.5 archive's choices, listed
// in notes/audioware-sounds.md "Event map"). Only empty fields are ever set.
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
      PreemSoundSets.Fill(n"wea_pla_nekomata", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_nekomata", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_nova", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_nova", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_nue", n"autoFireSound", n"w_gun_rifle_power_ajax_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_nue", n"autoFireStop", n"w_gun_rifle_power_ajax_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_omaha", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_omaha", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_palica", n"autoFireSound", n"w_gun_rifle_power_pozhar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_palica", n"autoFireStop", n"w_gun_rifle_power_pozhar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_rasetsu", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_rasetsu", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
      PreemSoundSets.Fill(n"wea_pla_satara", n"autoFireSound", n"w_gun_revol_tech_quasar_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_satara", n"autoFireStop", n"w_gun_revol_tech_quasar_fire_auto_stop"),
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
      PreemSoundSets.Fill(n"wea_pla_zhuo", n"burstFireSound", n"w_gun_smg_smart_shingen_fire_burst")
    ];
  }

  // Sets each fill's field on the player sound set of that name when the field is empty.
  // Returns the number of fields set.
  public static func Patch(entries: array<ref<audioAudioMetadata>>, fills: array<PreemSoundFill>) -> Int32 {
    let count = 0;
    for entry in entries {
      let settings = entry as audioPlayerWeaponSettings;
      if IsDefined(settings) {
        for fill in fills {
          if Equals(fill.setName, settings.name) && PreemSoundSets.SetIfEmpty(settings, fill.field, fill.event) {
            count += 1;
          }
        }
      }
    }
    return count;
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
