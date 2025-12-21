class_name BuildPlannerContainer extends MarginContainer


@export var build_container: DynamicSlotContainer

@export var delete_build_button: LabelButton
@export var selected_build_label: GenericLabel

@export var last_page_button: GenericButton
@export var next_page_button: GenericButton





func _ready() -> void :
	UserData.profile.selected_build_idx_changed.connect( func():
		update_item_slots()
		)


	next_page_button.pressed.connect( func():
		UserData.profile.fix_builds()

		if UserData.profile.builds.size() - 1 < UserData.profile.selected_build_idx + 1:
			UserData.profile.builds.push_back(ItemContainer.new(ItemContainerResources.BUILD, ItemContainerResources.BUILD.size))

		UserData.profile.set_selected_build_idx(mini(UserData.profile.selected_build_idx + 1, UserData.profile.builds.size()))
		)


	last_page_button.pressed.connect( func():
		UserData.profile.set_selected_build_idx(UserData.profile.selected_build_idx - 1)
		UserData.profile.fix_builds()
		)


	build_container.update_slots(0)






func _process(_delta: float) -> void :
	if delete_build_button.is_pressed:
		UserData.profile.get_selected_build().clear()
		UserData.profile.fix_builds()
		update_item_slots()
		return

	selected_build_label.text = "BUILD " + str(UserData.profile.selected_build_idx + 1)

	process_page_arrow_buttons()
	process_item_manager()




func process_page_arrow_buttons() -> void :
	next_page_button.disabled = false
	last_page_button.disabled = false


	if UserData.profile.get_selected_build().get_items().size() == 0:
		next_page_button.disabled = true

	if UserData.profile.selected_build_idx <= 0:
		last_page_button.disabled = true








func process_item_manager() -> void :
	for swap_result_to_process in ItemManager.swap_results_to_process:
		if not is_instance_valid(swap_result_to_process):
			continue

		if ItemPressResult.SUCCESS_TYPES.has(swap_result_to_process.type):
			update_item_slots()




func update_item_slots() -> void :
	for idx in build_container.get_child_count():
		var build: ItemContainer = UserData.profile.get_selected_build()
		var item_texture_rect: ItemSlot = build_container.get_child(idx)
		var dragged_item = ItemManager.dragged_item_slot

		var item: Item = build.items[idx]

		if is_instance_valid(dragged_item) and not Platform.is_mobile():
			if dragged_item.item_container.resource == build.resource and idx == dragged_item.index:
				item = null

		item_texture_rect.update(item)
