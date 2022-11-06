module PreemCrafting.PreemUI
import PreemCrafting.Codeware.UI.*

public class PreemModSelectorPopup extends BasePreemMenuPopup {

    protected let m_preemGrid: ref<PreemGrid>;
    protected let m_preemContent: ref<inkCompoundWidget>;
    
    protected cb func OnCreate() -> Void {
		super.OnCreate();

        let content = new inkCanvas();
        content.SetAnchor(inkEAnchor.Fill);
        content.Reparent(this.m_container);
        this.m_preemContent = content;
        this.m_preemGrid.Reparent(this.m_preemContent);
        this.RegisterListener(this, n"OnModSelected", n"OnPreemModSelectedCallBack");
    }

    public static func Show(requester: ref<inkGameController>, grid: ref<PreemGrid>) -> Void {
		let popup: ref<PreemModSelectorPopup> = new PreemModSelectorPopup();
        popup.SetModContent(grid);
        popup.Open(requester);
	}

    protected cb func OnInitialize() -> Void {
		super.OnInitialize();
	}

    public cb func OnPreemModSelectedCallBack(widget: wref<inkWidget>) -> Bool
	{
		LogChannel(n"DEBUG", s"PreemUI PreemPopup:: CloseDialog");
        this.Close();
	}

    public func GetSize() -> Vector2{
        return this.m_container.GetSize();
    }

    public func SetModContent(grid: ref<PreemGrid>) -> Void{
       this.m_preemGrid = grid;
       this.m_preemGrid.Reparent(this.m_preemContent);
       this.RegisterListener(this, n"OnModSelected", n"OnPreemModSelectedCallBack");
    }

	public func UseCursor() -> Bool {
		return true;
	}

    protected func RegisterListener(scriptable: ref<IScriptable>, eventName:CName, methodToCall: CName){

		let widget: ref<inkWidget> = this.m_preemContent.GetWidgetByIndex(0);
		let grid: ref<PreemGrid> = widget.GetController() as PreemGrid;

		if IsDefined(grid) {
			grid.RegisterToCallback(eventName,scriptable,methodToCall);
		}
	}

}
