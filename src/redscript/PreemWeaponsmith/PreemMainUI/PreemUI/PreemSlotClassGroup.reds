module PreemCrafting.PreemUI
import PreemCrafting.Codeware.UI.*
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModSlotManager.*

public class PreemSlotClassGroup extends BasePreemSlotClassGroup {

    public let preemModSlotManager: ref<PreemModSlotManager>;

    protected let _preemSlotClass: PreemModClassType;

    public static func Create() -> ref<PreemSlotClassGroup>
    {
        let self: ref<PreemSlotClassGroup> = new PreemSlotClassGroup();
		self.CreateInstance();
		return self;
    }

    public func SetCurrentOrientation(orientation: SlotClassGroupOrientation){
        this.SetOrientation(orientation);
    }

    public func SetClassLabel(className: String){
        this.m_lblClass.SetText(className);
    }

    public func AddSlot(slot: ref<PreemModSlot>)
    {   
        this.AddModSlot(slot, this.m_currentOrientation);
    }

    protected cb func OnInitialize(){
		this.SetListener(n"OnBtnClick",n"OnSlotClick");
	}

    protected func GetSlotFromName(slotName: CName) -> ref<PreemModSlot>
    {
        let slot: ref<PreemModSlot>;
		if(Equals(this.m_currentOrientation, SlotClassGroupOrientation.Horizontal))
		{
            let childIndex: Int32 = 0;
		    let numChildren: Int32 = this.m_slotRowH.GetNumChildren();

            while childIndex < numChildren {
                let widget: ref<inkWidget> = this.m_slotRowH.GetWidgetByIndex(childIndex);
                let modSlot = widget.GetController() as PreemModSlot;
                if(Equals(modSlot.GetName(),slotName))
                {
                    slot = modSlot;
                    break;
                }

                childIndex += 1;
            }

			return slot;
		}
		else
        {
			let childIndex: Int32 = 0;
		    let numChildren: Int32 = this.m_slotRowV.GetNumChildren();

            while childIndex < numChildren {
                let widget: ref<inkWidget> = this.m_slotRowV.GetWidgetByIndex(childIndex);
                let modSlot  = widget.GetController() as PreemModSlot;
                if(Equals(modSlot.GetName(),slotName))
                {
                    slot = modSlot;
                    break;
                }

                childIndex += 1;
            }
            
			return slot;
		}  
    }

    protected cb func OnSlotClick(widget: wref<inkWidget>) -> Bool {
        LogChannel(n"DEBUG", s"PreemUI ClassGroup::\(widget.GetName())");
        let slot = this.GetSlotFromName(widget.GetName());
        LogChannel(n"DEBUG", s"PreemUI ClassGroup::\(slot.GetName())");
		this.preemModSlotManager.SetCurrentlySelectedPreemSlot(slot);
        LogChannel(n"DEBUG", s"PreemUI ClassGroup::\(this.preemModSlotManager.GetCurrentlySelectedPreemSlot().GetName())");
		this.Trigger(n"OnSlotClicked");
	}
    
}