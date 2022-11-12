module PreemCrafting.Codeware.UI
import PreemCrafting.Core.*


public class BasePreemModItem extends inkCustomController {

    protected let m_name: String;

	protected let m_grid: ref<BasePreemGrid>;

	protected let m_container: wref<inkCanvas>;

	protected let m_item: wref<inkCompoundWidget>;

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

		let itemButton: ref<BasePreemButton> = BasePreemButton.Create();
		itemButton.SetName(n"item");
		itemButton.ToggleAnimations(true);
		itemButton.ToggleSounds(true);
		itemButton.Reparent(root);

		this.m_button = itemButton;
		this.m_item = root;

		this.SetRootWidget(root);
	}

	public func SetName(name:CName){
		this.m_button.SetName(name);
	}

	protected func RegisterListener(scriptable: ref<IScriptable>, eventName:CName, methodToCall: CName){

		let widget: ref<inkWidget> = this.m_item.GetWidgetByIndex(0);
		let button: ref<BasePreemButton> = widget.GetController() as BasePreemButton;

		if IsDefined(button) {
			button.RegisterToCallback(eventName,scriptable,methodToCall);
		}
	}

	protected func Trigger(event: CName) -> Void {
		this.m_grid.CallCustomCallback(event);
	}

	public func SetText(text: String)
	{
		let button: ref<BasePreemButton> = this.m_item.GetWidgetByIndex(0).GetController() as BasePreemButton;
		button.SetText(text);
		button.SetIconVisible(Equals(button.GetText(),""));
	}

	public static func Create() -> ref<BasePreemModItem>
    {
        let self: ref<BasePreemModItem> = new BasePreemModItem();
		self.CreateInstance();
		return self;
    }

	public func GetContainer() -> wref<inkCanvas>
	{
		return this.m_container;
	}

}