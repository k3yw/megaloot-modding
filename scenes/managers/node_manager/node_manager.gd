extends Node



var labels: Array[GenericLabel] = []
var tab_buttons: Array[TabButton] = []
var market_slots: Array[MarketSlot] = []
var close_buttons: Array[CloseButton] = []
var generic_buttons: Array[GenericButton] = []
var enemy_containers: Array[EnemyContainer] = []
var generic_h_sliders: Array[GenericHSlider] = []
var item_texture_rects: Array[ItemTextureRect] = []
var generic_drop_downs: Array[GenericDropDown] = []
var generic_line_edits: Array[GenericLineEdit] = []
var stat_label_containers: Array[StatLabelContiner] = []
var generic_v_scroll_bars: Array[GenericVScrollBar] = []
var adventurer_tree_nodes: Array[AdventurerTreeNode] = []
var generic_toggle_buttons: Array[GenericToggleButton] = []
var memory_slot_containers: Array[MemorySlotContainer] = []
var generic_drop_down_selections: Array[GenericDropDownSelection] = []

var main_canvas_layer: MainCanvasLayer = null
var library_state: LibraryState = null





func _init() -> void :
	tree_entered.connect(
		func(): get_tree().node_added.connect( func(node: Node): process_new_child(node))
	)



func process_new_child(child: Node) -> void :
	if child is GenericLabel:
		child.tree_exiting.connect( func(): labels.erase(child))
		labels.push_back(child)

	if child is GenericButton:
		child.tree_exiting.connect( func(): generic_buttons.erase(child))
		generic_buttons.push_back(child)

	if child is GenericHSlider:
		child.tree_exiting.connect( func(): generic_h_sliders.erase(child))
		generic_h_sliders.push_back(child)

	if child is GenericToggleButton:
		child.tree_exiting.connect( func(): generic_toggle_buttons.erase(child))
		generic_toggle_buttons.push_back(child)

	if child is MemorySlotContainer:
		child.tree_exiting.connect( func(): memory_slot_containers.erase(child))
		memory_slot_containers.push_back(child)

	if child is AdventurerTreeNode:
		child.tree_exiting.connect( func(): adventurer_tree_nodes.erase(child))
		adventurer_tree_nodes.push_back(child)

	if child is EnemyContainer:
		child.tree_exiting.connect( func(): enemy_containers.erase(child))
		enemy_containers.push_back(child)

	if child is GenericVScrollBar:
		child.tree_exiting.connect( func(): generic_v_scroll_bars.erase(child))
		generic_v_scroll_bars.push_back(child)

	if child is MarketSlot:
		child.tree_exiting.connect( func(): market_slots.erase(child))
		market_slots.push_back(child)

	if child is ItemTextureRect:
		child.tree_exiting.connect( func(): item_texture_rects.erase(child))
		item_texture_rects.push_back(child)

	if child is GenericDropDown:
		child.tree_exiting.connect( func(): generic_drop_downs.erase(child))
		generic_drop_downs.push_back(child)

	if child is GenericLineEdit:
		child.tree_exiting.connect( func(): generic_line_edits.erase(child))
		generic_line_edits.push_back(child)

	if child is GenericDropDownSelection:
		child.tree_exiting.connect( func(): generic_drop_down_selections.erase(child))
		generic_drop_down_selections.push_back(child)

	if child is StatLabelContiner:
		child.tree_exiting.connect( func(): stat_label_containers.erase(child))
		stat_label_containers.push_back(child)

	if child is TabButton:
		child.tree_exiting.connect( func(): tab_buttons.erase(child))
		tab_buttons.push_back(child)

	if child is CloseButton:
		child.tree_exiting.connect( func(): close_buttons.erase(child))
		close_buttons.push_back(child)

	if child is MainCanvasLayer:
		child.tree_exiting.connect( func(): main_canvas_layer = null)
		main_canvas_layer = child

	if child is LibraryState:
		child.tree_exiting.connect( func(): library_state = null)
		library_state = child
