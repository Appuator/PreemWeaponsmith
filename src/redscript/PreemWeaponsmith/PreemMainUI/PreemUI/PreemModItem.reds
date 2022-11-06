module PreemCrafting.PreemUI
import PreemCrafting.Codeware.UI.*
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModSlotManager.*

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

	protected cb func OnInitialize(){
		this.RegisterListener(this,n"OnBtnClick",n"OnClick");
	}

	public static func Create() -> ref<PreemModItem>
    {
        let self: ref<PreemModItem> = new PreemModItem();
		self.CreateInstance();
		return self;
    }
	
}