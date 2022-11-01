module PreemCrafting.UI
import PreemCrafting.Codeware.UI.*
import PreemCrafting.Codeware.Popup.*

public class PreemModSelectorPopup extends BasePreemMenuPopup {

    protected let m_grid: ref<PreemGrid>;
    protected let m_content: ref<inkCompoundWidget>;
    
    protected cb func OnCreate() -> Void {
		super.OnCreate();

        let content = new inkCanvas();
        content.SetAnchor(inkEAnchor.Fill);
        content.Reparent(this.m_container);
        this.m_content = content;
        this.m_grid.Reparent(this.m_content);
    }

    public func Show(requester: ref<inkGameController>) -> Void {
		// Pass popup options
		//popup.SetOption1(param1);
        this.Open(requester);
	}

    protected cb func OnInitialize() -> Void {
		super.OnInitialize();
	}

    public cb func OnPreemModSelectedCallBack(widget: wref<inkWidget>) -> Bool
	{
		//LogChannel(n"DEBUG", s"PreemUI PreemPopup:: CloseDialog");
        this.Close();
	}

    public func GetSize() -> Vector2{
        return this.m_container.GetSize();
    }

	public func UseCursor() -> Bool {
		return true;
	}

    public static func Create(grid: ref<PreemGrid>) -> ref<PreemModSelectorPopup>
    {
        let self: ref<PreemModSelectorPopup> = new PreemModSelectorPopup();
        self.m_grid = grid;
		self.CreateInstance();
		return self;
    }

}
