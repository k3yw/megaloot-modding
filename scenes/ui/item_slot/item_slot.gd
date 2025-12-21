class_name ItemSlot extends TextureRect


@export var item_container_resource: ItemContainerResource
@export var item_texture_container: CenterContainer



func _ready() -> void :
	if is_instance_valid(item_container_resource):
		add_to_group(get_group_name(item_container_resource))


static func get_group_name(arg_item_container_resource: ItemContainerResource) -> String:
	return "item_slot_" + arg_item_container_resource.get_own_name()


func update(item: Item, inside_canvas_group: bool = false) -> void :
	if not is_in_group("visible_by_joypad"):
		add_to_group("visible_by_joypad")

	if not is_instance_valid(item):
		(material as ShaderMaterial).set_shader_parameter("alpha", 1.0)
		if item_texture_container.get_child_count():
			var child: Node = item_texture_container.get_child(0)
			item_texture_container.remove_child(child)
			child.queue_free()
		return


	var item_texture_rect_data = ItemTextureRectData.new()
	item_texture_rect_data.slot_reference = self
	item_texture_rect_data.item = item


	if item_texture_container.get_child_count():
		var item_texture_rect: ItemTextureRect = (item_texture_container.get_child(0) as ItemTextureRect)
		item_texture_rect.apply_data(item_texture_rect_data)
		item_texture_rect.upgrade_mark_texture_rect.hide()
		
		item_texture_rect.build_planner_match_texture_rect.hide()
		for build_item in UserData.profile.get_selected_build().get_items():
			if not build_item.resource == item.resource:
				continue
			item_texture_rect.build_planner_match_texture_rect.show()
		return
	
	

	var item_texture_rect = preload("res://scenes/ui/item_texture_rect/item_texture_rect.tscn").instantiate()
	item_texture_container.add_child(item_texture_rect)

	remove_from_group("visible_by_joypad")

	item_texture_rect.tree_exiting.connect( func():
		if InputMode.get_active_type() == InputMode.Type.JOYPAD:
			UI.hovered_node = self
		)

	if inside_canvas_group:
		item_texture_rect.set_as_multiply()

	item_texture_rect.apply_data(item_texture_rect_data)
	(material as ShaderMaterial).set_shader_parameter("alpha", 0.0)
	item_texture_rect.upgrade_mark_texture_rect.hide()




func get_rects() -> Array[Control]:
	if has_item_texture():
		return [self, get_item_texture_rect()]
	return [self]


func get_hovered_rect() -> Control:
	if has_item_texture():
		var item_texture_rect: ItemTextureRect = get_item_texture_rect()
		if item_texture_rect.hovering:
			return item_texture_rect

	if UI.is_hovered(self):
		return self

	return null


func is_hovered() -> bool:
	if is_instance_valid(get_hovered_rect()):
		return true

	return false



func get_item_texture_rect() -> ItemTextureRect:
	if item_texture_container.get_child_count() == 0:
		return null

	return item_texture_container.get_child(0) as ItemTextureRect


func has_item_texture() -> bool:
	return item_texture_container.get_child_count() > 0
