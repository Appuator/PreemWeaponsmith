module PreemCrafting.PreemUI
import PreemCrafting.Codeware.UI.*

public class PreemModSelectorPopup extends BasePreemMenuPopup {

    protected let m_preemGrid: ref<PreemGrid>;
    protected let m_preemContent: ref<inkCompoundWidget>;
    private let m_tooltipsManager: wref<gameuiTooltipsManager>;

    
    protected cb func OnCreate() -> Void {
		super.OnCreate();

        let content = new inkCanvas();
        content.SetAnchor(inkEAnchor.Fill);
        content.Reparent(this.m_container);
        this.m_preemContent = content;
        this.m_preemGrid.Reparent(this.m_preemContent);
        this.RegisterListener(this, n"OnModSelected", n"OnPreemModSelectedCallBack");
        //this.RegisterListener(this, n"OnHoverOver", n"OnPreemModHoverOverCallBack");
        //this.RegisterListener(this, n"OnHoverOut", n"OnPreemModHoverOutCallBack");
    }

    public static func Show(requester: ref<inkGameController>, grid: ref<PreemGrid>) -> Void {
		let popup: ref<PreemModSelectorPopup> = new PreemModSelectorPopup();
        popup.SetModContent(grid);
        popup.Open(requester);
	}

    public static func Show(requester: ref<inkGameController>, grid: ref<PreemGrid>, tooltipsManager: wref<gameuiTooltipsManager>) -> Void {
		let popup: ref<PreemModSelectorPopup> = new PreemModSelectorPopup();
        popup.SetModContent(grid);
        popup.SetupTooltips(tooltipsManager);
        popup.Open(requester);
	}

    protected cb func OnInitialize() -> Void {
		super.OnInitialize();
        // this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    	// this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
        // this.RegisterListener(this, n"OnHoverOver", n"OnPreemModHoverOverCallBack");
        // this.RegisterListener(this, n"OnHoverOut", n"OnPreemModHoverOutCallBack");
	}  

    public cb func OnPreemModSelectedCallBack(widget: wref<inkWidget>) -> Bool
	{
		LogChannel(n"DEBUG", s"PreemUI PreemPopup:: CloseDialog");
        this.UnregisterListener(this, n"OnPreemModSelected", n"OnPreemModSelectedCallBack");
        this.UnregisterListener(this, n"OnHoverOver", n"OnPreemModHoverOverCallBack");
        this.UnregisterListener(this, n"OnHoverOut", n"OnPreemModHoverOutCallBack");
        this.m_tooltipsManager.HideTooltips();
        this.Close();
	}

    // public cb func OnPreemModHoverOverCallBack(evt: ref<inkPointerEvent>) -> Bool
	// {
	// 	LogChannel(n"DEBUG", s"PreemUI PreemPopup:: \(evt.GetTarget().GetName())");
    //     let tooltipData: ref<MaterialTooltipData> = new MaterialTooltipData();
    //     tooltipData.Title = NameToString(evt.GetTarget().GetName());
    //     tooltipData.BaseMaterialQuantity = 2;
    //     tooltipData.MaterialQuantity = 2;
    //     this.m_tooltipsManager.ShowTooltipAtWidget(n"materialTooltip", this.m_preemContent, tooltipData, gameuiETooltipPlacement.RightTop);
	// }

    // public cb func OnPreemModHoverOutCallBack(evt: ref<inkPointerEvent>) -> Bool
	// {
    //     this.m_tooltipsManager.HideTooltips();
	// 	LogChannel(n"DEBUG", s"PreemUI PreemPopup:: \(evt.GetTarget().GetName())");
	// }

    public func GetSize() -> Vector2{
        return this.m_container.GetSize();
    }

    public func SetModContent(grid: ref<PreemGrid>) -> Void
    {
       this.m_preemGrid = grid;
       this.m_preemGrid.Reparent(this.m_preemContent);
       this.RegisterListener(this, n"OnModSelected", n"OnPreemModSelectedCallBack");
    }
    

    public func SetupTooltips(tooltipsManager: wref<gameuiTooltipsManager>)
    {
        this.m_tooltipsManager = tooltipsManager;
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

    protected func UnregisterListener(scriptable: ref<IScriptable>, eventName:CName, methodToCall: CName){

		let widget: ref<inkWidget> = this.m_preemContent.GetWidgetByIndex(0);
		let grid: ref<PreemGrid> = widget.GetController() as PreemGrid;

		if IsDefined(grid) {
			grid.UnregisterFromCallback(eventName,scriptable,methodToCall);
		}
	}

    protected cb func OnGlobalReleaseInput(evt: ref<inkPointerEvent>) -> Void {
		if evt.IsAction(n"cancel") {
            if(IsDefined(this.m_tooltipsManager))
            {
                this.m_tooltipsManager.HideTooltips();
            }

		}

        super.OnGlobalReleaseInput(evt);
	}

}
