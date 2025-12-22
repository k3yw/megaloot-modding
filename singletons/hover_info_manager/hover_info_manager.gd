extends Node



@export var hover_info_holder: CanvasLayer
var hover_info_lock_time: float = 0.75




func _ready() -> void :
	PopupManager.popup_shown.connect(_on_popup_shown)
	StateManager.state_changed.connect( func():
			var curr_state: Node = StateManager.get_current_state()
			if curr_state is GameplayState:
				curr_state.gameplay_covered_changed.connect( func(): _clear_all())
			)

	process_mode = ProcessMode.PROCESS_MODE_ALWAYS




func _process(_delta: float) -> void :
	var curr_state: Node = StateManager.get_current_state()
	var hovered_node: Node = get_hovered_node(curr_state)

	if StateManager.screen_transition.animation_player.is_playing():
		hovered_node = null

	process_hovered_node(curr_state, hovered_node)



func _on_popup_shown() -> void :
	_clear_all()






func process_hovered_node(curr_state: Node, hovered_node: Node) -> void :
	var to_update: bool = false

	if curr_state is GameplayState:
		if curr_state.hover_info_update_request == true:
			curr_state.hover_info_update_request = false
			to_update = true

		if hovered_node is PingTextureRect:
			to_update = true


	if to_update and is_dynamic(hovered_node):
		var hover_info: HoverInfo = get_first()
		if is_instance_valid(hover_info):
			var data: HoverInfoData = get_hover_info_data(curr_state, hovered_node)

			if is_instance_valid(data):
				hover_info.apply_data(data)
				return


	if not hover_info_holder_working():
		create_hover_info(curr_state)
		return

	if has_new_owner(curr_state, hovered_node):
		_clear_all()
		return

	if escaped_last(hovered_node):
		remove_last()
		return


	if not has_hover_info(hovered_node):
		create_hover_info(curr_state)
		return









func get_first() -> HoverInfo:
	for child in hover_info_holder.get_children():
		if child is HoverInfo:
			return child

	return null



func get_all_hover_info():
	var all_hover_info: Array[HoverInfo] = []

	for child in hover_info_holder.get_children():
		if child is HoverInfo:
			all_hover_info.push_back(child)

	return all_hover_info



func hover_info_holder_working() -> bool:
	for hover_info in get_all_hover_info():
		if not hover_info.is_queued_for_deletion() and is_instance_valid(hover_info):
			return true

	return false

var hover_cache_thread_mutex: Mutex
var hover_cache_thread: Thread = null
func _launch_hover_thread():
	hover_cache_thread_mutex = Mutex.new()
	hover_cache_thread = Thread.new()
	hover_cache_thread.start(populate_hover_cache)
	
var hover_info_cache: Array[HoverInfo] = []

const hover_info_cache_size = 64
# determines factor at which cache will be repopulated after certain size is shrinked
const hover_info_cache_size_factor = 16

func populate_hover_cache () -> void:
	while true:
		# we dont care about overshooting so no need to mutex lock this access
		var size = hover_info_cache.size()
		if size <= 0 or (hover_info_cache_size - size) >= hover_info_cache_size_factor:
			var cache = []
			for i in range(size, hover_info_cache_size):
				cache.push_back(preload("res://scenes/ui/hover_info/hover_info.tscn").instantiate())
				await get_tree().create_timer(0.1, true, true, true).timeout
			hover_cache_thread_mutex.lock()
			hover_info_cache.append_array(cache)
			hover_cache_thread_mutex.unlock()
		await get_tree().create_timer(0.2, true, true, true).timeout

func get_hover_cache() -> HoverInfo:
	hover_cache_thread_mutex.lock()
	var ret = hover_info_cache.pop_back()
	hover_cache_thread_mutex.unlock()
	return ret

func create_hover_info(curr_state: Node):
	if hover_cache_thread == null:
		_launch_hover_thread()
	var hovered_node: Node = get_hovered_node(curr_state)
	var hover_info_data: HoverInfoData = get_hover_info_data(curr_state, hovered_node)
	var first_hover_info: HoverInfo = get_first()


	if not is_instance_valid(hover_info_data):
		return

	if is_instance_valid(first_hover_info):
		if NodeUtils.get_all_children(first_hover_info.hover_owner).has(hovered_node):
			return

	hover_info_data.owner = hovered_node
	
	var hover_info: HoverInfo = get_hover_cache()
	if hover_info == null:
		hover_info = preload("res://scenes/ui/hover_info/hover_info.tscn").instantiate()
	hover_info.set_lock_time(hover_info_lock_time)
	hover_info_holder.add_child(hover_info)
	hover_info.apply_data(hover_info_data)

	UI.active_hover_info.push_back(hover_info)



func keep_hover_info(hovered_node: Control) -> bool:
	if not is_instance_valid(hovered_node):
		return false

	for hover_info in get_all_hover_info():

		if hover_info.lock_time_left <= 0:
			if hover_info.data.owner == hovered_node:
				return true

	return false




func has_new_owner(curr_state: Node, hovered_node: Control) -> bool:
	if not is_instance_valid(hovered_node):
		return true

	var all_hover_info = get_all_hover_info()

	for hover_info_idx in all_hover_info.size():
		var hover_info: HoverInfo = all_hover_info[hover_info_idx]

		if not is_instance_valid(hover_info):
			continue

		if not is_instance_valid(hover_info.data):
			return true


		if hover_info.lock_time_left > 0:
			if get_hovered_node(curr_state) == hover_info.data.owner:
				return false

		if hover_info.lock_time_left <= 0 and is_instance_valid(hover_info.data.owner):
			if UI.is_hovered(hover_info.data.owner):
				return false

		if not hover_info_idx:
			if hover_info.lock_time_left > 0:
				return true

		if NodeUtils.get_all_children(hover_info).has(hovered_node):
			return false


	return true




func has_hover_info(hovered_node: Control) -> bool:
	for hover_info in get_all_hover_info():

		if hover_info.data.owner == hovered_node:
			return true

		if hover_info.main_container == hovered_node:
			return true


	return false



func escaped_last(hovered_node: Control) -> bool:
	if not is_instance_valid(hovered_node):
		return true

	var all_hover_info = get_all_hover_info()

	if all_hover_info.size() < 2:
		return false

	var last_hover_info: HoverInfo = all_hover_info.back()
	if not is_instance_valid(last_hover_info.data):
		return true

	if last_hover_info.data.owner == hovered_node:
		return false

	if last_hover_info.lock_time_left > 0:
		return true

	if NodeUtils.get_all_children(last_hover_info).has(hovered_node):
		return false

	return true



func is_dynamic(hovered_node: Control) -> bool:
	var all_hover_info = get_all_hover_info()

	if not all_hover_info.size() == 1:
		return false

	var hover_info: HoverInfo = all_hover_info.front()

	if not is_instance_valid(hover_info):
		return false

	if not is_instance_valid(hover_info.data):
		return false

	if NodeUtils.get_all_children(hover_info).has(hovered_node):
		return false

	return hover_info.data.is_dynamic





func _clear_all() -> void :
	for hover_info in get_all_hover_info():
		hover_info.hide()

		if is_instance_valid(hover_info.data):
			hover_info.data.unreference()

		UI.active_hover_info.erase(hover_info)
		hover_info.queue_free()



func remove_last() -> void :
	var last_hover_info: HoverInfo = get_all_hover_info().back()
	hover_info_holder.remove_child(last_hover_info)

	UI.active_hover_info.erase(last_hover_info)
	if is_instance_valid(last_hover_info.data):
		last_hover_info.data.unreference()
	last_hover_info.queue_free()




func get_hovered_node(curr_state: Node) -> Control:
	var all_hover_info = get_all_hover_info()

	for idx in range(all_hover_info.size() - 1, -1, -1):
		var hover_info: HoverInfo = all_hover_info[idx]

		if UI.is_hovered(hover_info.main_container) and hover_info.lock_time_left <= 0:
			for set_icon in hover_info.set_icon_container.get_children():
				if set_icon is TextureRect:
					if UI.is_hovered(set_icon):
						return set_icon

			if UI.is_hovered(hover_info.cost_container):
				return hover_info.cost_container

			for bb_container in hover_info.get_bb_containers():
				if UI.is_hovered(bb_container):
					return bb_container

			return hover_info.main_container



	for upgrade_tinker_token in get_tree().get_nodes_in_group("upgrade_tinker_token"):
		if UI.is_hovered(upgrade_tinker_token):
			return upgrade_tinker_token


	for hover_info_module in get_tree().get_nodes_in_group("hover_info_module"):
		if UI.is_hovered(hover_info_module.get_parent()):
			return hover_info_module.get_parent()


	if is_instance_valid(NodeManager.library_state):
		var items_container: GridContainer = NodeManager.library_state.item_scroll_container.scroll_container.get_child(0).get_child(0)
		var enemies_container: GridContainer = NodeManager.library_state.bestiary_container.enemy_texture_container
		var build_container: DynamicSlotContainer = NodeManager.library_state.build_planner_container.build_container

		for idx in build_container.get_child_count():
			var item_texture_slot: ItemSlot = build_container.get_child(idx)
			var item_texture_rect: ItemTextureRect = item_texture_slot.get_item_texture_rect()

			if not is_instance_valid(item_texture_rect):
				continue

			if item_texture_rect.hovering:
				return item_texture_rect


		for idx in items_container.get_child_count():
			var item_texture_rect: ItemTextureRect = items_container.get_child(idx)
			if item_texture_rect.hovering:
				return item_texture_rect

		for idx in enemies_container.get_child_count():
			var enemy_texture_rect = enemies_container.get_child(idx)
			if UI.is_hovered(enemy_texture_rect):
				return enemy_texture_rect


	if curr_state is MemorySelectionState:
		if curr_state.interact_button.hovering:
			return curr_state.interact_button


	if curr_state is GameplayState:
		var enemies_to_battle: Array[Enemy] = curr_state.memory.get_enemies_to_battle()
		var canvas_layer: GameplayCanvasLayer = curr_state.canvas_layer
		var room_screen: RoomScreen = canvas_layer.room_screen

		if not is_instance_valid(curr_state.memory.local_player):
			return null

		if curr_state.memory.local_player.died:
			return null


		for child in curr_state.canvas_layer.market_popup_container.item_holder.get_children():
			if child is ItemTextureRect:
				if child.hovering:
					return child


		if canvas_layer.loot_stash_button.hovering:
			return canvas_layer.loot_stash_button

		if canvas_layer.chat_button.hovering:
			return canvas_layer.chat_button

		if UI.is_hovered(canvas_layer.difficulty_progress_bar):
			return canvas_layer.difficulty_progress_bar

		if canvas_layer.market_button.hovering:
			return canvas_layer.market_button

		for enemy_idx in enemies_to_battle.size():
			if room_screen.enemy_container_holder.get_child_count() <= enemy_idx:
				continue

			var enemy_container: EnemyContainer = room_screen.enemy_container_holder.get_child(enemy_idx)
			var enemy: Enemy = enemies_to_battle[enemy_idx]

			if not is_instance_valid(enemy):
				continue

			if enemy.out_of_combat:
				continue

			if UI.is_hovered(enemy_container.selection_rect):
				return enemy_container.selection_rect

			if UI.is_hovered(enemy_container.immunity_texture_rect):
				return enemy_container.immunity_texture_rect

			for status_effect_container in enemy_container.effect_container_holder.get_children():
				if UI.is_hovered(status_effect_container):
					return status_effect_container

		for partner_container_holder in [room_screen.partner_container_holder]:
			for partner_container in partner_container_holder.get_children():
				if UI.is_hovered(partner_container):
					return partner_container

		if UI.is_hovered(canvas_layer.adventurer_portrait.set_texture_rect):
			return canvas_layer.adventurer_portrait.set_texture_rect

		if UI.is_hovered(canvas_layer.adventurer_portrait):
			return canvas_layer.adventurer_portrait

		if UI.is_hovered(room_screen.ping_texture_rect):
			return room_screen.ping_texture_rect

		if room_screen.interact_button.hovering:
			return room_screen.interact_button

		for status_effect_container in canvas_layer.health_bar.effect_container_holder.get_children():
			if UI.is_hovered(status_effect_container):
				return status_effect_container


		for status_effect_container in canvas_layer.effect_container_holder.get_children():
			if UI.is_hovered(status_effect_container):
				return status_effect_container

		if UI.is_hovered(canvas_layer.armor_bar):
			return canvas_layer.armor_bar

		if UI.is_hovered(canvas_layer.health_bar):
			return canvas_layer.health_bar

		if UI.is_hovered(canvas_layer.mana_bar):
			return canvas_layer.mana_bar

		if canvas_layer.market_refresh_button.hovering:
			return canvas_layer.market_refresh_button


		for stat in Stats.DISPLAY:
			var stat_label_container: StatLabelContiner = canvas_layer.get_stat_label_container(stat)
			if UI.is_hovered(stat_label_container):
				return stat_label_container


		for container in ItemContainerResources.GAMEPLAY_ITEM_CONTAINERS:
			for item_slot in canvas_layer.get_item_slots(container):
				var hovered_rect: Control = item_slot.get_hovered_rect()
				if is_instance_valid(hovered_rect):
					return hovered_rect


	if curr_state is LobbyState:
		for trial_container in curr_state.get_trial_containers():
			if trial_container.hovering:
				return trial_container



	return null








func get_hover_info_data(curr_state: Node, hovered_node: Control) -> HoverInfoData:
	if not is_instance_valid(hovered_node):
		return null


	var hover_info_module: HoverInfoModule = null
	var hover_info_data: HoverInfoData = null

	if hovered_node.has_node("HoverInfoModule"):
		hover_info_module = hovered_node.get_node("HoverInfoModule") as HoverInfoModule

	if is_instance_valid(hover_info_module):
		hover_info_data = hover_info_module.get_hover_info_data()


	if is_instance_valid(hover_info_data):
		for idx in hover_info_data.bb_container_data_arr.size():
			var bb_container_data: BBContainerData = hover_info_data.bb_container_data_arr[idx]
			if not is_instance_valid(bb_container_data):
				continue

			match bb_container_data.tag:
				BBTags.PING:
					bb_container_data.text = str(Net.ping)


		if hover_info_data.bb_container_data_arr.is_empty():
			return null

		return hover_info_data



	hover_info_data = HoverInfoData.new()





	for hover_info in get_all_hover_info():
		if hovered_node == hover_info.cost_container:
			if is_instance_valid(hover_info.data.cost_type):
				return Info.from_stat_resource(hover_info_data, get_character(curr_state), hover_info.data.cost_type)


		for idx in hover_info.set_icon_container.get_child_count():
			if not is_instance_valid(hover_info.data):
				continue

			if not hover_info.data.item_set_resources.size() - 1 >= idx:
				continue

			var set_icon = hover_info.set_icon_container.get_child(idx)

			if hovered_node == set_icon and set_icon is TextureRect:
				return Info.from_item_set(hover_info_data, get_character(curr_state), hover_info.data.item_set_resources[idx])


		for bb_container in hover_info.get_bb_containers():
			if bb_container == hovered_node:
				hover_info_data = bb_container.get_hover_info(hover_info_data)
				if is_instance_valid(hover_info_data):
					return hover_info_data

		hover_info_data = HoverInfoData.new()





	if is_instance_valid(NodeManager.library_state):
		var items_container: GridContainer = NodeManager.library_state.item_scroll_container.scroll_container.get_child(0).get_child(0)
		var enemies_container: GridContainer = NodeManager.library_state.bestiary_container.enemy_texture_container
		var build_container: DynamicSlotContainer = NodeManager.library_state.build_planner_container.build_container

		var extra_info: Array[BBContainerData] = []
		var item: Item = null


		for idx in build_container.get_child_count():
			var item_slot: ItemSlot = build_container.get_child(idx)

			if not item_slot.has_item_texture():
				continue

			if not hovered_node == item_slot.get_item_texture_rect():
				continue

			item = UserData.profile.get_selected_build().items[idx]
			break


		for idx in items_container.get_child_count():
			var item_texture_rect = items_container.get_child(idx)
			if not item_texture_rect == hovered_node:
				continue

			item = NodeManager.library_state.library.items[idx]
			if not is_instance_valid(item.resource):
				extra_info = Info.get_requirement_unlock_info(Items.LIST[idx], null)
			break


		if is_instance_valid(item):
			hover_info_data = Info.from_item(hover_info_data, item, null)

			if not is_instance_valid(item.resource):
				hover_info_data.bb_container_data_arr += extra_info
				return hover_info_data


			var floor_text: String = T.get_translated_string("Floor") + " "
			var buy_price: Price = item.get_buy_price(false)
			hover_info_data.cost_type = buy_price.type
			hover_info_data.cost = buy_price.amount

			Info.add_requirement_unlock_info(hover_info_data, item.resource, null)
			if item.resource.unlock_requirements.size() > 0:
				hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))

			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(floor_text + str(item.resource.spawn_floor), Color.DIM_GRAY))


			return hover_info_data


		for idx in enemies_container.get_child_count():
			var enemy_texture_rect = enemies_container.get_child(idx)

			if not enemy_texture_rect == hovered_node:
				continue

			var enemy: Enemy = NodeManager.library_state.enemies[idx]

			if not is_instance_valid(enemy) or not NodeManager.library_state.profile.encountered_enemies.has(enemy.resource):
				hover_info_data.name_color = Color.DARK_GRAY
				hover_info_data.name = T.get_translated_string("Unknown Enemy")
				return hover_info_data

			var floor_text: String = T.get_translated_string("Floor") + " "
			hover_info_data = Info.from_enemy(hover_info_data, enemy, true)

			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(floor_text + str(enemy.resource.floor_number + 1), Color.DIM_GRAY))


			return hover_info_data



	if curr_state is MemorySelectionState:
		if hovered_node == curr_state.interact_button:
			var selected_memory_slot: MemorySlot = UserData.get_memeory_slot(curr_state.selected_memory_slot_idx)

			if is_instance_valid(selected_memory_slot) and selected_memory_slot.memory.can_ascend():
				hover_info_data.bb_container_data_arr = T.get_translated_bb_code(Keywords.ASCEND.name, "Keyword Description")

				return hover_info_data


	if curr_state is GameplayState:
		var market_popup_container: MarketPopupContainer = curr_state.canvas_layer.market_popup_container
		var character_manager: CharacterManager = curr_state.character_manager
		var canvas_layer: GameplayCanvasLayer = curr_state.canvas_layer
		var room_screen: RoomScreen = canvas_layer.room_screen
		var hovered_slot: Slot = curr_state.get_hovered_slot()
		var hovered_item: Item = hovered_slot.get_item()
		var dragged_item: Item = ItemManager.dragged_item_slot.get_item()
		var selected_adventurer: Adventurer = curr_state.get_selected_adventurer()
		var selected_player: Player = curr_state.get_selected_player()
		var market_manager: MarketManager = curr_state.market_manager
		var memory: Memory = curr_state.memory
		var local_player: Player = memory.local_player

		var swap_equipment_result: ItemPressResult.Type = character_manager.can_swap_equipment(local_player)
		var active_item_sets: Array[ItemSetResource] = []
		var defending_abilities: Array[AbilityResource] = []
		var enemies_to_battle: Array[Enemy] = []
		var extra_stats: Array[BonusStat] = []



		if is_instance_valid(selected_player):
			active_item_sets = selected_player.get_limited_active_item_sets()


		if is_instance_valid(memory.battle):
			var battle: Battle = memory.battle
			enemies_to_battle = battle.enemies_to_battle


		var slots_to_merge: Array[Slot] = ItemManager.get_slots_to_merge(local_player, ItemManager.hovered_slot, ItemManager.MergeSource.GLOBAL)
		var info_item: Item = null

		if slots_to_merge.size():
			var main_item: Item = slots_to_merge[0].get_item()
			var alt_item: Item = slots_to_merge[1].get_item()
			var cloned_item_a: Item = Item.new(main_item)
			var cloned_item_b: Item = Item.new(alt_item)
			var merge_with_item: Item = cloned_item_b
			var merge_item: Item = cloned_item_a


			merge_item.merge_with(merge_with_item)
			extra_stats = merge_item.get_bonus_stats()


			if not main_item.reforged_stats.is_empty():
				main_item = alt_item

			info_item = main_item

			for bonus_stat in main_item.get_bonus_stats():
				for extra_stat in extra_stats:
					if not extra_stat.is_same_as(bonus_stat):
						continue
					extra_stat.amount -= bonus_stat.amount


			cloned_item_a.cleanup()
			cloned_item_a.free()

			cloned_item_b.cleanup()
			cloned_item_b.free()



		if is_instance_valid(hovered_item) and not is_instance_valid(dragged_item):
			if hovered_item.is_reforge or hovered_item.rarity == ItemRarity.Type.DIVINE:
				extra_stats.clear()



		if is_instance_valid(dragged_item):
			var to_clear: bool = true
			for slot in slots_to_merge:
				var item: Item = slot.get_item()
				if is_instance_valid(item):
					if not dragged_item.is_reforge and item.rarity == ItemRarity.Type.DIVINE:
						continue

				if slot.is_same_slot(ItemManager.dragged_item_slot):
					to_clear = false
					break

			if to_clear:
				extra_stats.clear()



		for idx in memory.partners.size():
			for partner_container_holder in [room_screen.partner_container_holder]:
				var partner_container: PartnerContainer = partner_container_holder.get_child(idx)
				var partner: Player = memory.partners[idx]

				var player_name: String = partner.get_translated_log_name()



				if hovered_node == partner_container:
					hover_info_data.bottom_hint_texture = Action.get_press_texture()
					hover_info_data.bottom_hint = T.get_translated_string("to-lock").to_lower()

					if is_instance_valid(curr_state.locked_partner) and curr_state.locked_partner.profile_id == local_player.profile_id:
						hover_info_data.bottom_hint = T.get_translated_string("to-unlock").to_lower()

					if is_instance_valid(dragged_item):
						if not memory.game_mode.team_based or memory.game_mode.team_based and partner.team == memory.local_player.team:
							var text: String = T.get_translated_string("Send Item To Player")
							hover_info_data.bottom_hint = text.to_lower()

					hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(player_name))
					hover_info_data.is_dynamic = true
					return hover_info_data


		if hovered_node is EffectContainer:
			if is_instance_valid(hovered_node.stat_resource):
				hover_info_data = Info.from_stat_resource(hover_info_data, hovered_node.character, hovered_node.stat_resource)
				return hover_info_data

			if is_instance_valid(hovered_node.item_set_resource):
				hover_info_data = Info.from_item_set(hover_info_data, hovered_node.character, hovered_node.item_set_resource)
				return hover_info_data

			if is_instance_valid(hovered_node.specialization):
				hover_info_data = Info.from_item_set(hover_info_data, selected_player, hovered_node.specialization.original_item_set, hovered_node.specialization)
				return hover_info_data

			hover_info_data = Info.from_status_effect_resource(hover_info_data, hovered_node.status_effect_resource, hovered_node.character)

			return hover_info_data


		for idx in market_popup_container.item_holder.get_child_count():
			var child = market_popup_container.item_holder.get_child(idx)
			if child is ItemTextureRect:
				if not hovered_node == child:
					continue

				var item: Item = market_popup_container.item_cache[idx]
				hover_info_data = Info.from_item(hover_info_data, item, local_player)

				item.is_banish = child.is_banish
				if child.is_banish:
					hover_info_data.bottom_hint = T.get_translated_string("to-restore").to_lower()
					hover_info_data.bottom_hint_texture = Action.get_press_texture()
					hover_info_data.name = Info.get_item_name(item)
					hover_info_data.is_dynamic = true


				if market_popup_container.requirement_locked_items.has(item.resource):
					Info.add_requirement_unlock_info(hover_info_data, item.resource, local_player)

				return hover_info_data



		match hovered_node:
			canvas_layer.adventurer_portrait: return Info.from_adventurer(hover_info_data, selected_adventurer)
			canvas_layer.health_bar: return Info.from_stat_resource(hover_info_data, null, Stats.HEALTH)
			canvas_layer.armor_bar: return Info.from_stat_resource(hover_info_data, null, Stats.ARMOR)
			canvas_layer.mana_bar: return Info.from_stat_resource(hover_info_data, null, Stats.MANA)


		for stat in Stats.DISPLAY:
			var stat_label_container: StatLabelContiner = canvas_layer.get_stat_label_container(stat)

			if stat_label_container == hovered_node:
				return Info.from_stat_resource(hover_info_data, selected_player, stat_label_container.stat)



		for idx in enemies_to_battle.size():
			var enemy: Enemy = enemies_to_battle[idx]
			var enemy_container: EnemyContainer = room_screen.get_enemy_container(idx)

			if not is_instance_valid(enemy_container):
				continue

			if not is_instance_valid(enemy):
				continue

			if enemy.out_of_combat:
				continue



			if enemy_container.immunity_texture_rect == hovered_node:
				var text: PackedStringArray = T.get_translated_string("Enemy Player Immunity").split("|")
				var misc: String = T.get_translated_string("Enemy player immunity misc").to_lower()
				var reduction: float = floorf((1.0 - memory.battle.get_partner_damage_reduction()) * 100)
				misc = misc.replace("{amount}", "1")

				for string in text:
					string = string.replace("{amount}", Format.number(reduction))

					if enemy.immune_to == UserData.profile.id:
						string = string.replace("{player-name}", Net.own_name)

					for player in Lobby.data.players:
						if player.profile_id == enemy.immune_to:
							string = string.replace("{player-name}", player.name)
							break

					hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(string.to_lower()))

				hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
				hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
				hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(misc, Color.DIM_GRAY))

				return hover_info_data



			if not enemy_container.selection_rect == hovered_node:
				continue

			hover_info_data = Info.from_enemy(hover_info_data, enemy)

			if memory.room_type == Rooms.CHEST:
				hover_info_data.cost = memory.get_chest_gold_reward()
				hover_info_data.cost_type = Stats.GOLD

			if not memory.battle.selected_enemy_idx == idx:
				hover_info_data.bottom_hint_texture = Action.get_press_texture()
				hover_info_data.bottom_hint = T.get_translated_string("to-select").to_lower()



			hover_info_data.is_dynamic = true
			return hover_info_data




		if not is_instance_valid(dragged_item):
			var market_slots: Array[Slot] = []

			for index in selected_player.market.items.size():
				var slot = Slot.new(selected_player.market, index)
				market_slots.push_back(slot)

			for index in selected_player.merchant.items.size():
				var slot = Slot.new(selected_player.merchant, index)
				market_slots.push_back(slot)

			for index in selected_player.mystic_trader.items.size():
				var slot = Slot.new(selected_player.mystic_trader, index)
				market_slots.push_back(slot)


			for slot in market_slots:
				var item_slot: ItemSlot = canvas_layer.get_item_slot(slot)
				if not is_instance_valid(item_slot):
					continue

				if not item_slot.has_item_texture():
					continue

				if item_slot.get_rects().has(hovered_node):
					var market_item: Item = slot.get_item()
					var merge_item: Item = market_item

					if not is_instance_valid(market_item):
						return

					if slots_to_merge.size():
						merge_item = info_item



					if not slot.item_container.challenge_locked_indexes.has(slot.index):
						hover_info_data.bottom_hint = T.get_translated_string("to-lock").to_lower()
						hover_info_data.bottom_hint_texture = Action.get_press_texture()


					if market_manager.can_buy_item(slot.item_container, slot.index):
						hover_info_data.bottom_hint = T.get_translated_string("to-buy").to_lower()
						if market_item.is_banish:
							hover_info_data.bottom_hint = T.get_translated_string("to-banish").to_lower()

						hover_info_data.bottom_hint_texture = Action.get_alt_press_texture()



					if slot.item_container.locked_indexes.has(slot.index):
						hover_info_data.bottom_hint = T.get_translated_string("to-unlock").to_lower()
						hover_info_data.bottom_hint_texture = Action.get_press_texture()



					var buy_price: Price = market_item.get_buy_price(true)
					hover_info_data.cost = buy_price.amount
					if market_item.discount > 0.0:
						var pre_discount_cost: Price = market_item.get_buy_price(false)
						hover_info_data.pre_discount_cost = pre_discount_cost.amount

					hover_info_data.is_dynamic = true
					hover_info_data.cost_type = buy_price.type

					return Info.from_item(hover_info_data, merge_item, selected_player, extra_stats)



		for item_container in curr_state.memory.get_item_containers(selected_player):
			for index in item_container.items.size():
				var slot = Slot.new(item_container, index)
				var item_slot: ItemSlot = canvas_layer.get_item_slot(slot)

				if not is_instance_valid(item_slot):
					continue


				if not item_slot.has_item_texture():
					continue

				var item: Item = slot.get_item()


				if not is_instance_valid(item):
					continue

				if not item_slot.get_rects().has(hovered_node):
					continue

				var bottom_hint_text: String = T.get_translated_string("to-equip").to_lower()
				var show_hint: bool = swap_equipment_result == ItemPressResult.Type.SWAP
				var has_socket: bool = false

				if not is_instance_valid(info_item) or item.is_reforge:
					info_item = item

				hover_info_data.bottom_hint_texture = Action.get_alt_press_texture()
				hover_info_data.is_dynamic = true


				for socket in local_player.adventurer.sockets:
					if item.resource.socket_type == socket:
						has_socket = true
						break


				if item_container.resource == ItemContainerResources.INVENTORY and not info_item.is_reforge:
					if not has_socket:
						show_hint = false


				if not is_instance_valid(item.resource.socket_type) or item.is_phantom:
					show_hint = false

				if selected_player == local_player:
					if item.resource.is_tome() and local_player.can_learn_ability(item.resource.ability_to_learn):
						bottom_hint_text = T.get_translated_string("to-learn").to_lower()
						show_hint = true

					if item.resource.is_essential():
						bottom_hint_text = T.get_translated_string("to-toggle").to_lower()
						show_hint = true

					if item.has_transformer_stat():
						bottom_hint_text = T.get_translated_string("to-activate").to_lower()
						show_hint = true

					if item.resource.is_consumable() or item.resource.is_stat_adapter():
						bottom_hint_text = T.get_translated_string("to-consume").to_lower()
						show_hint = true

				if item.is_reforge:
					show_hint = false

				if [ItemContainerResources.DISMANTLE, ItemContainerResources.ENEMY_UPGRADE].has(item_container.resource):
					var stats_to_dismantle: Array[BonusStat] = item.get_stats_to_dismantle()

					if stats_to_dismantle.is_empty():
						continue

					for bonus_stat in stats_to_dismantle:
						hover_info_data.bb_container_data_arr += Info.from_stat(local_player, bonus_stat, [])

					return hover_info_data


				if show_hint:
					hover_info_data.bottom_hint = bottom_hint_text
					match item_container.resource:
						ItemContainerResources.EQUIPMENT: hover_info_data.bottom_hint = T.get_translated_string("to-remove").to_lower()
						ItemContainerResources.LOOT_STASH: hover_info_data.bottom_hint = T.get_translated_string("to-take").to_lower()



				hover_info_data = Info.from_item(hover_info_data, info_item, selected_player, extra_stats)
				if item.has_burnout():
					hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
					hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
					hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(T.get_translated_string("burnout-description"), Color.DIM_GRAY))


				return hover_info_data



		if is_instance_valid(hovered_item):
			var duplicated_hovered_item: Item = Item.new(hovered_item)
			info_item = duplicated_hovered_item

			for slot in selected_player.get_all_item_slots():
				if ItemManager.can_merge(hovered_slot, slot) or ItemManager.can_merge(slot, hovered_slot):
					var item_slot: ItemSlot = canvas_layer.get_item_slot(slot)
					var item: Item = slot.get_item()

					if not item_slot.get_rects().has(hovered_node):
						if not item_slot.get_item_texture_rect() == hovered_node:
							continue

					if not item.is_reforge and info_item.is_reforge:
						info_item = item

					if duplicated_hovered_item.is_tinker_kit:
						info_item = dragged_item

					hover_info_data.is_dynamic = true
					hover_info_data = Info.from_item(hover_info_data, info_item, selected_player, extra_stats)
					break


			duplicated_hovered_item.cleanup()
			duplicated_hovered_item.free()

			if hover_info_data.bb_container_data_arr.is_empty():
				hover_info_data.unreference()
				return null

			return hover_info_data




	if curr_state is LobbyState:
		for trial_idx in Trials.LIST.size():
			var trial_container: IconButton = curr_state.trial_container_holder.get_child(trial_idx)
			var trial: Trial = Trials.LIST[trial_idx]

			if hovered_node == trial_container:
				if not trial_container.locked:
					hover_info_data.bottom_hint = T.get_translated_string("to toggle").to_lower()
					hover_info_data.bottom_hint_texture = Action.get_press_texture()

				return Info.from_trial(hover_info_data, trial)






	hover_info_data.unreference()
	return null







func get_character(curr_state) -> Character:
	var character: Character = null

	if curr_state is GameplayState:
		if is_instance_valid(curr_state.memory.local_player):
			character = curr_state.memory.local_player

	return character
