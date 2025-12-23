extends Node

enum MergeSource{
	GLOBAL, 
	PRESS, 
	ALT_PRESS, 
	MARKET, 
}

signal item_created(item: Item)

var disabled_containers: Array[ItemContainerResource] = []

var dragged_item_slot: Slot = Empty.slot
var alt_pressed_slot: Slot = Empty.slot
var pressed_slot: Slot = Empty.slot
var hovered_slot: Slot = Empty.slot
var hovered_item: Item = null

var swap_results_to_process: Array[ItemPressResult] = []
var cursor_queued_for_update: bool = false




func _ready() -> void :
	StateManager.state_changed.connect( func(): reset())
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void :
	alt_pressed_slot = Empty.slot
	pressed_slot = Empty.slot
	process_alt_press()
	process_press()

	disabled_containers.clear()



func reset() -> void :
	cursor_queued_for_update = false
	swap_results_to_process.clear()
	dragged_item_slot = Empty.slot
	alt_pressed_slot = Empty.slot
	disabled_containers.clear()
	pressed_slot = Empty.slot
	hovered_slot = Empty.slot
	hovered_item = null




func process_press() -> void :
	if not Input.is_action_just_pressed("press"):
		return

	if disabled_containers.has(hovered_slot.item_container.resource):
		swap_results_to_process.push_back(ItemPressResult.new([], ItemPressResult.Type.DISABLED))
		return


	pressed_slot = hovered_slot

	var dragged_item: Item = null
	var pressed_item: Item = hovered_slot.get_item()

	if is_instance_valid(dragged_item_slot):
		dragged_item = dragged_item_slot.get_item()


	if pressed_slot.item_container.resource == ItemContainerResources.PARTNER:
		return

	if hovered_slot.item_container.resource.is_shop:
		return

	if is_instance_valid(pressed_item):
		if pressed_item.drag_locked:
			swap_results_to_process.push_back(ItemPressResult.new([], ItemPressResult.Type.DISABLED))
			return

	var slots_to_merge: Array[Slot] = get_slots_to_merge(null, hovered_slot, MergeSource.PRESS)
	if slots_to_merge.size():
		merge(slots_to_merge[0], slots_to_merge[1])
		discard_dragged_item()
		return


	if hovered_slot.item_container.resource == ItemContainerResources.EQUIPMENT:
		if not matches_socket(dragged_item_slot, hovered_slot):
			hovered_slot = get_equip_slot(hovered_slot.item_container, dragged_item_slot)
			pressed_item = hovered_slot.get_item()


	if [ItemContainerResources.SELL, ItemContainerResources.SPLIT, ItemContainerResources.TINKER].has(pressed_slot.item_container.resource):
		return


	if is_instance_valid(pressed_item) and not is_instance_valid(dragged_item):
		if not hovered_slot == Empty.slot:
			drag_item(hovered_slot)
			return

	if is_instance_valid(dragged_item_slot):
		if hovered_slot.item_container.resource != ItemContainerResources.BUILD:
			try_to_swap_items(hovered_slot, dragged_item_slot)
		elif dragged_item_slot.item_container.resource == ItemContainerResources.LIBRARY:
			try_to_swap_items(hovered_slot, dragged_item_slot)

	discard_dragged_item()






func process_alt_press() -> void :
	if not Input.is_action_just_pressed("alt_press"):
		return

	var local_player: Player = null
	var curr_state: Node = StateManager.get_current_state()
	if curr_state is GameplayState:
		local_player = curr_state.memory.local_player

	if disabled_containers.has(hovered_slot.item_container.resource):
		swap_results_to_process.push_back(ItemPressResult.new([], ItemPressResult.Type.DISABLED))
		return

	alt_pressed_slot = hovered_slot

	if hovered_slot.item_container.resource == ItemContainerResources.BUILD:
		hovered_slot.item_container.remove_item_at(hovered_slot.index)
		swap_results_to_process.push_back(ItemPressResult.new([], ItemPressResult.Type.SWAP))
		return

	var dragged_item: Item = dragged_item_slot.get_item()
	var pressed_item: Item = hovered_slot.get_item()


	if is_instance_valid(dragged_item):
		pressed_slot = Slot.new(ItemContainer.new(ItemContainerResources.SELL))
		return

	if not is_instance_valid(pressed_item):
		return

	if pressed_item.drag_locked:
		swap_results_to_process.push_back(ItemPressResult.new([], ItemPressResult.Type.DISABLED))
		return

	if hovered_slot.item_container.resource.is_shop:
		return

	if hovered_slot.item_container.resource == ItemContainerResources.INVENTORY:
		if pressed_item.resource.is_essential():
			swap_results_to_process.push_back(ItemPressResult.new([hovered_slot], ItemPressResult.Type.TOGGLE))
			return

		if pressed_item.resource.is_consumable():
			swap_results_to_process.push_back(ItemPressResult.new([hovered_slot], ItemPressResult.Type.CONSUME))
			return


	if pressed_item.is_reforge:
		return


	var slots_to_merge: Array[Slot] = get_slots_to_merge(local_player, hovered_slot, MergeSource.ALT_PRESS)
	if slots_to_merge.size():
		merge(slots_to_merge[0], slots_to_merge[1])
		return


	if disabled_containers.has(ItemContainerResources.EQUIPMENT):
		swap_results_to_process.push_back(ItemPressResult.new([], ItemPressResult.Type.DISABLED))
		return



	if not is_instance_valid(local_player):
		return


	var equipped_item: bool = false
	for index in local_player.equipment.sockets.size():
		var socket: SocketType = local_player.equipment.sockets[index]

		if not pressed_item.resource.socket_type == socket:
			continue

		var swap_slot: Slot = Slot.new()
		if hovered_slot.item_container.resource == ItemContainerResources.INVENTORY:
			swap_slot.item_container = local_player.equipment
			swap_slot.index = index

			if equipped_item and is_instance_valid(swap_slot.get_item()):
				return

		if hovered_slot.item_container.resource == ItemContainerResources.EQUIPMENT:
			swap_slot.index = local_player.inventory.get_first_empty_idx()
			swap_slot.item_container = local_player.inventory

		if try_to_swap_items(hovered_slot, swap_slot):
			equipped_item = true

	if not equipped_item and is_instance_valid(hovered_item.resource.socket_type):
		swap_results_to_process.push_back(ItemPressResult.new([], ItemPressResult.Type.MISSING_SOCKET))







func create_item(item_to_add: ItemResource, spawn_floor: int = 0, rarity: int = 0) -> Item:
	var item: Item = Item.new()
	item.spawn_floor = spawn_floor

	for i in rarity:
		if not item.try_to_increase_rarity():
			break

	item.resource = item_to_add
	if is_instance_valid(item.resource.passive):
		item.reforged_passive = item.resource.passive
		item.reforge_level += 1

	if item_to_add.use_custom_rarity:
		item.set_rarity(item_to_add.custom_rarity)

	item_created.emit(item)
	return item






func create_insightus(floor_number: int) -> Item:
	var item: Item = create_item(Items.INSIGHTUS)
	item.transform_stat = Stats.TRANSFORMED_STATS.pick_random()
	item.spawn_floor = floor_number

	return item



func try_to_swap_items(slot_a: Slot, slot_b: Slot) -> bool:
	if slot_a.item_container.resource == ItemContainerResources.LOOT_STASH:
		if not slot_b.item_container.resource == ItemContainerResources.LOOT_STASH:
			if is_instance_valid(slot_b.get_item()):
				return false

	if slot_b.item_container.resource == ItemContainerResources.LOOT_STASH:
		if not slot_a.item_container.resource == ItemContainerResources.LOOT_STASH:
			if is_instance_valid(slot_a.get_item()):
				return false


	var swap_result = ItemPressResult.new([], can_swap(slot_a, slot_b))
	swap_results_to_process.push_back(swap_result)

	if swap_result.type == ItemPressResult.Type.SWAP:
		swap_result.slots = [slot_a, slot_b] as Array[Slot]
		swap_items(slot_a, slot_b)
		return true

	return false





func merge(slot_a: Slot, slot_to_remove: Slot) -> void :
	var curr_state: Node = StateManager.get_current_state()
	var player: Player = null

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	player = curr_state.memory.local_player

	var item_to_remove: Item = slot_to_remove.get_item()
	var main_item: Item = slot_a.get_item()

	var divine_merge: bool = item_to_remove.rarity == ItemRarity.Type.DIVINE
	if item_to_remove.is_reforge or main_item.is_reforge:
		divine_merge = false

	slot_a.item_container.merge_items(slot_a.index, item_to_remove, curr_state.memory)


	if divine_merge:
		curr_state.character_manager.add_diamonds(player, 1)
		var item_slot: ItemSlot = curr_state.canvas_layer.get_item_slot(slot_a)
		if is_instance_valid(item_slot):
			curr_state.canvas_layer.vfx_manager.create_small_popup_label(
				item_slot.global_position, 
				"+1", 
				Stats.DIAMOND.color, 
				Stats.DIAMOND.icon, 
				)


	slot_to_remove.remove_item()

	swap_results_to_process.push_back(ItemPressResult.new([slot_a, slot_to_remove], ItemPressResult.Type.MERGE))




func get_slots_to_merge(character: Character, check_slot, merge_source: MergeSource) -> Array[Slot]:
	if not is_instance_valid(check_slot):
		return []

	check_slot = check_slot as Slot

	if [MergeSource.PRESS, MergeSource.GLOBAL].has(merge_source):
		if is_instance_valid(dragged_item_slot):
			if can_merge(check_slot, dragged_item_slot) or can_merge(dragged_item_slot, check_slot):
				return [check_slot, dragged_item_slot]


	if [MergeSource.ALT_PRESS, MergeSource.GLOBAL].has(merge_source):
		if [ItemContainerResources.INVENTORY, ItemContainerResources.LOOT_STASH].has(check_slot.item_container.resource):
			if disabled_containers.has(check_slot.item_container.resource):
				return []

			for slot in character.get_all_equipment_slots():
				if can_merge(slot, check_slot):
					return [slot, check_slot]

			for slot in character.get_all_inventory_slots():
				var can_loot_stash_merge: bool = check_slot.item_container.resource == ItemContainerResources.LOOT_STASH and can_merge(slot, check_slot)
				if is_instance_valid(slot.get_item()) and slot.get_item().is_reforge:
					continue

				if can_merge(check_slot, slot) or can_loot_stash_merge:
					return [check_slot, slot]


	if [MergeSource.MARKET, MergeSource.GLOBAL].has(merge_source):
		var slots: Array[Slot] = character.get_all_equipment_slots() + character.get_all_inventory_slots()
		if character.inventory.is_full():
			slots = character.get_all_item_slots()

		for player_slot in slots:
			if can_merge(player_slot, check_slot):
				return [player_slot, check_slot]


	return []




func drag_item(item_to_drag: Slot):
	cursor_queued_for_update = true
	dragged_item_slot = item_to_drag
	UIManager.update_partner_containers()


func discard_dragged_item():
	cursor_queued_for_update = true
	dragged_item_slot = Empty.slot
	UIManager.update_partner_containers()





func swap_items(slot_a: Slot, slot_b: Slot) -> void :
	var item_a: Item = slot_a.get_item()
	var item_b: Item = slot_b.get_item()


	if slot_a.item_container.resource == slot_b.item_container.resource and slot_a.index == slot_b.index:
		return

	if not matches_socket(slot_a, slot_b):
		return


	if slot_a.item_container.resource == ItemContainerResources.LIBRARY:
		item_a = Item.new(item_a)

	if slot_b.item_container.resource == ItemContainerResources.LIBRARY:
		item_b = Item.new(item_b)

	if not slot_a.item_container.resource == ItemContainerResources.LIBRARY:
		if slot_a.item_container.resource != ItemContainerResources.BUILD:
			slot_a.remove_item()
		slot_a.item_container.add_item_at(slot_a.index, item_b)

	if not slot_b.item_container.resource == ItemContainerResources.LIBRARY:
		if slot_b.item_container.resource != ItemContainerResources.BUILD:
			slot_b.remove_item()
		slot_b.item_container.add_item_at(slot_b.index, item_a)






func matches_socket(slot_a: Slot, slot_b: Slot) -> bool:
	var indexed_items: Array[Slot] = [slot_a, slot_b]
	var item_a: Item = slot_a.get_item()
	var item_b: Item = slot_b.get_item()
	var items_to_swap: Array[Item] = [item_a, item_b]


	for idx in range(0, 2):
		var indexed_item: Slot = indexed_items[idx]

		if not is_instance_valid(indexed_item.item_container):
			return false

		if indexed_item.item_container.resource == ItemContainerResources.EQUIPMENT:

			var item_swapped_with: Item = items_to_swap[wrap(idx + 1, 0, 2)]

			if is_instance_valid(item_swapped_with):
				var socket: SocketType = null

				if indexed_item.item_container.sockets.size() > indexed_item.index:
					socket = indexed_item.item_container.sockets[indexed_item.index]


				if is_instance_valid(socket) and not item_swapped_with.resource.socket_type == socket:
					return false


	return true









func can_merge(slot_a: Slot, removed_slot: Slot) -> bool:
	var item_a: Item = slot_a.get_item()
	var removed_item: Item = removed_slot.get_item()

	if not is_instance_valid(removed_item) or not is_instance_valid(item_a):
		return false

	if not Item.is_compatible(item_a, removed_item):
		return false

	if slot_a.item_container.resource == ItemContainerResources.LOOT_STASH:
		return false

	if removed_slot.item_container.resource.is_shop and not removed_slot.item_container.resource.merge_on_buy:
		return false

	if removed_item.is_tinker_kit:
		if removed_slot.item_container.resource.is_shop and not removed_slot.item_container.resource.merge_on_buy:
			return false

	if not [slot_a.item_container.resource, removed_slot.item_container.resource].has(ItemContainerResources.INVENTORY):
		if not [slot_a.item_container.resource, removed_slot.item_container.resource].has(ItemContainerResources.EQUIPMENT):
			return false


	return true






func get_rand_weight(item_resource: ItemResource, floor_number: int) -> float:
	var item_weight: float = pow(item_resource.get_price(), 0.75)
	var rand_weight: float = Math.bell(item_weight, floor_number)
	var weight_reduction: float = 1.0

	return rand_weight / weight_reduction




func sort_by_rarity(item_a: Item, item_b: Item):
	if not is_instance_valid(item_a):
		return false

	if not is_instance_valid(item_b):
		return false

	if item_a.rarity <= item_b.rarity:
		return true
	return false








func get_rand_item_from_gold(item_content: Array[ItemResource], amount: int) -> Item:
	var pool: Array[ItemResource] = []

	for item_resource in item_content:
		if item_resource.get_price() <= amount:
			pool.push_back(item_resource)

	if not pool.size():
		return null

	var chosen_item_resource: ItemResource = pool.pick_random()
	var chosen_rarity: int = 0

	for rarity in ItemRarity.Type.size():
		if chosen_item_resource.calculate_price(rarity) <= amount:
			chosen_rarity = rarity
			continue
		break

	var rand_item: Item = create_item(chosen_item_resource, chosen_rarity)

	return rand_item






func pick_random_item_resource(item_pool: Array[ItemResource], floor_number: int) -> ItemResource:
	var chosen_item: ItemResource = null
	var rand = RandomNumberGenerator.new()

	var weight_pool: PackedFloat32Array
	for item in item_pool:
		var weight: float = get_rand_weight(item, floor_number)
		weight_pool.push_back(weight)

	chosen_item = item_pool[rand.rand_weighted(weight_pool)]


	return chosen_item






func get_equip_slot(equipment: ItemContainer, dragged_slot: Slot) -> Slot:
	var dragged_item: Item = dragged_slot.get_item()
	var equip_slot = Slot.new(equipment)

	for index in equipment.sockets.size():
		var socket = equipment.sockets[index]

		if not dragged_item.resource.socket_type == socket:
			continue

		equip_slot.index = index

		if is_instance_valid(equip_slot.get_item()):
			continue

		break


	return equip_slot










func can_swap(slot_a: Slot, slot_b: Slot) -> ItemPressResult.Type:
	var result: ItemPressResult.Type = ItemPressResult.Type.SWAP
	if [slot_a.index, slot_b.index].has(-1):
		return ItemPressResult.Type.NULL

	if [slot_a, slot_b].has(null):
		return ItemPressResult.Type.NULL


	var equipment_slot: Slot = Empty.slot

	if slot_a.item_container.resource == ItemContainerResources.EQUIPMENT:
		equipment_slot = slot_a

	if slot_b.item_container.resource == ItemContainerResources.EQUIPMENT:
		equipment_slot = slot_b


	if not equipment_slot == Empty.slot:
		var item_a: Item = slot_a.get_item()
		var item_b: Item = slot_b.get_item()



		for idx in equipment_slot.item_container.items.size():
			var item: Item = equipment_slot.item_container.items[idx]

			if not is_instance_valid(item):
				continue

			if equipment_slot.index == idx:
				continue

			if equipment_slot.item_container.sockets.count(item.resource.socket_type) == 1:
				continue

			if not equipment_slot == slot_a:
				if is_instance_valid(item_a):
					if item_a.resource == item.resource:
						return ItemPressResult.Type.HAS_DUPLICATES

			if not equipment_slot == slot_b:
				if is_instance_valid(item_b):
					if item_b.resource == item.resource:
						return ItemPressResult.Type.HAS_DUPLICATES



		if is_instance_valid(item_a):
			if item_a.is_phantom or item_a.is_reforge:
				return ItemPressResult.Type.NULL

		if is_instance_valid(item_b):
			if item_b.is_phantom or item_b.is_reforge:
				return ItemPressResult.Type.NULL


	return result
