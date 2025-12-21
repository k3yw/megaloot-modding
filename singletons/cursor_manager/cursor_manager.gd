extends Node

@export var fake_cursor_texture_rect: FakeCursorTextureRect

@export var main_sub_viewport: SubViewport
@export var hover_sub_viewport: SubViewport

@export var main_cursor_texture_rect: TextureRect
@export var hover_cursor_texture_rect: TextureRect

@export var main_item_texture_rect: TextureRect
@export var hover_item_texture_rect: TextureRect



func _ready() -> void :
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void :
	process_cursor()
	process_cursor_update()



func process_cursor_update() -> void :
	if not ItemManager.cursor_queued_for_update:
		return

	ItemManager.cursor_queued_for_update = false
	CursorManager.update_cursor()




func process_cursor():
	var curr_state = StateManager.get_current_state()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if StateManager.is_busy():
		return


	for pressable in get_tree().get_nodes_in_group("pressable"):
		if not UI.is_hovered(pressable):
			continue
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		return


	for line_edit in NodeManager.generic_line_edits:
		if not is_instance_valid(line_edit):
			continue

		if line_edit.hovering:
			Input.set_default_cursor_shape(Input.CURSOR_IBEAM)
			return


	for generic_button in NodeManager.generic_buttons:
		if not is_instance_valid(generic_button):
			continue

		if generic_button.disabled:
			continue

		if generic_button.hovering:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return


	for tab_button in NodeManager.tab_buttons:
		if not is_instance_valid(tab_button):
			continue

		if tab_button.is_pressed:
			continue

		if tab_button.hovering:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return


	for generic_toggle_button in NodeManager.generic_toggle_buttons:
		if UI.is_hovered(generic_toggle_button) and not generic_toggle_button.disabled:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return


	for generic_drop_down in NodeManager.generic_drop_downs:
		if UI.is_hovered(generic_drop_down):
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return

	for generic_drop_down_selection in NodeManager.generic_drop_down_selections:
		if UI.is_hovered(generic_drop_down_selection):
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return


	for icon_button in get_tree().get_nodes_in_group("icon_button"):
		icon_button = icon_button as IconButton
		if icon_button.hovering and not icon_button.locked:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return




	for close_button in NodeManager.close_buttons:
		if close_button.hovering:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return


		for node_container in NodeManager.adventurer_tree_nodes:
			if UI.is_hovered(node_container):
				Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
				return





	if curr_state is MemorySelectionState:
		for child in curr_state.memory_slot_holder.get_children():
			if child is MemorySlotContainer:
				if child.hovering:
					Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
					return


		for child in curr_state.lobby_holder.get_children():
			if child is LobbyContainer:
				if is_instance_valid(curr_state.selected_lobby_container):
					if curr_state.selected_lobby_container.lobby_name == child.lobby_name:
						continue

				if child.hovering:
					Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
					return


	if curr_state is GameplayState:
		var hovered_slot: Slot = curr_state.get_hovered_slot()
		var hovered_item: Item = hovered_slot.get_item()

		var dragged_slot: Slot = ItemManager.dragged_item_slot
		var dragged_item: Item = dragged_slot.get_item()

		for idx in curr_state.memory.partners.size():
			for partner_container_holder in [curr_state.room_screen.partner_container_holder]:
				var parter_container: PartnerContainer = partner_container_holder.get_child(idx)
				if UI.is_hovered(parter_container):
					Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
					return

		if curr_state.hovering_enemy_container:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return

		if curr_state.canvas_layer.room_screen.battle_speed_container.hovering:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return


		if curr_state.hovering_enemy_container:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return


		if is_instance_valid(hovered_item) and is_instance_valid(dragged_item):
			if dragged_slot.item_container.resource == hovered_slot.item_container.resource:
				if dragged_slot.index == hovered_slot.index:
					return

			if [ItemContainerResources.MARKET, ItemContainerResources.MERCHANT].has(hovered_slot.item_container.resource):
				if is_instance_valid(dragged_item):
					return

				if not curr_state.market_manager.can_buy_item(hovered_slot.item_container, hovered_slot.index):
					return

			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return



	for tab_button in NodeManager.tab_buttons:
		if not is_instance_valid(tab_button):
			continue

		if not tab_button.is_pressed:
			continue

		if UI.is_hovered(tab_button):
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			return





func get_textures(scale: int, saturation: float = 1.0) -> Array[ImageTexture]:
	var scaled_image_size: Vector2i = main_sub_viewport.size * scale

	(hover_item_texture_rect.material as ShaderMaterial).set_shader_parameter("saturation", saturation)
	(main_item_texture_rect.material as ShaderMaterial).set_shader_parameter("saturation", saturation)

	await RenderingServer.frame_post_draw

	var i_beam_image: Image = preload("res://assets/textures/ui/cursor_i_beam.png").get_image()
	var main_image: Image = main_sub_viewport.get_texture().get_image()
	var hover_image: Image = hover_sub_viewport.get_texture().get_image()


	main_image.resize(scaled_image_size.x, scaled_image_size.y, Image.INTERPOLATE_NEAREST)
	hover_image.resize(scaled_image_size.x, scaled_image_size.y, Image.INTERPOLATE_NEAREST)
	i_beam_image.resize(scaled_image_size.x, scaled_image_size.y, Image.INTERPOLATE_NEAREST)


	var final_main_texture: ImageTexture = ImageTexture.create_from_image(main_image)
	var final_hover_texture: ImageTexture = ImageTexture.create_from_image(hover_image)
	var i_beam_texture = ImageTexture.create_from_image(i_beam_image)


	return [final_main_texture, final_hover_texture, i_beam_texture]




func get_pixel_scale() -> int:
	var res_difference: Vector2 = get_window().size / Options.BASE_RESOLUTION
	var pixel_scale: int = maxi(1, mini(ceili((res_difference).x), ceili((res_difference).y)))
	return pixel_scale



func update_cursor() -> void :
	var pixel_scale: int = get_pixel_scale()
	var saturation: float = 1.0

	hover_item_texture_rect.hide()
	main_item_texture_rect.hide()


	var item: Item = ItemManager.dragged_item_slot.get_item()
	if ItemUtils.is_valid(item):
		if item.resource.is_essential() and not item.get_remaining_uses():
			saturation = 0.0

		var item_texture: Texture2D = item.get_texture()
		hover_item_texture_rect.texture = item_texture
		main_item_texture_rect.texture = item_texture
		hover_item_texture_rect.show()
		main_item_texture_rect.show()



	var textures = await get_textures(pixel_scale, saturation)
	if not textures.size():
		return

	Input.set_custom_mouse_cursor(textures[1], Input.CURSOR_POINTING_HAND, Vector2(16, 16) * pixel_scale)
	Input.set_custom_mouse_cursor(textures[2], Input.CURSOR_IBEAM, Vector2(16, 16) * pixel_scale)
	Input.set_custom_mouse_cursor(textures[0], Input.CURSOR_ARROW, Vector2(16, 16) * pixel_scale)


	match Input.get_current_cursor_shape():
		Input.CURSOR_POINTING_HAND: fake_cursor_texture_rect.pointing_hand_texture = textures[1]
		Input.CURSOR_ARROW: fake_cursor_texture_rect.arrow_texture = textures[0]
