module PreemCrafting.PreemUI
import PreemCrafting.Core.*
import Codeware.UI.*

public abstract class BasePreemGrid extends inkCustomController {
	protected let m_root: wref<inkFlex>;

	protected let m_container: wref<inkCanvas>;

	protected let m_buttonHints: wref<ButtonHintsEx>;

	protected let m_areaSize: Vector2;

	protected let m_grid: wref<inkVerticalPanel>;

	protected let m_layout: Vector2;

	protected let m_rows: array<wref<inkHorizontalPanel>>;

	protected let m_bg: ref<inkRectangle>;

	protected let m_frame: ref<inkImage>;

	public let selectedMod: CName;

	protected cb func OnCreate() -> Void {
		let workbench: ref<inkFlex> = new inkFlex();
		workbench.SetName(n"workbench");
		workbench.SetAnchor(inkEAnchor.Fill);

		let background: ref<inkRectangle> = new inkRectangle();
		background.SetAnchor(inkEAnchor.Fill);
		background.SetMargin(new inkMargin(8.0, 8.0, 8.0, 8.0));
		background.SetTintColor(ThemeColors.PureBlack());
		background.SetOpacity(0.217);
		this.m_bg = background;
		background.Reparent(workbench);

		let pattern: ref<inkImage> = new inkImage();
		pattern.SetName(n"pattern");
		pattern.SetAtlasResource(r"base\\gameplay\\gui\\fullscreen\\inventory\\atlas_inventory.inkatlas");
		pattern.SetTexturePart(n"BLUEPRINT_3slot");
		pattern.SetBrushTileType(inkBrushTileType.Both);
		pattern.SetTileHAlign(inkEHorizontalAlign.Center);
		pattern.SetTileVAlign(inkEVerticalAlign.Center);
		pattern.SetAnchor(inkEAnchor.Fill);
		pattern.SetOpacity(0.1);
		pattern.SetTintColor(ThemeColors.Bittersweet());
		pattern.SetMargin(new inkMargin(8.0, 4.0, 8.0, 2.0));
		pattern.Reparent(workbench);

		let frame: ref<inkImage> = new inkImage();
		frame.SetName(n"frame");
		frame.SetAtlasResource(r"base\\gameplay\\gui\\fullscreen\\inventory\\inventory4_atlas.inkatlas");
		frame.SetTexturePart(n"itemGridFrame3Big");
		frame.SetNineSliceScale(true);
		frame.SetNineSliceGrid(new inkMargin(24, 24, 24, 24));
		frame.SetAnchor(inkEAnchor.Fill);
		frame.SetOpacity(0.5);
		frame.SetTintColor(ThemeColors.Bittersweet());
		this.m_frame = frame;
		frame.Reparent(workbench);

		let container: ref<inkCanvas> = new inkCanvas();
		container.SetName(n"container");
		container.SetAnchor(inkEAnchor.Fill);
		container.Reparent(workbench);

		let grid: ref<inkVerticalPanel> = new inkVerticalPanel();
		grid.SetName(n"grid");
		grid.SetAnchor(inkEAnchor.Fill);
		grid.SetAnchorPoint(0.5,0.5);
		this.m_grid = grid;

		this.BuildGrid();

		grid.Reparent(workbench);
		this.m_root = workbench;
		this.m_container = container;

		this.SetRootWidget(workbench);
		this.SetContainerWidget(container);
	}

	public func SetOpacity(opacity: Float){
		this.m_bg.SetOpacity(opacity);
		this.m_frame.SetOpacity(opacity);
	}

	public func GetContainer() -> wref<inkCanvas> {
		return this.m_container;
	}


	public func GetHints() -> wref<ButtonHintsEx> {
		return this.m_buttonHints;
	}

	public func GetSize() -> Vector2 {
		return this.m_areaSize;
	}

	public func SetSize(areaSize: Vector2) -> Void {
		this.m_areaSize = areaSize;
	}

	public func SetLayout(layout: Vector2) -> Void {
		this.m_layout = layout;
	}

	public func SetHints(buttonHints: wref<ButtonHintsEx>) -> Void {
		this.m_buttonHints = buttonHints;
	}

	public func SetModData(modData: CName){
        this.selectedMod = modData;
    }
    
	public func AddClassGroup(classGroup: ref<BasePreemSlotClassGroup>, rowIndex: Int32, cellIndex: Int32) -> Void {
		classGroup.Assign(this, rowIndex, cellIndex);
	}

	public func AddModItem(item: ref<BasePreemModItem>, rowIndex: Int32, cellIndex: Int32) -> Void {
		item.Assign(this, rowIndex, cellIndex);
	}

	public func AddRow(rowName: CName)
	{
		let initialRow: ref<inkHorizontalPanel> = new inkHorizontalPanel();
		initialRow.SetName(rowName);
		initialRow.SetFitToContent(true);
		initialRow.SetAnchor(inkEAnchor.CenterFillHorizontaly);
		ArrayPush(this.m_rows, initialRow);

		initialRow.Reparent(this.m_grid);
	}

	public func AddColumn(columnName: CName){

		for row in this.m_rows
		{
			let cell = this.CreateCell(columnName);
			cell.Reparent(row);
		}
	}

	protected func CreateCell(cellName: CName) -> ref<inkCanvas>
	{
		let cell = new inkCanvas();
		cell.SetName(cellName);
		//cell.SetFitToContent(true);
		cell.SetAnchor(inkEAnchor.CenterFillVerticaly);
		cell.SetSize(this.GetCellWidth(),this.GetCellHeight());
		return cell;
	}

	protected func BuildGrid()
	{

		let i = 0;
		let j = 0;
		let rows = FloorF(this.m_layout.X);
		let columns = FloorF(this.m_layout.Y);

		while(i < rows){
			this.AddRow(n"row");
			i += 1;
		}

		while(j < columns){
			this.AddColumn(n"column");
			j += 1;
		}
	}

	public func GetRow(rowIndex: Int32) -> wref<inkCompoundWidget> {

		return this.m_grid.GetWidgetByIndex(rowIndex) as inkCompoundWidget;
	}

	public func GetCell(rowIndex: Int32, cellIndex: Int32) -> wref<inkCompoundWidget> {
		
		let row = this.m_grid.GetWidgetByIndex(rowIndex) as inkCompoundWidget;
		return row.GetWidgetByIndex(cellIndex) as inkCompoundWidget;
	}

	public func GetRowCount() -> Int32{
		return FloorF(this.m_layout.Y);
	}

	public func GetColumnCount() -> Int32{
		return FloorF(this.m_layout.X);
	}

	protected func GetCellWidth() -> Float{
		return (this.m_areaSize.X / (Cast<Float>(this.GetColumnCount())));
	}

	protected func GetCellHeight() -> Float{
		return (this.m_areaSize.Y / (Cast<Float>(this.GetRowCount())));
	}

	public func SetVisible(isVisible: Bool) -> Void
	{
		this.m_root.SetVisible(isVisible);
		this.m_container.SetVisible(isVisible);
	}
}
