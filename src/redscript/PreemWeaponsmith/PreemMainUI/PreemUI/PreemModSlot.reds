module PreemCrafting.PreemUI
import PreemCrafting.Codeware.UI.*
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModSlotManager.*

public class PreemModSlot extends BasePreemModSlot
{
    public let preemSlotData: ref<PreemSlot>;

    public func SetSlotData(slotData: ref<PreemSlot>) -> Void{
		this.preemSlotData = slotData;
		this.RefreshSlot();
	}

	public func GetSlotData() -> ref<PreemSlot>{
		return this.preemSlotData;
	}

	public func InstallPreemMod(preemMod: ref<PreemMod>)
	{
		this.preemSlotData.slottedMod = preemMod;
		this.RefreshSlot();
	}

	protected func RefreshSlot() -> Void {
		this.SetText(NameToString(this.preemSlotData.GetSlottedMod().GetModName()));
	}

	// protected cb func OnPreemModSlotClick(widget: wref<inkWidget>) -> Bool {
	// 	let button: ref<CustomButton> = widget.GetController() as CustomButton;
	// 	let buttonName: CName = button.GetName();
	// 	LogChannel(n"DEBUG", s"PreemUI Slot::\(buttonName)");

    //     this.m_grid.SetModData(buttonName);
	// 	this.Trigger(n"OnSlotClicked");
	// }

	protected cb func OnInitialize(){
		//this.RegisterListener(this,n"OnBtnClick",n"OnPreemModSlotClick");
	}

	public static func Create() -> ref<PreemModSlot>
    {
        let self: ref<PreemModSlot> = new PreemModSlot();
		self.CreateInstance();
		return self;
    }


}