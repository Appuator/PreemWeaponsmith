module PreemCrafting.Core

// The mod's settings for the current save (SPEC §5, §7): unlock mode, limit mode and slot layout.
// A ScriptableSystem's `persistent` fields are written into the save and read back when it loads,
// so each playthrough keeps its own values. A save that has none yet (a new game, or one from
// before this store) starts from the defaults: Mod Settings' values when it is installed (it fills
// PreemModSettings), else the built-in ones.
public class PreemSettings extends ScriptableSystem {
  private persistent let m_initialized: Bool;
  private persistent let m_unlockMode: PreemWeaponsmithProgressionModUnlockStyle;
  private persistent let m_limitMode: PreemWeaponsmithProgressionModAmountStyle;
  private persistent let m_slotLayout: PreemWeaponsmithModSlotPosition;

  public static func GetInstance(gi: GameInstance) -> ref<PreemSettings> {
    return GameInstance.GetScriptableSystemsContainer(gi).Get(n"PreemCrafting.Core.PreemSettings") as PreemSettings;
  }

  private func EnsureInitialized() -> Void {
    if !this.m_initialized {
      let defaults = new PreemModSettings();
      this.m_unlockMode = defaults.ModUnlockMode;
      this.m_limitMode = defaults.ModAmountMode;
      this.m_slotLayout = defaults.ModSlotPosition;
      this.m_initialized = true;
    }
  }

  public func GetUnlockMode() -> PreemWeaponsmithProgressionModUnlockStyle {
    this.EnsureInitialized();
    return this.m_unlockMode;
  }

  public func GetLimitMode() -> PreemWeaponsmithProgressionModAmountStyle {
    this.EnsureInitialized();
    return this.m_limitMode;
  }

  public func GetSlotLayout() -> PreemWeaponsmithModSlotPosition {
    this.EnsureInitialized();
    return this.m_slotLayout;
  }

  public func SetUnlockMode(mode: PreemWeaponsmithProgressionModUnlockStyle) -> Void {
    this.EnsureInitialized();
    this.m_unlockMode = mode;
  }

  public func SetLimitMode(mode: PreemWeaponsmithProgressionModAmountStyle) -> Void {
    this.EnsureInitialized();
    this.m_limitMode = mode;
  }

  public func SetSlotLayout(layout: PreemWeaponsmithModSlotPosition) -> Void {
    this.EnsureInitialized();
    this.m_slotLayout = layout;
  }
}
