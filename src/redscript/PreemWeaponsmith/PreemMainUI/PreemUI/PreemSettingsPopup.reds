module PreemCrafting.PreemUI
import PreemCrafting.Core.*
import Codeware.UI.*

// The settings panel (SPEC §7): changes this save's unlock mode, limit mode and slot layout
// (PreemSettings). Each button cycles one setting; the crafting screen applies it at once
// (CraftingMainGameController.ApplyPreemSettings). Opened from the SETTINGS button on the Preem
// slot frame; Esc / Back closes it.
public class PreemSettingsPopup extends BasePreemMenuPopup {

  private let m_settings: ref<PreemSettings>;
  private let m_owner: wref<CraftingMainGameController>;
  private let m_unlockButton: ref<BasePreemButton>;
  private let m_limitButton: ref<BasePreemButton>;
  private let m_layoutButton: ref<BasePreemButton>;

  public static func Show(owner: ref<CraftingMainGameController>, settings: ref<PreemSettings>) -> ref<PreemSettingsPopup> {
    let popup = new PreemSettingsPopup();
    popup.m_settings = settings;
    popup.m_owner = owner;
    popup.Open(owner);
    return popup;
  }

  protected cb func OnCreate() -> Void {
    super.OnCreate();

    let panel = new inkVerticalPanel();
    panel.SetName(n"settings");
    panel.SetAnchor(inkEAnchor.Centered);
    panel.SetAnchorPoint(new Vector2(0.5, 0.5));
    panel.SetChildMargin(new inkMargin(0.0, 12.0, 0.0, 12.0));
    panel.Reparent(this.m_container);

    let title = new inkText();
    title.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    title.SetFontStyle(n"Medium");
    title.SetFontSize(50);
    title.SetLetterCase(textLetterCase.UpperCase);
    title.SetTintColor(ThemeColors.Bittersweet());
    title.SetText("Preem Weaponsmith settings (this save)");
    title.Reparent(panel);

    this.m_unlockButton = this.AddSettingButton(panel, n"OnUnlockClicked");
    this.m_limitButton = this.AddSettingButton(panel, n"OnLimitClicked");
    this.m_layoutButton = this.AddSettingButton(panel, n"OnLayoutClicked");
    this.Refresh();
  }

  private func AddSettingButton(parent: ref<inkCompoundWidget>, callback: CName) -> ref<BasePreemButton> {
    let button = BasePreemButton.Create();
    button.GetRootWidget().SetSize(new Vector2(900.0, 110.0));
    button.ToggleAnimations(true);
    button.ToggleSounds(true);
    button.RegisterToCallback(n"OnBtnClick", this, callback);
    button.Reparent(parent);
    return button;
  }

  private func Refresh() -> Void {
    if !IsDefined(this.m_settings) {
      return;
    }
    this.m_unlockButton.SetText(Equals(this.m_settings.GetUnlockMode(), PreemWeaponsmithProgressionModUnlockStyle.Sandbox)
      ? "Mod unlocks: Sandbox (every mod)" : "Mod unlocks: Weapon Blueprints (by weapon rarity)");
    this.m_limitButton.SetText(Equals(this.m_settings.GetLimitMode(), PreemWeaponsmithProgressionModAmountStyle.Sandbox)
      ? "Mod limit: Sandbox (6 per weapon)" : "Mod limit: Weapon Blueprints (by weapon rarity)");
    this.m_layoutButton.SetText(Equals(this.m_settings.GetSlotLayout(), PreemWeaponsmithModSlotPosition.OnWeapon)
      ? "Slot layout: on the weapon" : "Slot layout: below the weapon");
  }

  private func Changed() -> Void {
    this.Refresh();
    if IsDefined(this.m_owner) {
      this.m_owner.ApplyPreemSettings();
    }
  }

  public cb func OnUnlockClicked(widget: wref<inkWidget>) -> Bool {
    this.m_settings.SetUnlockMode(Equals(this.m_settings.GetUnlockMode(), PreemWeaponsmithProgressionModUnlockStyle.Sandbox)
      ? PreemWeaponsmithProgressionModUnlockStyle.WeaponBlueprints : PreemWeaponsmithProgressionModUnlockStyle.Sandbox);
    this.Changed();
  }

  public cb func OnLimitClicked(widget: wref<inkWidget>) -> Bool {
    this.m_settings.SetLimitMode(Equals(this.m_settings.GetLimitMode(), PreemWeaponsmithProgressionModAmountStyle.Sandbox)
      ? PreemWeaponsmithProgressionModAmountStyle.WeaponBlueprints : PreemWeaponsmithProgressionModAmountStyle.Sandbox);
    this.Changed();
  }

  public cb func OnLayoutClicked(widget: wref<inkWidget>) -> Bool {
    this.m_settings.SetSlotLayout(Equals(this.m_settings.GetSlotLayout(), PreemWeaponsmithModSlotPosition.OnWeapon)
      ? PreemWeaponsmithModSlotPosition.BelowWeapon : PreemWeaponsmithModSlotPosition.OnWeapon);
    this.Changed();
  }

  public func UseCursor() -> Bool {
    return true;
  }

  protected cb func OnGlobalReleaseInput(evt: ref<inkPointerEvent>) -> Void {
    if evt.IsAction(n"cancel") {
      this.Close();
    }
    super.OnGlobalReleaseInput(evt);
  }
}
