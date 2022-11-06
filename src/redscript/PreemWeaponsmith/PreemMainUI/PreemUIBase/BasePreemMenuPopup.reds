// -----------------------------------------------------------------------------
// Codeware.UI.MenuPopup
// -----------------------------------------------------------------------------
//
// - [TODO] Base class for menu custom popups (Hub, Vendor, etc.)
//

module PreemCrafting.Codeware.UI

public abstract class BasePreemMenuPopup extends CustomPopup {

	protected let m_container: wref<inkCompoundWidget>;

	protected cb func OnCreate() -> Void {
		super.OnCreate();
		this.CreateContainer();
	}

	protected func CreateContainer() -> Void {
		let container: ref<inkCanvas> = new inkCanvas();
		container.SetName(n"container");
		container.SetMargin(new inkMargin(0.0, 0.0, 0.0, 200.0));
		container.SetAnchor(inkEAnchor.Centered);
		container.SetAnchorPoint(new Vector2(0.5, 0.5));
		container.SetSize(new Vector2(1000.0, 800.0));
		container.Reparent(this.GetRootCompoundWidget());

		this.m_container = container;

		this.SetContainerWidget(container);
	}

	protected cb func OnShow() -> Void {
		super.OnShow();

		this.SetUIContext();
	}

	protected cb func OnHide() -> Void {
		super.OnHide();

		this.ResetUIContext();
	}

	protected func SetUIContext() -> Void {
		let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGame());
		uiSystem.PushGameContext(UIGameContext.ModalPopup);
		uiSystem.RequestNewVisualState(n"inkInGameMenuStateSolid");
	}

	protected func ResetUIContext() -> Void {
		let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGame());
		uiSystem.PopGameContext(UIGameContext.ModalPopup);
		uiSystem.RestorePreviousVisualState(n"inkInGameMenuStateSolid");
	}
}
