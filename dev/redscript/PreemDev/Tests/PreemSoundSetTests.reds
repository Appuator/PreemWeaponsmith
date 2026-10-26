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
