module PreemCrafting.Codeware.UI

public abstract class BasePreemSlotClassGroup extends inkCustomController {
	protected let m_name: String;

	protected let m_grid: wref<BasePreemGrid>;

	protected let m_container: wref<inkCanvas>;

	protected let m_slotRowH: wref<inkCompoundWidget>;

	protected let m_slotRowV: wref<inkCompoundWidget>;

	protected let m_lblClass: wref<inkText>;

	protected let m_bg: wref<inkRectangle>;

	protected let m_currentOrientation: SlotClassGroupOrientation;

	protected cb func OnAssign() -> Void {
		let namespace: String;
		StrSplitLast(NameToString(this.GetClassName()), ".", namespace, this.m_name);
	}

	protected cb func OnCreate() -> Void {
		let root: ref<inkCanvas> = new inkCanvas();
		root.SetName(this.GetClassName());
		root.SetAnchor(inkEAnchor.Centered);
		root.SetSize(400,200);

        let Bg: ref<inkRectangle> = new inkRectangle();
        Bg.SetAnchor(inkEAnchor.Fill);
        Bg.SetTintColor(ThemeColors.PureBlack());
		Bg.SetOpacity(0.8);
        Bg.Reparent(root);

        let lblClassGroup: ref<inkText> = new inkText();
        lblClassGroup.SetName(n"lblClassGroup");
		lblClassGroup.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		lblClassGroup.SetFontStyle(n"Small");
		lblClassGroup.SetFontSize(30);
		lblClassGroup.SetLetterCase(textLetterCase.UpperCase);
		lblClassGroup.SetTintColor(ThemeColors.ElectricBlue());
		lblClassGroup.SetAnchor(inkEAnchor.TopLeft);
		lblClassGroup.SetHorizontalAlignment(textHorizontalAlignment.Left);
		lblClassGroup.SetVerticalAlignment(textVerticalAlignment.Top);
		lblClassGroup.SetText("Class");
        lblClassGroup.Reparent(root);

        let slotRowH: ref<inkHorizontalPanel> = new inkHorizontalPanel();
		slotRowH.SetFitToContent(true);
		//slotRowH.SetAnchor(inkEAnchor.BottomCenter);
		slotRowH.SetHAlign(inkEHorizontalAlign.Center);
        slotRowH.SetVAlign(inkEVerticalAlign.Center);
		slotRowH.SetChildMargin(new inkMargin(20.0, 30.0, 20.0, 0.0));
		slotRowH.Reparent(root);
		slotRowH.SetVisible(true);

		let slotRowV: ref<inkVerticalPanel> = new inkVerticalPanel();
		slotRowV.SetFitToContent(true);
		//slotRowV.SetAnchor(inkEAnchor.BottomCenter);
		slotRowV.SetHAlign(inkEHorizontalAlign.Center);
        slotRowV.SetVAlign(inkEVerticalAlign.Center);
		slotRowV.SetChildMargin(new inkMargin(20.0, 30.0, 20.0, 0.0));
		slotRowV.Reparent(root);
		slotRowV.SetVisible(false);


		this.m_slotRowH = slotRowH;
		this.m_slotRowV = slotRowV;
		this.m_bg = Bg;
		this.m_currentOrientation = SlotClassGroupOrientation.Horizontal;
		this.m_lblClass = lblClassGroup;

		this.SetRootWidget(root);
	}

	protected func AddModSlot(slot: ref<BasePreemModSlot>, orientation: SlotClassGroupOrientation)
	{
		if(Equals(orientation, SlotClassGroupOrientation.Horizontal))
		{
			slot.GetRootCompoundWidget().Reparent(this.m_slotRowH);
		}
		else{
			slot.GetRootCompoundWidget().Reparent(this.m_slotRowV);
		}
	}

	protected func SetOrientation(orientation: SlotClassGroupOrientation){
		if(Equals(orientation, SlotClassGroupOrientation.Horizontal))
		{
			this.m_slotRowH.SetVisible(true);
			this.m_slotRowV.SetVisible(false);
			this.GetRootWidget().SetSize(400,200);
			this.m_currentOrientation = SlotClassGroupOrientation.Horizontal;
		}
		else{
			this.m_slotRowH.SetVisible(false);
			this.m_slotRowV.SetVisible(true);
			this.GetRootWidget().SetSize(200,400);
			this.m_currentOrientation = SlotClassGroupOrientation.Vertical;
		}
	}

	protected func GetAreaSize() -> Vector2 {
		return this.m_grid.GetSize();
	}

	protected func Trigger(event: CName) -> Void {
		this.m_grid.CallCustomCallback(event);
	}

	public func Assign(grid: ref<BasePreemGrid>) -> Void {
		this.Assign(grid, 0, 0);
	}

	public func Assign(grid: ref<BasePreemGrid>, rowIndex: Int32, cellIndex: Int32) -> Void {
		this.m_grid = grid;
		this.m_container = this.m_grid.GetContainer();

		let cell = grid.GetCell(rowIndex, cellIndex);
		
		this.OnAssign();
		this.Reparent(cell);
	}

	protected func SetListener(listenerEventName: CName, methodToCall: CName){

		this.RegisterListenerToSlotButtons(this.m_slotRowH, listenerEventName,methodToCall);
		this.RegisterListenerToSlotButtons(this.m_slotRowV, listenerEventName,methodToCall);
	}

	protected func RegisterListenerToSlotButtons(container: wref<inkCompoundWidget>, eventName:CName, methodToCall: CName) -> Void {
		let childIndex: Int32 = 0;
		let numChildren: Int32 = container.GetNumChildren();

		while childIndex < numChildren {
			let widget: ref<inkWidget> = container.GetWidgetByIndex(childIndex);
			let slot: ref<BasePreemModSlot> = widget.GetController() as BasePreemModSlot;

			if IsDefined(slot) {
				//slot.RegisterToCallback(eventName,this,methodToCall);
				slot.RegisterListener(this, eventName, methodToCall);
			}

			childIndex += 1;
		}
	}

	// public func GetSlot(slotIndex: Int32) -> wref<CustomButton>
	// {
	// 	let slotContainer: wref<inkCompoundWidget>;
	// 	if Equals(this.m_currentOrientation, SlotClassGroupOrientation.Horizontal)
	// 	{
	// 		slotContainer = this.m_slotRowH;
	// 	}
	// 	else{
	// 		slotContainer = this.m_slotRowV;
	// 	}

	// 	let widget: ref<inkWidget> = slotContainer.GetWidgetByIndex(slotIndex);
	// 	let button: ref<CustomButton> = widget.GetController() as CustomButton;

	// 	return button;
	// }

	// protected cb func OnRelease(evt: ref<inkPointerEvent>) -> Bool {
	// 	let button: ref<CustomButton> = evt.GetTarget().GetController() as CustomButton;

	// 	if evt.IsAction(n"popup_moveUp") {
	// 		button.SetDisabled(!button.IsDisabled());

	// 		// let buttonName: String = button.GetText();
	// 		// let buttonEvent: String = button.IsDisabled()
	// 		// 	? "OnDisable"
	// 		// 	: "OnEnable";

	// 		this.UpdateHints(button);

	// 		this.PlaySound(n"MapPin", n"OnCreate");
	// 	}
	// }

	// protected cb func OnEnter(evt: ref<inkPointerEvent>) -> Bool {
	// 	let button: ref<CustomButton> = evt.GetTarget().GetController() as CustomButton;

	// 	this.UpdateHints(button);
	// }

	// protected cb func OnLeave(evt: ref<inkPointerEvent>) -> Bool {
	// 	this.RemoveHints();
	// }

	// protected func UpdateHints(button: ref<CustomButton>) -> Void {
	// 	this.UpdateHint(
	// 		n"popup_moveUp",
	// 			button.IsEnabled()
	// 				? "OnDisable"
	// 				: "OnEnable"
	// 	);

	// 	this.UpdateHint(
	// 		n"click",
	// 		"OnClick",
	// 		button.IsEnabled()
	// 	);
	// }

	// protected func RemoveHints() -> Void {
	// 	this.RemoveHint(n"popup_moveUp");
	// 	this.RemoveHint(n"click");
	// }

	// protected func UpdateHint(action: CName, label: String, active: Bool) -> Void {
	// 	if active {
	// 		this.m_workbench.GetHints().AddButtonHint(action, label);
	// 	} else {
	// 		this.m_workbench.GetHints().RemoveButtonHint(action);
	// 	}
	// }

	// protected func UpdateHint(action: CName, label: String) -> Void {
	// 	this.m_workbench.GetHints().AddButtonHint(action, label);
	// }

	// protected func UpdateHoldHint(action: CName, label: String, active: Bool) -> Void {
	// 	if active {
	// 		this.m_workbench.GetHints().AddButtonHint(action, "[" + GetLocalizedText("LocKey#565") + "] " + label);
	// 	} else {
	// 		this.m_workbench.GetHints().RemoveButtonHint(action);
	// 	}
	// }

	// protected func UpdateHoldHint(action: CName, label: String) -> Void {
	// 	this.m_workbench.GetHints().AddButtonHint(action, "[" + GetLocalizedText("LocKey#565") + "] " + label);
	// }

	// protected func RemoveHint(action: CName) -> Void {
	// 	this.m_workbench.GetHints().RemoveButtonHint(action);
	// }

	// protected func LockHints() -> Void {
	// 	this.m_workbench.GetHints().Lock();
	// }

	// protected func UnlockHints() -> Void {
	// 	this.m_workbench.GetHints().Unlock();
	// }
}
