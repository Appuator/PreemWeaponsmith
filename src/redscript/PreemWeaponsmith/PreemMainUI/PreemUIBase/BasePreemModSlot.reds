module PreemCrafting.PreemUI
import PreemCrafting.Core.*
import Codeware.UI.*

public class BasePreemModSlot extends inkCustomController {

    protected let m_name: String;

	protected let m_grid: ref<BasePreemGrid>;

	protected let m_container: wref<inkCanvas>;

	protected let m_slot: wref<inkCompoundWidget>;

	protected let m_button: ref<BasePreemButton>;

    public func Assign(grid: ref<BasePreemGrid>, rowIndex: Int32, cellIndex: Int32) -> Void {
		this.m_grid = grid;
		this.m_container = this.m_grid.GetContainer();

		let cell = grid.GetCell(rowIndex, cellIndex);
		
		this.OnAssign();
		this.Reparent(cell);
	}

    protected cb func OnAssign() -> Void {
		let namespace: String;
		StrSplitLast(NameToString(this.GetClassName()), ".", namespace, this.m_name);
	}

	protected cb func OnCreate() -> Void {
		let root: ref<inkCanvas> = new inkCanvas();
		root.SetName(this.GetClassName());
		root.SetAnchor(inkEAnchor.Centered);
		root.SetSize(150,150);

		let slotButton: ref<BasePreemButton> = BasePreemButton.Create();
		slotButton.SetName(n"slot");
		slotButton.ToggleAnimations(true);
		slotButton.ToggleSounds(true);
		slotButton.GetRootWidget().SetAnchor(inkEAnchor.Centered);
		slotButton.Reparent(root);

		this.m_button = slotButton;
		this.m_slot = root;

		this.SetRootWidget(root);
	}

	public func SetName(name:CName){
		this.m_button.SetName(name);
	}

	public func GetName() -> CName
	{
		return this.m_button.GetName();
	}

	public func SetText(text: String)
	{
		let button: ref<BasePreemButton> = this.m_slot.GetWidgetByIndex(0).GetController() as BasePreemButton;
		button.SetText(text);
		button.SetIconVisible(Equals(button.GetText(),""));
	}

	protected func RegisterListener(scriptable: ref<IScriptable>, eventName:CName, methodToCall: CName){

		let widget: ref<inkWidget> = this.m_slot.GetWidgetByIndex(0);
		let button: ref<BasePreemButton> = widget.GetController() as BasePreemButton;

		if IsDefined(button) {
			button.RegisterToCallback(eventName,scriptable,methodToCall);
		}
	}

	protected func Trigger(event: CName) -> Void {
		this.m_grid.CallCustomCallback(event);
	}

	public static func Create() -> ref<BasePreemModSlot>
    {
        let self: ref<BasePreemModSlot> = new BasePreemModSlot();
		self.CreateInstance();
		return self;
    }
}