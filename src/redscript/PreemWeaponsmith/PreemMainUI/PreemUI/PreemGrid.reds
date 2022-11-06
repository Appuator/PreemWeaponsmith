module PreemCrafting.PreemUI
import PreemCrafting.Codeware.UI.*
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.ModSlotManager.*

public class PreemGrid extends BasePreemGrid {

    public static func Create(size: Vector2,layout: Vector2) -> ref<PreemGrid>
    {
        let self: ref<PreemGrid> = new PreemGrid();
        self.SetSize(size);
        self.SetLayout(layout);
		self.CreateInstance();
		return self;
    }

    public cb func OnSlotClickedCallBack(widget: wref<inkWidget>) -> Bool
	{
		this.CallCustomCallback(n"OnPreemSlotClicked");
	}

    public cb func OnModSelectedCallBack(widget: wref<inkWidget>) -> Bool
	{
		//LogChannel(n"DEBUG", s"PreemUI PreemGrid::\(this.selectedMod)");
		this.CallCustomCallback(n"OnPreemModSelected");
	}

    public cb func OnInitialize(){
		this.RegisterToCallback(n"OnSlotClicked", this, n"OnSlotClickedCallBack");
        this.RegisterToCallback(n"OnModSelected", this, n"OnModSelectedCallBack");
	}

}