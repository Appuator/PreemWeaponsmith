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

  // The event map: auto loop + stop on 23 plain sound sets.
  private cb func Test_AutoFillCount() {
    let count = 0;
    for fill in PreemSoundSets.Fills() {
      if Equals(fill.field, n"autoFireSound") || Equals(fill.field, n"autoFireStop") {
        if !StrContains(NameToString(fill.setName), "_suppressor") { count += 1; }
      }
    }
    this.ExpectInt32("plain auto fills", count, 46);
  }

  private cb func Test_FilledFieldIsKept() {
    let liberty = this.Set(n"wea_pla_liberty");
    liberty.autoFireSound = n"some_patch_sound";
    let other = this.Set(n"wea_pla_not_a_set");
    let count = PreemSoundSets.Patch(this.Entries(liberty, other), PreemSoundSets.Fills());
    this.ExpectCName("Liberty autoFireSound kept", liberty.autoFireSound, n"some_patch_sound");
    this.ExpectCName("Liberty autoFireStop filled", liberty.autoFireStop, n"w_gun_pistol_power_lexington_fire_auto_stop");
    this.ExpectInt32("fields set", count, 1);
  }
}
