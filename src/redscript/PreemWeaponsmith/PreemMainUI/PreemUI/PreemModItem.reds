module PreemCrafting.PreemUI
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModSlotManager.*
import Codeware.UI.*

public class PreemModItem extends BasePreemModItem
{

    public let selectedModData: ref<PreemMod>;

	public let preemModSlotManager: ref<PreemModSlotManager>;

    public let selectedMod: CName;

    public func SetModData(modData: ref<PreemMod>) -> Void
    {
		this.selectedModData = modData;
		this.RefreshMod();
	}

	public func GetModData() -> ref<PreemMod>{
		return this.selectedModData;
	}

	protected func RefreshMod() -> Void {
		this.SetText(NameToString(this.selectedModData.GetModName()));
	}

    protected cb func OnClick(widget: wref<inkWidget>) -> Bool {
		//LogChannel(n"DEBUG", s"PreemUI ModItem::\(this.selectedModData.GetModName())");

		this.preemModSlotManager.InstallMod(this.selectedModData);

		this.Trigger(n"OnModSelected");
	}

	protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool
	{
		LogChannel(n"DEBUG", s"PreemUI ModItem::\(this.selectedModData.GetModName())");
		this.preemModSlotManager.SetHoveredPreemMod(this.selectedModData);
	}

	protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Void {LogChannel(n"DEBUG", s"PreemUI ModItem::\(this.selectedModData.GetModName())");}

	protected cb func OnInitialize(){
		this.RegisterListener(this,n"OnBtnClick",n"OnClick");
		this.RegisterListener(this, n"OnHoverOver", n"OnHoverOver");
    	this.RegisterListener(this, n"OnHoverOut", n"OnHoverOut");
	}

	protected cb func OnUninitialize(){
		this.UnregisterFromCallback(n"OnBtnClick", this,n"OnClick");
		this.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOver");
    	this.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOut");
	}

	public static func Create() -> ref<PreemModItem>
    {
        let self: ref<PreemModItem> = new PreemModItem();
		self.CreateInstance();
		return self;
    }
	
}