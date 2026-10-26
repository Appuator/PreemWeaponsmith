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
      PreemSoundSets.Fill(n"wea_pla_liberty", n"autoFireSound", n"w_gun_pistol_power_lexington_fire_auto"),
      PreemSoundSets.Fill(n"wea_pla_liberty", n"autoFireStop", n"w_gun_pistol_power_lexington_fire_auto_stop")
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
