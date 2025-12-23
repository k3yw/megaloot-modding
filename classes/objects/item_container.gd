class_name ItemContainer extends Object

enum ItemRemoveCause{
	NULL, 
	BANISHED, 
	MERCHANT_UPGRADED, 
	LEARNED_ABILITY, 
	INSIGHTUS_ACTIVATED, 
	STAT_ADPTED
	}


signal item_updated(item: Item, idx: int)
signal item_added(item: Item, idx: int)
signal item_removing(item: Item)
signal item_removed(idx: int, cause: ItemRemoveCause)

var resource: ItemContainerResource = ItemContainerResource.new()
var challenge_locked_indexes: PackedInt64Array = []
var locked_indexes: PackedInt64Array = []
var modification_order: Array[int] = []
var sockets: Array[SocketType] = []
var items: Array[Item] = []
var infinite: bool = false

@warning_ignore("unused_private_class_variable")
var _owner: Character = null





func _init(arg_resource: ItemContainerResource = ItemContainerResource.new(), size: int = 0) -> void :
	resource = arg_resource

	if size == -1:
		infinite = true
		items.resize(1)
		return

	items.resize(size)

	for idx in size:
		modification_order.push_back(idx)


func sort_items() -> void :
	var groups: Dictionary = {
		"helmet": {}, 
		"chestplate": {}, 
		"leggings": {}, 
		"boots": {}, 
		"necklace": {}, 
		"weapon": {}, 
		"ring": {}, 
		"essential": {}, 
		"consumable": {}
	}

	for item in items:
		if item == null:
			continue

		var item_resource = item.resource
		var item_id: int = Items.LIST.find(item_resource)
		var group_key: String = ""

		if item_resource.is_essential() or item_resource.is_special:
			group_key = "essential"
		if item_resource.is_consumable():
			group_key = "consumable"

		match item_resource.socket_type:
			SocketTypes.HELMET: group_key = "helmet"
			SocketTypes.CHESTPLATE: group_key = "chestplate"
			SocketTypes.LEGGINGS: group_key = "leggings"
			SocketTypes.BOOTS: group_key = "boots"
			SocketTypes.NECKLACE: group_key = "necklace"
			SocketTypes.WEAPON: group_key = "weapon"
			SocketTypes.RING: group_key = "ring"

		if group_key.is_empty():
			continue

		if not groups[group_key].has(item_id):
			groups[group_key][item_id] = []
		groups[group_key][item_id].push_back(item)

	for group in groups.values():
		var sorted_keys: Array = group.keys()
		sorted_keys.sort_custom( func(a, b): return a > b)

		var sorted_group: Dictionary = {}
		for key in sorted_keys:
			sorted_group[key] = group[key]
			group[key].sort_custom( func(a, b): return a.rarity > b.rarity)
		group.clear()
		group.merge(sorted_group)

	var sorted_items: Array[Item] = []
	sorted_items.resize(items.size())
	sorted_items.fill(null)
	var index: int = 0


	for group_key in ["helmet", "chestplate", "leggings", "boots", "necklace", "weapon", "ring"]:
		for items_array in groups[group_key].values():
			for item in items_array:
				if index >= items.size():
					items = sorted_items
					return
				sorted_items[index] = item
				index += 1

	var essential_amount: int = 0
	for items_array in groups["essential"].values():
		essential_amount += items_array.size()

	var consumable_amount: int = 0
	for items_array in groups["consumable"].values():
		consumable_amount += items_array.size()


	var empty_slots: int = 5 - (essential_amount + consumable_amount)
	var essential_start: int = items.size() - essential_amount


	index = essential_start
	for items_array in groups["essential"].values():
		for item in items_array:
			if index >= items.size():
				items = sorted_items
				return
			sorted_items[index] = item
			index += 1


	index = essential_start - consumable_amount
	if not (empty_slots < 1):
		index -= empty_slots

	for items_array in groups["consumable"].values():
		for item in items_array:
			if index >= essential_start:
				items = sorted_items
				return
			sorted_items[index] = item
			index += 1

	for idx in sorted_items.size():
		var item: Item = sorted_items[idx]
		item_updated.emit(item, idx)

	items = sorted_items
	return



func process_modification(idx: int) -> void :
	if infinite:
		return

	var pos: int = modification_order.find(idx)
	modification_order.pop_at(pos)

	modification_order.push_back(idx)



func clear() -> void :
	for idx in items.size():
		items[idx] = null



func try_to_add_item_at(slots: Array[SocketType], idx: int, item: Item) -> bool:
	if resource == ItemContainerResources.EQUIPMENT:
		if not slots[idx] == item.resource.socket_type:
			return false

	process_modification(idx)
	add_item_at(idx, item)
	return true



func try_to_add_item(item: Item) -> bool:
	var idx: int = get_first_empty_idx()
	if idx == -1:
		return false

	process_modification(idx)
	add_item_at(idx, item)
	return true





func add_item_at(idx: int, item: Item) -> void :
	if not items.size() > idx:
		if not infinite:
			return

	if infinite:
		items.resize(maxi(items.size(), idx + 1))

	process_modification(idx)
	items[idx] = item

	item_added.emit(item, idx)



func remove_item_at(idx: int, cause: ItemRemoveCause = ItemRemoveCause.NULL):
	if not items.size() > idx or idx < 0:
		return

	if ItemUtils.is_valid(items[idx]):
		item_removing.emit(items[idx])

	items[idx] = null

	process_modification(idx)

	item_removed.emit(idx, cause)





func merge_items(idx: int, item_to_merge: Item, memory: Memory) -> void :
	if not is_instance_valid(items[idx]):
		return
	var item: Item = items[idx]
	item.merge_with(item_to_merge)
	item_updated.emit(item, idx)





func remove_reforge(idx: int) -> void :
	if not is_instance_valid(items[idx]):
		return

	var item: Item = items[idx]
	item.remove_reforge()

	item_updated.emit(item, idx)



func is_full():
	var full: bool = true

	for item in items:
		if not is_instance_valid(item):
			full = false
			break

	return full



func get_filtered_from_item_set(item_set_resource: ItemSetResource) -> Array[Item]:
	var filtered_items: Array[Item] = []

	for item in ItemUtils.get_valid_items(items):
		if item.get_set_resources().has(item_set_resource):
			filtered_items.push_back(item)

	return filtered_items



func get_items_with_null() -> Array[Item]:
	var items_with_null: Array[Item] = items.duplicate()

	for idx in sockets.size():
		var socket: SocketType = sockets[idx]

		if socket == SocketTypes.REPLICATED_WEAPON:
			for item in items:
				if not is_instance_valid(item):
					continue
				if item.resource.socket_type == SocketTypes.WEAPON:
					items_with_null[idx] = item
					break

	return items_with_null



func get_items() -> Array[Item]:
	return ItemUtils.get_valid_items(get_items_with_null())



func get_item_count() -> int:
	return get_items().size()




func get_last_item_idx() -> int:
	for idx in range(items.size() - 1, -1, -1):
		var item: Item = items[idx]
		if is_instance_valid(item):
			return idx
	return 0



func get_first_empty_idx() -> int:
	for idx in items.size():
		var item: Item = items[idx]

		if not is_instance_valid(item):
			return idx

	if infinite:
		items.push_back(null)
		return items.size() - 1

	return -1



func get_synergy_sets(arg_item: Item) -> Array[ItemSetResource]:
	var synergy_sets: Array[ItemSetResource] = []

	for item in get_items():
		if item == arg_item:
			continue

		for bonus_stat in item.resource.bonus_stats:
			for boosting_set in bonus_stat.boosting_sets:
				if arg_item.resource.set_resources.has(boosting_set):
					if not synergy_sets.has(boosting_set):
						synergy_sets.push_back(boosting_set)

		for bonus_stat in arg_item.resource.bonus_stats:
			for boosting_set in bonus_stat.boosting_sets:
				if item.resource.set_resources.has(boosting_set):
					if not synergy_sets.has(boosting_set):
						synergy_sets.push_back(boosting_set)

	return synergy_sets





func get_active_item_sets() -> Array[ItemSetResource]:
	var active_item_sets: Array[ItemSetResource] = []

	for idx in modification_order:
		if idx > items.size() - 1:
			continue

		var item: Item = items[idx]

		if not is_instance_valid(item):
			continue

		if item.has_burnout():
			continue

		for item_set in item.get_set_resources():
			if item_set == ItemSets.GENERIC:
				continue

			if active_item_sets.has(item_set):
				continue

			active_item_sets.push_back(item_set)

	return active_item_sets





func get_item(idx: int) -> Item:
	if idx == -1:
		return null

	if not items.size() > idx:
		return null

	return items[idx]





func has_duplicates() -> bool:
	var unique_item_resources: Array[ItemResource] = []

	for item in get_items():
		if unique_item_resources.has(item.resource):
			return true

		unique_item_resources.push_back(item.resource)

	return false



func cleanup() -> void :
	for item in items:
		if is_instance_valid(item):
			item.cleanup()
			item.free()
