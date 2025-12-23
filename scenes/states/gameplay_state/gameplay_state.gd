class_name GameplayState extends Node

enum ItemType{MARKET, EFFECT_DROP, CHEST_DROP}

signal item_encountered(item_resource: ItemResource)
signal game_ended(winner: Team.Type)
signal gameplay_covered_changed

signal pressed_primary_action(forced: bool)
signal pressed_stance_action(forced: bool)
signal pressed_base_ability_action(forced: bool)
signal pressed_learned_ability_1_action(forced: bool)
signal pressed_learned_ability_2_action(forced: bool)


@onready var room_screen: RoomScreen = canvas_layer.room_screen

@export var character_manager: CharacterManager
@export var market_manager: MarketManager
@export var battle_manager: BattleManager
@export var enemy_manager: EnemyManager
@export var canvas_layer: GameplayCanvasLayer
@export var death_screen: DeathScreen

var gameplay_covered: Array[Node] = []

var methods_in_process: Array[Callable] = []
var methods_to_process: Array[Method] = []
var last_frame_dragged_item: Slot
var room_processor: RoomProcessor


var memory_slot_idx: int = -1
var phantom_memory: Memory = null
var memory: Memory = null


var locked_partner: Player = null

var hover_info_update_request: bool = false
var hovering_enemy_container: bool = false


var options: Options = OptionsManager.options

var update_all_ui_requested: bool = false
var equipped_slots: Array[Slot] = []

var last_local_player_damage_result: DamageResult = null
var last_damage_result: DamageResult = null
var run_time_freeze: float = 0.0
var frozen_run_time: float = 0.0



func _ready() -> void :
	canvas_layer.stats_scroll_container.visibility_changed.connect(
		func(): UIManager.update_stats_scroll_container(memory.local_player, true))

	room_screen.interact_button.pressed.connect( func(): pressed_primary_action.emit(false))

	canvas_layer.market_popup_container.visibility_changed.connect( func(): process_cover())
	canvas_layer.chat_popup_container.visibility_changed.connect( func(): process_cover())
	canvas_layer.loot_stash_popup_container.visibility_changed.connect( func():
		update_item_slots()
		process_cover()
		)
	canvas_layer.market_button.pressed.connect( func(): open_market_popup())

	room_screen.partner_container_holder.hovered_partner_idx_changed.connect( func(): update_all_ui_requested = true)
	room_screen.partner_container_holder.partners = memory.partners


	ItemManager.item_created.connect(_on_item_created)

	character_manager.set_gameplay_state(self)
	market_manager.set_gameplay_state(self)
	battle_manager.set_gameplay_state(self)
	enemy_manager.set_gameplay_state(self)
	memory.update_game_mode_script()
	connect_local_player_signals()
	setup_rng()


	if memory.profile_id.is_empty():
		memory.profile_id = UserData.profile.id


	var local_player: Player = memory.local_player
	local_player.battle_log_name = [T.get_translated_string("Local Player Name")]
	local_player.client_id = Lobby.get_client_id()


	if not memory.initialized:
		initialize_memory()

	for player in memory.get_all_players():
		player.initialize()

	update_music()
	update_room_processor()
	canvas_layer.gold_coins_container.label.text = str(local_player.gold_coins)
	room_screen.update_room(memory.room_type)


	update_all_ui_requested = true
	fix_confusion_effect()
	fix_memory()

	if is_instance_valid(memory.battle):
		reset_enemy_containers(memory.battle)

	if Lobby.is_lobby_owner():
		battle_manager.set_battle_speed(options.battle_speed)


	update_market_popup()
	save()


	await get_tree().create_timer(0.45).timeout
	if not UserData.profile.seen_tutorial_popup:
		PopupManager.pop(PopupManager.no_tutorial_popup)
		UserData.profile.seen_tutorial_popup = true
		UserData.profile.save()







func initialize_memory() -> void :
	var local_player: Player = memory.local_player

	for player in memory.get_all_players():
		StatUtils.set_stat_amount(player.stats, Stat.new([Stats.ACCURACY, 100]))

		player.gold_coins = 15 + (3 * memory.partners.size())
		player.gold_coins += 25 * player.active_trials.size()
		player.diamonds = 1

		if player.team == Team.Type.RED:
			player.gold_coins += ceilf(memory.get_gold_on_kill(null, 0) * 1.25)

	for item_resource in local_player.adventurer.starting_inventory_items:
		character_manager.drop_item(ItemManager.create_item(item_resource, memory.floor_number), true)

	market_manager.make_initial_refresh()
	character_manager.try_to_rest()


	var market_idx: int = 0
	for idx in local_player.adventurer.challenge_market_items.size():
		var challenge_market_item: ItemResource = local_player.adventurer.challenge_market_items[idx]
		local_player.market.items[market_idx] = ItemManager.create_item(challenge_market_item)
		local_player.market.challenge_locked_indexes.push_back(market_idx)
		local_player.market.items[market_idx].discount = 0.1
		market_idx += 1

	for idx in local_player.adventurer.starting_market_items.size():
		var starting_market_item: ItemResource = local_player.adventurer.starting_market_items[idx]
		local_player.market.items[market_idx] = ItemManager.create_item(starting_market_item)
		local_player.market.locked_indexes.push_back(market_idx)
		market_idx += 1


	if memory.game_mode == GameModes.PRACTICE:
		for item in UserData.profile.get_selected_build().get_items():
			character_manager.add_item(item.resource, item.rarity)

	if memory.game_mode.last_floor == -1:
		memory.is_endless = true

	memory.initialized = true




func _on_item_created(item: Item) -> void :
	item_encountered.emit(item.resource)



func _on_local_player_gold_coins_changed(new_amount: float) -> void :
	if not memory.partners.is_empty():
		Net.call_func(MultiplayerManager.sync_gold_coins, [Lobby.get_client_id(), new_amount])
	UIManager.update_gold_coins(memory.local_player)


func _on_local_player_diamonds_changed(new_amount: float) -> void :
	if not memory.partners.is_empty():
		Net.call_func(MultiplayerManager.sync_diamonds, [Lobby.get_client_id(), new_amount])
	UIManager.update_diamonds(memory.local_player)



func connect_local_player_signals() -> void :
	var local_player: Player = memory.local_player

	local_player.gold_coins_changed.connect(_on_local_player_gold_coins_changed)
	local_player.diamonds_changed.connect(_on_local_player_diamonds_changed)

	if memory.partners.is_empty():
		return

	var client_id: int = Lobby.get_client_id()

	for item_container in local_player.get_item_containers():
		item_container.item_removed.connect( func(idx: int, cause: ItemContainer.ItemRemoveCause):
			Net.call_func(MultiplayerManager.remove_item, [client_id, item_container.resource.resource_path, idx, cause]))

		item_container.item_added.connect( func(item: Item, idx: int):
			Net.call_func(MultiplayerManager.add_item, [client_id, item_container.resource.resource_path, SaveSystem.get_data(item), idx]))

		item_container.item_updated.connect( func(item: Item, idx: int):
			Net.call_func(MultiplayerManager.update_item, [client_id, item_container.resource.resource_path, SaveSystem.get_data(item), idx]))


	local_player.item_added_to_recent_market_items.connect( func(item_resource: ItemResource):
		Net.call_func(MultiplayerManager.add_to_recent_market_items, [client_id, item_resource.resource_path]))

	local_player.item_added_to_buy_history.connect( func(item_resource: ItemResource):
		Net.call_func(MultiplayerManager.add_to_buy_history, [client_id, item_resource.resource_path]))



func _process(delta: float) -> void :
	if not is_instance_valid(memory.local_player):
		return


	process_inputs()

	if not memory.local_player.died and not memory.room_type == Rooms.ENTRANCE:
		run_time_freeze = maxf(0.0, run_time_freeze - delta)
		memory.run_time += delta
		UIManager.update_turn_label()



	if is_instance_valid(memory.battle):
		memory.local_player.unlock_artifacts()
		if not character_manager.can_swap_equipment(memory.local_player) == ItemPressResult.Type.SWAP:
			ItemManager.disabled_containers.push_back(ItemContainerResources.EQUIPMENT)
			memory.local_player.lock_artifacts()


		memory.battle.clear_invalid_enemies()
		process_enemy_selection(memory.battle)
		battle_manager.process_battle_speed(memory.battle)
		update_enemy_containers(memory.battle)
		process_external_stats(memory.battle)
		process_turn_timer(memory.battle)


	for method in methods_to_process:
		if not is_instance_valid(method):
			continue
		call_method(method.callable, method.args)
	methods_to_process.clear()


	process_hovered_slot()


	process_item_manager.call_deferred()

	market_manager.process_market_refresh_button()
	market_manager.process_hub_action_panel()
	market_manager.process_market_slots()
	
	var selected_player: Player = market_manager.gameplay_state.get_selected_player()

	if not is_instance_valid(selected_player):
		return

	var market_slots: Array[Slot] = []
	for idx in selected_player.market.items.size():
		market_slots.push_back(Slot.new(selected_player.market, idx))

	for idx in selected_player.merchant.items.size():
		market_slots.push_back(Slot.new(selected_player.merchant, idx))

	for idx in selected_player.mystic_trader.items.size():
		market_slots.push_back(Slot.new(selected_player.mystic_trader, idx))
	
	for slot in market_slots:
		var market_item: Item = slot.get_item()

		if not is_instance_valid(market_item):
			continue

		var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)

		if not is_instance_valid(item_texture_rect):
			continue
			
		item_texture_rect.build_planner_match_texture_rect.hide()

		for item in UserData.profile.get_selected_build().get_items():
			if not item.resource == market_item.resource:
				continue

			item_texture_rect.build_planner_match_texture_rect.show()

	process_partner_press()

	process_loot_stash()
	process_chat()

	process_changes()


	update_upgrade_item_texture_rect()
	process_equipment_slot_highlight()

	process_item_texture_rects()




	if memory.local_player.stat_change_process_requested:
		memory.local_player.stat_change_process_requested = false
		update_all_ui_requested = true

	if update_all_ui_requested:
		update_all_ui_requested = false
		update_all_ui()







func process_hovered_slot() -> void :
	var new_hovered_slot: Slot = get_hovered_slot()
	var old_hovered_slot: Slot = ItemManager.hovered_slot
	if not is_instance_valid(old_hovered_slot):
		old_hovered_slot = null

	if not new_hovered_slot.is_same_slot(old_hovered_slot):
		ItemManager.hovered_slot = get_hovered_slot()
		hover_info_update_request = true

	if not is_instance_valid(ItemManager.hovered_slot):
		ItemManager.hovered_slot = Empty.slot
	ItemManager.hovered_item = ItemManager.hovered_slot.get_item()




func process_inputs() -> void :
	if is_instance_valid(UI.active_line_edit):
		return

	var local_player: Player = memory.local_player

	if memory.local_player.died:
		return

	if Input.is_action_just_pressed("refresh_market"):
		market_manager.try_to_refresh_market()

	var quick_buy_slot: int = -1

	if Input.is_action_just_pressed("quick_buy_item_1"):
		quick_buy_slot = 0
	if Input.is_action_just_pressed("quick_buy_item_2"):
		quick_buy_slot = 1
	if Input.is_action_just_pressed("quick_buy_item_3"):
		quick_buy_slot = 2
	if Input.is_action_just_pressed("quick_buy_item_4"):
		quick_buy_slot = 3
	if Input.is_action_just_pressed("sort_inventory"):
		local_player.inventory.sort_items()
		update_item_slots()

	if not quick_buy_slot == -1:
		market_manager.try_to_buy_item(memory.local_player.market, quick_buy_slot)



	if Input.is_action_pressed("primary_action"):
		pressed_primary_action.emit(false)

	if Input.is_action_pressed("base_ability"):
		pressed_base_ability_action.emit(false)

	if Input.is_action_pressed("learned_ability_1"):
		pressed_learned_ability_1_action.emit(false)

	if Input.is_action_pressed("learned_ability_2"):
		pressed_learned_ability_2_action.emit(false)

	if Input.is_action_pressed("stance"):
		pressed_stance_action.emit(false)


	if Input.is_action_pressed("sell_item") and is_instance_valid(ItemManager.hovered_slot):
		if not ItemManager.hovered_slot.item_container == local_player.market:
			var slot_to_sell: Slot = ItemManager.hovered_slot

			if not ItemManager.dragged_item_slot == Empty.slot:
				slot_to_sell = ItemManager.dragged_item_slot

			market_manager.try_to_sell_items([slot_to_sell])

			update_item_slots()



	if not OS.is_debug_build():
		return

	if is_instance_valid(memory.battle):
		if Input.is_action_just_pressed("debug_complete_encounter"):
			advance(1)






func call_method(callable: Callable, args: Array) -> void :
	if methods_in_process.has(callable):
		return
	methods_in_process.push_back(callable)
	await callable.callv(args)
	methods_in_process.erase(callable)





func fix_memory() -> void :
	var local_player: Player = memory.local_player

	for player in memory.get_all_players():
		player.cache_stats()

	if not local_player.inventory.items.size():
		local_player.inventory = ItemContainer.new(ItemContainerResources.INVENTORY, Slot.INVENTORY_SLOTS_PER_PAGE)


	if not local_player.market.items.size():
		local_player.market = ItemContainer.new(ItemContainerResources.MARKET, 4)


	for item_container in [local_player.inventory, local_player.equipment, local_player.market]:
		for index in item_container.items.size():
			var slot: Slot = Slot.new(item_container, index)

			var item: Item = slot.get_item()

			if not is_instance_valid(item):
				continue

			if not is_instance_valid(item.resource):
				slot.remove_item()


	match memory.room_type:
		Rooms.BATTLE:
			if is_instance_valid(memory.battle):
				fix_battle(memory.battle)

		_: try_to_leave_room(null)




func fix_battle(battle: Battle) -> void :
	process_next_enemies(battle, true)
	battle.setup_in_progress = false


	for idx in range(battle.enemies_to_battle.size() - 1, -1, -1):
		var enemy: Enemy = battle.enemies_to_battle[idx]

		if not EnemyUtils.is_valid(enemy):
			battle.remove_enemy(idx)
			continue

		enemy.cache_stats()
		if enemy.get_health() == 0:
			battle.remove_enemy(idx)



	if not is_instance_valid(memory.get_player_to_battle()):
		for player in memory.get_alive_players():
			if not player.battle_profile.has_active_status_effect_resource(StatusEffects.TIMEOUT):
				continue
			player.battle_profile.remove_matching_status_effects(StatusEffects.TIMEOUT, 1)


	battle_manager.set_turn_in_progress(battle, false)
	battle_manager.try_to_complete_battle(battle)
	try_to_advance(battle)






func add_to_battle_log(battle: Battle, log_to_add: BattleLogData) -> void :
	var current_turn: int = battle.current_turn
	if current_turn == 0:
		return

	var last_log: BattleLogData = null
	canvas_layer.battle_log_tab_container.add_to_log(log_to_add.get_bb_container_data(), current_turn)






func update_upgrade_item_texture_rect() -> void :
	if not get_selected_player() == memory.local_player:
		return

	var dragged_item: Item = ItemManager.dragged_item_slot.get_item()
	var target_slot: Slot = null

	if is_instance_valid(ItemManager.hovered_item):
		target_slot = ItemManager.hovered_slot

	if is_instance_valid(dragged_item):
		target_slot = ItemManager.dragged_item_slot

	if not is_instance_valid(target_slot):
		UIManager.item_time = 0.0
		return


	var target_item: Item = target_slot.get_item()

	var target_item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(target_slot)
	var target_item_rarity: int = target_item.rarity
	var merge_texture: Texture = preload("res://assets/textures/ui/merge_icon.png")

	if target_item.is_reforge:
		merge_texture = preload("res://assets/textures/ui/reforge_merge_icon.png")

	if is_instance_valid(target_item_texture_rect):
		target_item_texture_rect.merge_texture_rect.texture = merge_texture

	for item_container in memory.get_item_containers(memory.local_player):
		if item_container.resource == ItemContainerResources.MARKET:
			continue

		for index in item_container.items.size():
			var slot: Slot = Slot.new(item_container, index)

			var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)
			var skip_main_merge_glow: bool = false
			var item: Item = slot.get_item()

			if not is_instance_valid(item):
				continue

			if target_item == item:
				continue

			if not is_instance_valid(item_texture_rect):
				continue

			if not Item.is_compatible(item, target_item):
				skip_main_merge_glow = true
				if not Item.is_compatible(target_item, item):
					continue

			if target_slot.item_container.resource == ItemContainerResources.EQUIPMENT:
				continue

			if item_container.resource == ItemContainerResources.LOOT_STASH:
				continue

			target_item_rarity = mini(ItemRarity.Type.DIVINE, target_item.rarity + 1)
			if item.is_reforge:
				target_item_rarity = target_item.rarity

			if is_instance_valid(target_item_texture_rect) and not skip_main_merge_glow:
				target_item_texture_rect.play_upgrade_visuals(target_item_rarity, target_item.is_reforge)

			item_texture_rect.merge_texture_rect.texture = merge_texture
			if item.is_reforge:
				item_texture_rect.merge_texture_rect.texture = preload("res://assets/textures/ui/reforge_merge_icon.png")

			item_texture_rect.play_upgrade_visuals(target_item_rarity, target_item.is_reforge)





	if not is_instance_valid(ItemManager.hovered_item) or not is_instance_valid(dragged_item):
		return



	var can_merge: bool = ItemManager.can_merge(ItemManager.hovered_slot, ItemManager.dragged_item_slot)
	if ItemManager.can_merge(ItemManager.dragged_item_slot, ItemManager.hovered_slot):
		can_merge = true

	if can_merge:
		var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(ItemManager.hovered_slot)

		if not is_instance_valid(item_texture_rect):
			return

		item_texture_rect.set_rarity_hue_effect(ItemRarity.get_hue_texture(ItemManager.hovered_item.rarity), ItemRarity.get_hue_strength(ItemManager.hovered_item.rarity))
		item_texture_rect.set_rarity_texture_rect_ratio(1.0)
		item_texture_rect.merge_texture_rect.modulate.a = 0.5
		item_texture_rect.rarity_color_overriden_this_frame = true
		item_texture_rect.rarity_hue_overriden_this_frame = true
		item_texture_rect.enable_glow_this_frame = false




func process_burnout_visuals(character: Character, slot: Slot) -> void :
	var item: Item = slot.get_item()

	if not is_instance_valid(item):
		return

	var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)

	if not is_instance_valid(item_texture_rect):
		return

	if not item.has_burnout():
		item_texture_rect.burnout_progress_bar.hide()
		return


	item_texture_rect.burnout_progress_bar.value = Item.MAX_BURNOUT - item.burnout
	item_texture_rect.burnout_progress_bar.show()






func process_special_item_visuals(character: Character, slot: Slot) -> void :
	var item: Item = slot.get_item()

	if not is_instance_valid(item):
		return

	var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)

	if not is_instance_valid(item_texture_rect):
		return

	var remaining_uses: int = item.get_remaining_uses()
	var curr_progress: float = 0.0
	var saturation: float = 1.0

	if item.resource.is_essential():
		saturation = 0.0
		if remaining_uses or is_instance_valid(item.resource.activation_effect.ability):
			saturation = 1.0

	if item.resource.is_tome():
		if character is Player:
			if not character.can_learn_ability(item.resource.ability_to_learn):
				curr_progress = 0.5

	item_texture_rect.build_planner_match_texture_rect.hide()
	for build_item in UserData.profile.get_selected_build().get_items():
		if not item.resource == build_item.resource:
			continue
		item_texture_rect.build_planner_match_texture_rect.show()

	if item.resource.is_consumable():
		if is_instance_valid(memory.battle) and memory.battle.turn_in_progress:
			curr_progress = 0.5

	if item.drag_locked:
		curr_progress = 0.5

	if item.resource.is_essential():
		item_texture_rect.rarity_texture_rect.texture = preload("res://assets/textures/rarity_borders/toggle_off_border.png")

		if item.toggled:
			item_texture_rect.rarity_texture_rect.texture = preload("res://assets/textures/rarity_borders/toggle_on_border.png")

		if not MultiplayerManager.can_activate_item(character, item, BattleTurn.Type.ATTACK):
			curr_progress = 0.5


	item_texture_rect.set_saturation(saturation)
	item_texture_rect.activation_texture_bar.hide()
	item_texture_rect.max_progress = 1.0
	item_texture_rect.curr_progress = curr_progress






func process_item_discount_visuals(slot: Slot) -> void :
	var item: Item = slot.get_item()

	if not is_instance_valid(item):
		return

	var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)

	if not is_instance_valid(item_texture_rect):
		return

	var mega_discount: bool = false

	(item_texture_rect.outline_texture_rect.texture as AtlasTexture).region.position.x = 0
	item_texture_rect.discount_texture_rect.hide()
	if item.discount > 0.0:
		(item_texture_rect.outline_texture_rect.texture as AtlasTexture).region.position.x = 36
		item_texture_rect.discount_texture_rect.show()

	if item.discount > 0.75:
		mega_discount = true

	(item_texture_rect.discount_texture_rect.material as ShaderMaterial).set_shader_parameter("enabled", mega_discount)




func process_equipment_preview_visuals(character: Character) -> void :
	var equipment: Array[Item] = character.equipment.get_items_with_null()

	for index in equipment.size():
		var equipment_slot_preview: EquipmentSlotPreview = canvas_layer.equipment_slot_preview_container.equipment_slot_preview_nodes[index]
		var equipped_item: Item = equipment[index]

		equipment_slot_preview.slot_texture_rect.show()

		if not is_instance_valid(equipped_item):
			continue

		var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(Slot.new(character.equipment, index))

		if not is_instance_valid(item_texture_rect):
			continue
		
		item_texture_rect.build_planner_match_texture_rect.hide()
		for build_item in UserData.profile.get_selected_build().get_items():
			if not equipped_item.resource == build_item.resource:
				continue
			item_texture_rect.build_planner_match_texture_rect.show()

		var modulate: Color = Color.WHITE
		equipment_slot_preview.slot_texture_rect.hide()

		item_texture_rect.activation_texture_bar.hide()
		item_texture_rect.max_progress = 1.0
		item_texture_rect.curr_progress = 0.0

		if not character_manager.can_swap_equipment(character) == ItemPressResult.Type.SWAP:
			item_texture_rect.curr_progress += 0.5

		if character.equipment.sockets[index] == SocketTypes.REPLICATED_WEAPON:
			item_texture_rect.curr_progress += 0.25
			modulate = Color.CYAN

		item_texture_rect.set_item_texture_rect_modulate(modulate)






func process_equipment_slot_highlight() -> void :
	var adventurer: Adventurer = memory.local_player.adventurer

	for idx in adventurer.sockets.size():
		canvas_layer.equipment_slot_container.hide_highlight(idx)

	if not get_selected_player() == memory.local_player:
		return

	if not is_instance_valid(ItemManager.hovered_item):
		return

	if ItemManager.dragged_item_slot.get_item() == ItemManager.hovered_item:
		return

	for idx in adventurer.sockets.size():
		var socket = adventurer.sockets[idx]
		if not is_instance_valid(ItemManager.hovered_item.resource):
			continue

		if ItemManager.hovered_item.resource.socket_type == socket:
			canvas_layer.equipment_slot_container.show_highlight(idx)








func process_partner_press() -> void :
	var to_update: bool = false


	for idx in memory.partners.size():
		for partner_container_holder in [room_screen.partner_container_holder]:
			var parter_container: PartnerContainer = partner_container_holder.get_child(idx)
			var partner: Player = memory.partners[idx]

			if not is_instance_valid(parter_container):
				continue

			if parter_container.is_pressed:
				if not ItemManager.dragged_item_slot == Empty.slot:

					if memory.game_mode.team_based and not partner.team == memory.local_player.team:
						break

					var item_data: Dictionary = SaveSystem.get_data(ItemManager.dragged_item_slot.get_item())
					Net.call_func(MultiplayerManager.send_item, [Lobby.get_client_id(), item_data], [partner.client_id])
					ItemManager.dragged_item_slot.remove_item()
					ItemManager.discard_dragged_item()
					break

				if locked_partner == partner:
					locked_partner = null
					to_update = true
					break

				locked_partner = partner
				to_update = true
				break



	if is_instance_valid(locked_partner):
		ItemManager.disabled_containers.push_back(ItemContainerResources.LOOT_STASH)
		ItemManager.disabled_containers.push_back(ItemContainerResources.EQUIPMENT)
		ItemManager.disabled_containers.push_back(ItemContainerResources.INVENTORY)

	if not to_update:
		return

	hover_info_update_request = true
	update_parter_container_lock()




func update_parter_container_lock() -> void :
	for idx in memory.partners.size():
		for partner_container_holder in [room_screen.partner_container_holder]:
			var parter_container: PartnerContainer = partner_container_holder.get_child(idx)
			var partner: Player = memory.partners[idx]
			if not is_instance_valid(parter_container):
				continue
			parter_container.lock_texture_rect.visible = locked_partner == partner







func can_convert_item(idx: int) -> bool:
	var slot = Slot.new(memory.local_player.market, idx)
	var item: Item = slot.get_item()

	if not is_instance_valid(item):
		return false

	if not is_instance_valid(item.resource):
		return false

	return true





func process_item_texture_rects() -> void :
	var selected_player: Player = get_selected_player()
	process_equipment_preview_visuals(selected_player)

	for index in selected_player.inventory.items.size():
		var slot = Slot.new(selected_player.inventory, index)
		process_special_item_visuals(selected_player, slot)

	for index in selected_player.merchant.items.size():
		var slot = Slot.new(selected_player.merchant, index)
		process_item_discount_visuals(slot)




func process_changes():
	var local_player: Player = memory.local_player

	if not last_frame_dragged_item == ItemManager.dragged_item_slot:
		update_item_slots()

	for item in local_player.inventory.items:
		if not is_instance_valid(item):
			continue

		if item.changed_this_frame:
			update_item_slots()
			item.changed_this_frame = false

	last_frame_dragged_item = ItemManager.dragged_item_slot







func upgrade_item(item: Item, base_floor: int, type: ItemType) -> void :
	var max_rarity: int = item.resource.get_max_rarity(base_floor)

	if type == ItemType.EFFECT_DROP:
		max_rarity += 1

	if type == ItemType.CHEST_DROP:
		max_rarity += 3

	for i in mini(25, max_rarity - 1):
		var fail_chance: int = mini(95, 45 + (i * 2))
		if Math.rand_success(fail_chance):
			continue

		item.try_to_increase_rarity()







func open_chest(battle: Battle, player_opened: Player) -> void :
	var battle_processor = BattleProcesor.new(self)
	await battle_processor.open_chest(battle)
	battle_processor.cleanup()
	battle_processor.free()

	await try_to_advance(battle)



func leave_chest_room(battle: Battle, player_left: Player) -> void :
	player_left.left_room = true

	for player in memory.get_all_players():
		if not player.left_room:
			return

	battle.completed = true
	await try_to_advance(battle)







func skip_enemy_upgrade(skipped_player: Player) -> void :
	var team_in_battle: Team.Type = memory.get_team_in_battle()
	skipped_player.left_room = true

	for player in memory.get_all_players():
		if not player.team == team_in_battle:
			continue

		if not player.left_room:
			return

	await battle_manager.clear_room(memory.battle)
	try_to_advance(memory.battle)




func try_to_leave_room(skipped_player: Player, skip_animation: bool = false) -> void :
	if is_instance_valid(skipped_player):
		skipped_player.left_room = true
		update_all_ui_requested = true

	for player in memory.get_all_players():
		if not player.left_room:
			return

	memory.battle.completed = true
	try_to_advance(memory.battle, skip_animation)





func process_enemy_selection(battle: Battle) -> void :
	var enemies_to_battle: Array[Enemy] = battle.enemies_to_battle
	var enemies_in_combat_idx: PackedInt64Array = battle.get_enemies_in_combat_idx()

	hovering_enemy_container = false

	if not memory.local_player.can_select_enemy(memory.get_team_in_battle()):
		return

	if enemies_in_combat_idx.size() > 1:
		if Input.is_action_just_pressed("select_left_enemy"):
			battle.selected_enemy_idx = enemies_in_combat_idx[enemies_in_combat_idx.find(battle.selected_enemy_idx) - 1]

		if Input.is_action_just_pressed("select_right_enemy"):
			battle.selected_enemy_idx += 1


	for idx in battle.get_enemies_in_combat_idx():
		var enemy_container: EnemyContainer = room_screen.get_enemy_container(idx)
		var enemy: Enemy = enemies_to_battle[idx]

		if not is_instance_valid(enemy_container):
			continue

		if enemy.out_of_combat:
			continue

		if UI.is_hovered(enemy_container.selection_rect):
			hovering_enemy_container = true

			if Input.is_action_just_pressed("press"):
				var selected_idx: int = idx
				battle.selected_enemy_idx = selected_idx
				hover_info_update_request = true


	battle.update_enemy_selection()

	if not battle.turn_in_progress:
		battle.initial_selected_enemy_idx = battle.selected_enemy_idx







func process_cover() -> void :
	var loot_stash_popup_container: LootStashPopupContainer = canvas_layer.loot_stash_popup_container
	var market_popup_container: MarketPopupContainer = canvas_layer.market_popup_container
	var chat_popup_container: ChatPopupContainer = canvas_layer.chat_popup_container
	var to_cover: Array[Node] = []


	if market_popup_container.visible:
		to_cover = NodeUtils.get_all_children(canvas_layer, [])

	if loot_stash_popup_container.visible or chat_popup_container.visible:
		to_cover = NodeUtils.get_all_children(canvas_layer.room_screen, [])

	for child in NodeUtils.get_all_children(loot_stash_popup_container, []):
		to_cover.erase(child)

	for child in NodeUtils.get_all_children(market_popup_container, []):
		to_cover.erase(child)


	if loot_stash_popup_container.visible or chat_popup_container.visible:
		to_cover.erase(canvas_layer.loot_stash_button)
		to_cover.erase(canvas_layer.chat_button)
		for partner_container in room_screen.partner_container_holder.get_children():
			to_cover.erase(partner_container)

	update_gameplay_covered(to_cover)





func update_gameplay_covered(to_cover: Array[Node]) -> void :
	for node in gameplay_covered:
		if not is_instance_valid(node):
			continue
		node.remove_meta(UI.GAMEPLAY_COVERED)

	for node in to_cover:
		if not is_instance_valid(node):
			continue
		node.set_meta(UI.GAMEPLAY_COVERED, true)

	gameplay_covered = to_cover
	gameplay_covered_changed.emit()




func sync_state(battle: Battle) -> void :
	var initial_state: PackedInt64Array = memory.get_floor_state()

	while initial_state == memory.get_floor_state():
		send_state_sync(battle)
		await get_tree().create_timer(3.0).timeout



func send_state_sync(battle: Battle) -> void :
	var enemies_to_battle_data: Array[Dictionary] = []
	var next_enemies_data: Array[Dictionary] = []

	for enemy in battle.enemies_to_battle:
		var enemy_data: Dictionary = SaveSystem.get_data(enemy)
		enemies_to_battle_data.push_back(enemy_data)

	for enemy in battle.next_enemies:
		var enemy_data: Dictionary = {}
		if is_instance_valid(enemy):
			enemy_data = SaveSystem.get_data(enemy)
		next_enemies_data.push_back(enemy_data)


	Net.call_func(MultiplayerManager.sync_state, [enemies_to_battle_data, next_enemies_data, memory.get_floor_state()])






func play_enemy_ability(enemy_idx: int, ability: AbilityResource) -> void :
	var enemy_container = room_screen.get_enemy_container(enemy_idx)
	if not is_instance_valid(enemy_container):
		return

	play_ability_sound(enemy_container.get_screen_position())
	enemy_container.emit_ability_particles(ability.get_cast_color())




func play_ability_sound(position: Vector2) -> void :
	var tone_event: ToneEventResource = ToneEventResource.new()
	var tone = Tone.new(preload("res://assets/sfx/use_ability.wav"), -2.5)
	tone_event.tones.push_back(tone)
	tone_event.stackable = true

	tone.pitch_min = 0.95
	tone.pitch_max = 1.05

	if not position == Vector2(-1, -1):
		tone_event.space_type = ToneEventResource.SpaceType._2D
		tone_event.position = position

	AudioManager.play_event(tone_event, name)





func try_to_advance(battle: Battle, skip_animation: bool = false) -> bool:
	if not battle.completed:
		return false

	battle.completed = false

	await battle_manager.create_battle_animation_timer(0.45)
	update_item_slots()

	await advance(1, skip_animation)

	return true






func advance(amount: int = 1, skip_animation: bool = false) -> void :
	var existed_last_room: bool = memory.is_last_room()
	var speed: float = battle_manager.battle_speed * 2

	if memory.room_idx == -1:
		memory.room_idx = 0
		amount = 0


	memory.room_idx += amount

	play_sfx(preload("res://assets/sfx/floor_completed.wav"))

	if not skip_animation:
		canvas_layer.room_screen.camera_3d_animation_player.play("start", -1, 1.0 / speed)

	await canvas_layer.screen_transition.start(1.45 / speed)

	reset_room()

	var room_type: RoomResource = memory.room_type


	if not room_type.restless:
		for player in memory.get_all_players():
			player.is_phantom = false
		memory.phantom_processed = false


	if existed_last_room:
		await change_floor_number(1, false)
		return


	setup_new_room()


	UIManager.update_player_portraits(get_selected_player())

	hover_info_update_request = true
	save()



func reset_room() -> void :
	canvas_layer.loot_stash_popup_container.animation_player.stop(true)
	canvas_layer.loot_stash_popup_container.hide()
	canvas_layer.room_screen.confused = false
	character_manager.actions_blocked = false
	memory.dismantling_player_id = ""
	memory.dismantle_item_count = 0



func armor_break(_battle: Battle, target: Character, _breaker: Character) -> void :
	if target.get_stat_amount(Stats.ACTIVE_ARMOR)[0] <= 0:
		return

	canvas_layer.create_popup_label(BattleActions.ARMOR_BREAK.get_action_popup_label_data())
	target.set_active_armor(0)








func attack_popup(damage_type: StatResource, damage: float, dmg_label_size: float) -> void :
	var popup_label_data = PopupLabelData.new(Format.number(damage), damage_type.color)
	popup_label_data.right_texture = damage_type.icon
	popup_label_data.size = dmg_label_size
	canvas_layer.create_popup_label(popup_label_data)






func fix_enemy_status_effect_labels(battle: Battle, enemy_idx: int) -> void :
	var enemy_container: EnemyContainer = canvas_layer.room_screen.get_enemy_container(enemy_idx)
	var enemy: Enemy = battle.enemies_to_battle[enemy_idx]

	if not is_instance_valid(enemy_container):
		return

	for child in enemy_container.effect_container_holder.get_children():
		var failed: bool = true
		if child is EffectContainer:
			for active_status_effect in enemy.battle_profile.get_active_status_effects():
				if child.status_effect_resource == active_status_effect.resource:
					failed = false

			if failed:
				child.queue_free()




func play_attack_sound(enemy_idx: int, is_crit: bool) -> void :
	var enemy_container: EnemyContainer = canvas_layer.room_screen.get_enemy_container(enemy_idx)

	if not is_instance_valid(enemy_container):
		return

	var tone_event: ToneEventResource = ToneEventResource.new()
	var tone = Tone.new(preload("res://assets/sfx/player_attack.wav"), -2.5)
	tone_event.tones.push_back(tone)
	tone_event.stackable = true

	tone.pitch_min = 0.95
	tone.pitch_max = 1.05

	if is_crit:
		tone.audio = preload("res://assets/sfx/player_crit_attack.wav")

	tone_event.space_type = ToneEventResource.SpaceType._2D
	tone_event.position = enemy_container.get_screen_position()


	AudioManager.play_event(tone_event, name)






func transform_player_to_phantom(battle: Battle, player: Character) -> void :
	if memory.phantom_processed:
		return

	play_sfx(preload("res://assets/sfx/player_death.wav"))
	player.is_phantom = true


	UIManager.update_player_portraits(get_selected_player())

	if not memory.partners.is_empty():
		if memory.game_mode == GameModes.PVP:
			if memory.get_alive_players(Team.Type.BLUE).size() == 0:
				try_to_end_game(Team.Type.RED)
				return
			if memory.get_alive_players(Team.Type.RED).size() == 0:
				try_to_end_game(Team.Type.BLUE)
				return
			return

		if memory.get_alive_players().size() == 0:
			try_to_end_game()
		return



	if not player == memory.local_player:
		return



	await get_tree().create_timer(0.45).timeout
	await canvas_layer.full_screen_transition.start(0.5)
	canvas_layer.full_screen_transition.end(0.5)


	var original_run_time: float = memory.run_time

	SaveSystem.load_data(memory, SaveSystem.get_data(phantom_memory))

	memory.run_time = original_run_time

	canvas_layer.battle_log_tab_container.reset_for_phantom()
	memory.local_player.is_phantom = true

	reset_enemy_containers(memory.battle)
	connect_local_player_signals()
	fix_confusion_effect()
	character_manager.try_to_rest()
	update_room_processor()
	fix_memory()

	ItemManager.discard_dragged_item()
	memory.phantom_processed = true

	save()




func process_endless_death() -> void :
	var rollback_floor: int = (floori(float(memory.floor_number) / 2) * 2) - 1
	MultiplayerManager.clear_all_sync_data()

	if rollback_floor > 1:
		for player in memory.get_all_players():
			player.gold_coins = 0

	var total_rooms: int = memory.get_room_count()
	await rollback(rollback_floor, total_rooms - 1)




func rollback(floor_number: int, room_idx: int) -> void :
	await canvas_layer.screen_transition.start(1.45)
	memory.floor_number = maxi(0, floor_number)
	memory.room_idx = room_idx

	if not memory.room_type.restless:
		for player in memory.get_all_players():
			player.is_phantom = false

		memory.phantom_processed = false


	setup_new_room()
	reset_room()

	canvas_layer.adventurer_portrait.eyes_closed = false
	room_screen.update_room(memory.room_type)
	update_all_ui()

	hover_info_update_request = true
	save()




func try_to_end_game(winner: Team.Type = Team.Type.NULL) -> void :
	memory.is_game_ended = true

	if memory.room_type == Rooms.FINAL:
		var battle_processor = BattleProcesor.new(self)
		await battle_processor.kill_heart_of_the_tower(memory.battle)
		battle_processor.cleanup()
		battle_processor.free()

		await get_tree().create_timer(1.25).timeout
		await canvas_layer.room_screen.shatter()
		await get_tree().create_timer(2.75).timeout


	play_sfx(preload("res://assets/sfx/player_death.wav"))
	canvas_layer.adventurer_portrait.close_eyes()









	var to_cover: Array[Node] = []
	to_cover = NodeUtils.get_all_children(canvas_layer.room_screen, [])
	for item_slot in canvas_layer.get_all_item_slots():
		if not item_slot.has_item_texture():
			continue

		var item_texture_rect: ItemTextureRect = item_slot.get_item_texture_rect()
		if not is_instance_valid(item_texture_rect):
			continue
		to_cover.push_back(item_texture_rect)

	update_gameplay_covered(to_cover)


	for player in memory.get_all_players():
		player.set_health(0)
		player.died = true


	memory.phantom_processed = true
	update_all_ui_requested = true

	set_process(false)
	update_all_ui()
	save()

	game_ended.emit(winner)







func process_next_enemies(battle: Battle, force: bool = false) -> void :
	for idx in 3:
		var next_enemy: Enemy = battle.next_enemies[idx]

		if not EnemyUtils.is_valid(next_enemy):
			continue


		if battle.enemies_to_battle.size() <= idx:
			battle.enemies_to_battle.resize(idx + 1)

		var enemy: Enemy = battle.enemies_to_battle[idx]

		if EnemyUtils.is_valid(enemy):
			if not enemy.out_of_combat:
				continue


		var enemy_container: EnemyContainer = canvas_layer.room_screen.get_enemy_container(idx)
		if not is_instance_valid(enemy_container):
			reset_enemy_containers(battle)
			enemy_container = canvas_layer.room_screen.get_enemy_container(idx)


		if not is_instance_valid(next_enemy.battle_profile):
			next_enemy.battle_profile = BattleProfile.new()

		next_enemy.try_to_add_status_effect(null, StatusEffects.TIMEOUT)

		if enemy_container.animation_player.current_animation == "enemy_flying_idle":
			enemy_container.animation_player.stop()

		enemy_container.set_texture(next_enemy.resource.texture)
		enemy_container.stop_ability_preview_particles()

		await enemy_container.play_fade_out(1.0 / battle_manager.battle_speed, force)

		(enemy_container.enemy_texture_rect.material as ShaderMaterial).set_shader_parameter("texture_offset", Vector2(0, 0))
		enemy_container.play_fade_in(1.0 / battle_manager.battle_speed)

		if battle.enemies_to_battle.size() <= idx:
			continue

		battle.enemies_to_battle[idx] = next_enemy as Enemy
		next_enemy.cache_stats()
		battle.next_enemies[idx] = null

		UIManager.update_enemy(battle, idx)
		for node in enemy_container.nodes_to_hide_on_death:
			node.show()




func try_to_drop_loot(player: Player) -> void :
	var total_players: int = memory.get_all_players().size() - 1

	if Math.rand_success(player.loot_drop_chance):
		var item_pool: Array[ItemResource] = Items.get_resources(Items.MARKET, memory.floor_number)
		var filter: Array[ItemResource] = player.banished_items + player.banned_items + Items.ESSENTIALS
		filter += player.get_owned_item_resources()

		for item in filter:
			item_pool.erase(item)

		for item in player.get_requirement_locked_items(item_pool):
			item_pool.erase(item)

		if item_pool.size() == 0:
			item_pool = player.get_owned_item_resources()

		player.loot_drop_chance = maxi(1, 10 - (total_players * 2))

		await battle_manager.create_battle_animation_timer(0.16)
		drop_rand_item(item_pool, GameplayState.ItemType.EFFECT_DROP)
		return

	var loot_chance_to_add: int = maxi(1, 5 - total_players)
	player.loot_drop_chance += loot_chance_to_add




func drop_items(drops: int) -> void :
	for drop_idx in drops:
		var arr: Array[ItemResource] = Items.MARKET.duplicate()
		for banned_item in memory.local_player.banned_items:
			arr.erase(banned_item)

		await get_tree().create_timer(0.1).timeout
		drop_rand_item(arr, GameplayState.ItemType.CHEST_DROP)




func drop_rand_item(item_content: Array[ItemResource], type: ItemType) -> void :
	var specializations: Array[Specialization] = memory.local_player.get_active_specializations()
	var item_floor: int = memory.floor_number + 1

	var item_pool: Array[ItemResource] = Items.get_resources(item_content, item_floor)
	var drop_luck: int = 10


	var rand_item_resource: ItemResource = item_pool.pick_random()

	if type == ItemType.EFFECT_DROP:
		drop_luck = 4

	if Math.rand_success(drop_luck):
		item_floor += 1
		if Math.rand_success(1):
			item_floor += 1

	if not item_pool.size():
		return

	var rand_item: Item = ItemManager.create_item(rand_item_resource, memory.floor_number)
	upgrade_item(rand_item, item_floor, type)

	if type == ItemType.CHEST_DROP:
		rand_item.roll_reforge(memory.floor_number)

	character_manager.drop_item(rand_item)






func play_status_effect(status_effect_resource: StatusEffectResource, amount: float = 1.0) -> void :
	var text: String = T.get_translated_string(status_effect_resource.application_message, "Status Effect Application Message")

	if amount > 1:
		text = Format.number(amount)

	var popup_label_data = PopupLabelData.new(text, status_effect_resource.color)
	popup_label_data.left_texture = status_effect_resource.icon

	canvas_layer.create_popup_label(popup_label_data)
	if is_instance_valid(status_effect_resource.application_sound):
		play_sfx(status_effect_resource.application_sound)




func process_item_manager() -> void :
	var local_player: Player = memory.local_player


	for idx in ItemManager.swap_results_to_process.size():
		var swap_result_to_process = ItemManager.swap_results_to_process[idx]

		if not is_instance_valid(swap_result_to_process):
			continue


		match swap_result_to_process.type:
			ItemPressResult.Type.SWAP:
				var slot_a: Slot = null
				var slot_b: Slot = null

				if is_instance_valid(swap_result_to_process.slots[0]):
					slot_a = swap_result_to_process.slots[0]
					match slot_a.item_container:
						local_player.equipment: equipped_slots.push_back(slot_a)

				if is_instance_valid(swap_result_to_process.slots[1]):
					slot_b = swap_result_to_process.slots[1]
					match slot_b.item_container:
						local_player.equipment: equipped_slots.push_back(slot_b)

				if equipped_slots.size():
					update_all_ui_requested = true
					character_manager.try_to_rest()


			ItemPressResult.Type.TOGGLE:
				var slot: Slot = swap_result_to_process.slots[0]
				toggle_item(local_player, slot.index)


			ItemPressResult.Type.MERGE:
				var slot: Slot = swap_result_to_process.slots[0]
				if is_instance_valid(slot):
					create_upgrade_effect(swap_result_to_process.slots[0])

				character_manager.try_to_rest()
				local_player.cache_stats()


			ItemPressResult.Type.HAS_DUPLICATES:
				create_equip_warning(T.get_translated_string("CANT EQUIP DUPLICATES").to_upper())

			ItemPressResult.Type.MISSING_SOCKET:
				var text: String = T.get_translated_string("missing-item-socket")
				var missing_socket: String = ""

				for socket in SocketTypes.BASE_SOCKETS:
					if not memory.local_player.adventurer.sockets.has(socket):
						missing_socket = socket.name

				text = text.replace("{socket-name}", missing_socket)
				create_equip_warning(text.to_upper())

			ItemPressResult.Type.DISABLED:
				if not character_manager.can_swap_equipment(memory.local_player) == ItemPressResult.Type.SWAP:
					create_equip_warning(T.get_translated_string("cant-move-during-battle").to_upper())


		if ItemPressResult.SUCCESS_TYPES.has(swap_result_to_process.type):
			if not update_all_ui_requested:
				update_item_slots()



	ItemManager.swap_results_to_process.clear()

	if is_instance_valid(ItemManager.pressed_slot) and is_instance_valid(ItemManager.pressed_slot.item_container) and not ItemManager.pressed_slot == Empty.slot:
		match ItemManager.pressed_slot.item_container.resource:
			ItemContainerResources.MARKET, ItemContainerResources.MERCHANT, ItemContainerResources.MYSTIC_TRADER: market_manager.toggle_item_lock(ItemManager.pressed_slot)
			ItemContainerResources.TINKER: character_manager.try_to_tinker(ItemManager.dragged_item_slot)
			ItemContainerResources.SPLIT: character_manager.split_item(ItemManager.dragged_item_slot)
			ItemContainerResources.SELL: market_manager.sell_dragged_item()



	if is_instance_valid(ItemManager.alt_pressed_slot) and not ItemManager.alt_pressed_slot == Empty.slot:
		var hovered_item: Item = ItemManager.hovered_slot.get_item()
		if not ItemUtils.is_valid(hovered_item):
			return

		if ItemManager.alt_pressed_slot.item_container.resource.move_to_inventory_on_alt_press:
			take_item(ItemManager.hovered_slot)

		match ItemManager.alt_pressed_slot.item_container.resource:
			ItemContainerResources.MARKET, ItemContainerResources.MERCHANT, ItemContainerResources.MYSTIC_TRADER:
				market_manager.try_to_buy_item(ItemManager.hovered_slot.item_container, ItemManager.hovered_slot.index)

			ItemContainerResources.INVENTORY:
				if hovered_item.has_transformer_stat():
					activate_insightus(memory.local_player, ItemManager.hovered_slot)

				if hovered_item.resource.is_stat_adapter():
					adapt_stat(memory.local_player, ItemManager.hovered_slot)

				if hovered_item.resource.is_tome():
					use_tome(memory.local_player, ItemManager.hovered_slot)



func take_item(from_slot: Slot) -> void :
	ItemManager.try_to_swap_items(from_slot, Slot.new(memory.local_player.inventory, memory.local_player.inventory.get_first_empty_idx()))




func activate_insightus(player: Player, slot: Slot) -> void :
	var selected_player: Player = get_selected_player()
	var item: Item = slot.get_item()

	player.activate_insightus(slot)

	play_item_dissolve(player, slot)
	slot.remove_item(ItemContainer.ItemRemoveCause.INSIGHTUS_ACTIVATED)

	if selected_player == player:
		update_item_slots()



func adapt_stat(player: Player, slot: Slot) -> void :
	var selected_player: Player = get_selected_player()
	var item: Item = slot.get_item()

	player.adapt_stat(slot)

	play_item_dissolve(player, slot)
	slot.remove_item(ItemContainer.ItemRemoveCause.STAT_ADPTED)

	if selected_player == player:
		update_item_slots()





func use_tome(player: Player, slot: Slot) -> void :
	var selected_player: Player = get_selected_player()
	var item: Item = slot.get_item()

	if not selected_player.can_learn_ability(item.resource.ability_to_learn):
		return

	player.learn_ability(slot)

	play_item_dissolve(player, slot)
	slot.remove_item(ItemContainer.ItemRemoveCause.LEARNED_ABILITY)

	if selected_player == player:
		update_item_slots()





func banish_item(player: Player, slot: Slot) -> void :
	var selected_player: Player = get_selected_player()
	var item: Item = slot.get_item()

	player.banish_item(slot)
	play_item_dissolve(player, slot)
	slot.remove_item(ItemContainer.ItemRemoveCause.BANISHED)

	if selected_player == player:
		update_item_slots()



func upgrade_merchant(player: Player, slot: Slot) -> void :
	var selected_player: Player = get_selected_player()
	var item: Item = slot.get_item()

	player.merchant_level += 1
	play_item_dissolve(player, slot)
	slot.remove_item(ItemContainer.ItemRemoveCause.MERCHANT_UPGRADED)

	if selected_player == player:
		update_item_slots()



func play_item_dissolve(character: Character, slot: Slot) -> void :
	var item_slot: ItemSlot = canvas_layer.get_item_slot(slot)
	var pos: Vector2 = UI.get_rect(item_slot).get_center()
	var selected_player: Player = get_selected_player()
	var item: Item = slot.get_item()

	if selected_player == character:
		AudioManager.play_sfx_at(preload("res://assets/sfx/banish.wav"), pos, 0.0, randf_range(1.0, 1.1))
		if selected_player == memory.local_player or slot.item_container.resource == ItemContainerResources.INVENTORY:
			canvas_layer.vfx_manager.create_banish_effect(item.resource.texture, item_slot)









func dismantle_item(item: Item, replicate: bool = true) -> void :
	UIManager.update_partner_containers()

	if not is_instance_valid(item):
		return

	if replicate:
		Net.call_func(MultiplayerManager.send_dismantle, [SaveSystem.get_data(item)])


	var bonus_stats: Array[BonusStat] = item.get_stats_to_dismantle()
	for player in memory.get_all_players():
		for bonus_stat in bonus_stats:
			character_manager.add_stat(player, bonus_stat)


	play_sfx(preload("res://assets/sfx/convert_to_battle_stats.wav"), 0.0, randf_range(1.0, 1.15))
	memory.dismantle.remove_item_at(0)
	update_all_ui()

	memory.dismantle_item_count += 1




func toggle_item(character: Character, idx: int) -> void :
	var selected_player: Player = get_selected_player()

	if not memory.partners.is_empty() and character == memory.local_player:
		Net.call_func(MultiplayerManager.toggle_item, [Lobby.get_client_id(), idx])


	var item: Item = character.inventory.get_item(idx)
	if not is_instance_valid(item):
		return

	item.toggled = not item.toggled

	if character == selected_player:
		update_item_slots()







func process_equipment_swap() -> void :
	var local_player: Player = memory.local_player

	if not equipped_slots.size():
		return

	var synergy_sets: Array[ItemSetResource] = []
	play_sfx(preload("res://assets/sfx/item_equip.wav"), 5, randf_range(1.0, 1.25))

	for slot in equipped_slots:
		if not is_instance_valid(slot):
			continue

		var item: Item = slot.get_item()

		if not is_instance_valid(item):
			continue

		for synergy_set in local_player.equipment.get_synergy_sets(item):
			if synergy_sets.has(synergy_set):
				continue
			synergy_sets.push_back(synergy_set)

	for idx in local_player.equipment.items.size():
		var item: Item = local_player.equipment.items[idx]
		if not is_instance_valid(item):
			continue

		for synergy_set in synergy_sets:
			if should_glow(item, synergy_set):
				var slot: Slot = Slot.new(local_player.equipment, idx)
				var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)
				if not is_instance_valid(item_texture_rect):
					continue
				item_texture_rect.item_glow_effect.glow()

	equipped_slots.clear()






func should_glow(item: Item, synergy_set: ItemSetResource) -> bool:
	for set_resource in item.resource.set_resources:
		if synergy_set == set_resource:
			return true

	for bonus_stat in item.resource.bonus_stats:
		for boosting_set in bonus_stat.boosting_sets:
			if synergy_set == boosting_set:
				return true

	return false





func can_convert_to_stats() -> bool:
	var items_to_convert: int = 0

	if not memory.local_player.market.get_item_count():
		return false

	for idx in memory.local_player.market.items.size():
		if can_convert_item(idx):
			items_to_convert += 1

	if not items_to_convert:
		return false


	return true








func process_loot_stash() -> void :
	var loot_stash_popup_container: LootStashPopupContainer = canvas_layer.loot_stash_popup_container
	var chat_popup_container: ChatPopupContainer = canvas_layer.chat_popup_container
	var loot_stash_button: LootStashButton = canvas_layer.loot_stash_button
	var selected_player: Player = get_selected_player()
	var item_count: int = memory.local_player.loot_stash.get_item_count()


	if not selected_player == memory.local_player:
		loot_stash_popup_container.animation_player.stop(true)
		loot_stash_popup_container.hide()
		return

	loot_stash_button.amount_label.target_value = item_count


	if not loot_stash_popup_container.visible:
		if loot_stash_button.is_pressed:
			loot_stash_popup_container.animation_player.play("show")
			chat_popup_container.animation_player.stop()
			chat_popup_container.hide()
		return


	loot_stash_popup_container.sell_close_button.text = T.get_translated_string("SELL ALL").to_upper()
	if not item_count:
		loot_stash_popup_container.sell_close_button.text = T.get_translated_string("CLOSE").to_upper()

	if loot_stash_button.is_pressed and loot_stash_popup_container.visible:
		loot_stash_popup_container.animation_player.stop()
		loot_stash_popup_container.hide()

	if loot_stash_popup_container.sell_close_button.is_pressed:
		loot_stash_popup_container.animation_player.stop(true)
		loot_stash_popup_container.hide()
		if item_count > 0:
			sell_all_loot_stash()
			update_item_slots()








func process_chat() -> void :
	var loot_stash_popup_container: LootStashPopupContainer = canvas_layer.loot_stash_popup_container
	var chat_popup_container: ChatPopupContainer = canvas_layer.chat_popup_container
	var chat_button: ChatButton = canvas_layer.chat_button

	chat_button.show()

	if memory.partners.is_empty():
		chat_button.hide()
		return

	if chat_popup_container.visible:
		chat_button.amount_label.target_value = 0

	if not chat_popup_container.visible:
		if chat_button.is_pressed:
			chat_popup_container.animation_player.play("show")
			loot_stash_popup_container.animation_player.stop()
			loot_stash_popup_container.hide()
		return

	if chat_button.is_pressed and chat_popup_container.visible:
		chat_popup_container.animation_player.stop()
		chat_popup_container.hide()
		return






func update_market_popup() -> void :
	var market_popup_container: MarketPopupContainer = canvas_layer.market_popup_container
	market_popup_container.market_items = Items.get_resources(Items.MARKET, memory.floor_number)

	for banned_item in memory.local_player.banned_items:
		market_popup_container.market_items.erase(banned_item)

	market_popup_container.local_player = memory.local_player
	market_popup_container.update()



func open_market_popup() -> void :
	var market_popup_container: MarketPopupContainer = canvas_layer.market_popup_container
	var market_button: GenericButton = canvas_layer.market_button

	if not market_popup_container.visible and market_button.is_pressed:
		update_market_popup()
		market_popup_container.animation_player.play("show")
		return







func process_turn_timer(battle: Battle) -> void :
	var turn_timer: TurnTimer = canvas_layer.room_screen.turn_timer
	if not memory.is_turn_timer_active():
		turn_timer.hide()
		return

	turn_timer.show()
	turn_timer.max_value = int(battle.turn_time)
	turn_timer.value = int(battle.turn_time_left)
	turn_timer.label.text = "%02d" % maxi(0, battle.turn_time_left)




func process_external_stats(battle: Battle) -> void :
	var external_stats: Array[Stat] = []

	for player in memory.get_all_players():
		player.battle_profile.external_stats = external_stats





func sell_all_loot_stash() -> void :
	var slots: Array[Slot] = []

	for idx in memory.local_player.loot_stash.items.size():
		var item: Item = memory.local_player.loot_stash.items[idx]
		if not is_instance_valid(item):
			continue

		var slot = Slot.new()
		slot.item_container = memory.local_player.loot_stash
		slot.index = idx
		slots.push_back(slot)

	market_manager.try_to_sell_items(slots)





func create_damage_popup(battle: Battle, damage_result: DamageResult) -> void :
	if not is_instance_valid(damage_result.result_type):
		return

	var target: Character = DamageResult.get_ref(damage_result.target)

	if is_instance_valid(target) and memory.is_player(target):
		var action_popup_label_data: PopupLabelData = damage_result.result_type.get_action_popup_label_data()

		if not is_instance_valid(action_popup_label_data):
			return

		if damage_result.result_type == BattleActions.HIT:
			action_popup_label_data.color = damage_result.damage_type.color
			action_popup_label_data.left_texture = damage_result.damage_type.icon
			action_popup_label_data.text = Format.number(damage_result.uncapped_total_damage)

		canvas_layer.create_popup_label(action_popup_label_data, battle_manager.get_battle_wait_time(action_popup_label_data.delay))
		return


	var enemy_idx: int = battle.get_enemy_idx_from_character(target)
	var enemy_container: EnemyContainer = canvas_layer.room_screen.get_enemy_container(enemy_idx)
	var pos: Vector2 = UI.get_rect(enemy_container.selection_rect).get_center()

	canvas_layer.vfx_manager.create_enemy_popup_label_from_damage_result(
		pos + Vector2(randf_range(-15, 15), 
		randf_range(-15, 15)), 
		damage_result
		)




func create_enemy_popup_label(enemy: Character, text: String, color: Color, texture: Texture2D) -> void :
	var battle = memory.battle
	if not is_instance_valid(battle):
		return
	battle = battle as Battle

	var enemy_idx: int = battle.get_enemy_idx_from_character(enemy)
	var enemy_container: EnemyContainer = canvas_layer.room_screen.get_enemy_container(enemy_idx)
	var pos: Vector2 = UI.get_rect(enemy_container.selection_rect).get_center()

	canvas_layer.vfx_manager.create_small_popup_label(
		pos + Vector2(randf_range(-15, 15), randf_range(-15, 15)), 
		text, 
		color, 
		texture, 
		)




func create_stat_added_popup(stat: BonusStat) -> void :
	var format_rules: Array[Format.Rules] = [Format.Rules.USE_PREFIX]

	if stat.is_modifier or stat.resource.is_percentage:
		format_rules.push_back(Format.Rules.PERCENTAGE)

	var stat_name: String = T.get_translated_string(stat.resource.name, "Stat Name")
	var popup_label_data = PopupLabelData.new(Format.number(stat.amount, format_rules) + " " + stat_name, stat.resource.color)
	popup_label_data.right_texture = stat.resource.icon
	canvas_layer.create_popup_label(popup_label_data)







func copy_stats(target: Character, stealer: Character) -> void :
	for stat in target.stats:
		stealer.add_stat(stealer.battle_profile.stats, stat)
		if stealer == memory.local_player:
			var bonus_stat = BonusStat.new()
			BonusStat.apply_stat(bonus_stat, stat)
			create_stat_added_popup(bonus_stat)




func update_room_processor():
	var curr_room: RoomResource = memory.room_type

	if is_instance_valid(room_processor):
		remove_child(room_processor)
		room_processor.queue_free()

	if not is_instance_valid(curr_room.processor_script):
		print("error: no processor scriopt, ", curr_room.resource_path)
		return

	var new_room_processor: RoomProcessor = curr_room.processor_script.new() as RoomProcessor
	new_room_processor.set_gameplay_state(self)
	room_processor = new_room_processor
	add_child(new_room_processor)
	room_processor.initialize()



func setup_new_room() -> void :
	var speed: float = 0.5 + (battle_manager.battle_speed * 0.5)
	canvas_layer.screen_transition.end(1.45 / speed)
	canvas_layer.room_screen.camera_3d_animation_player.play("RESET")

	memory.update_room_type()
	match memory.room_type:
		Rooms.MERCHANT: market_manager.refresh_market(ItemContainerResources.MERCHANT)


	update_room_processor()
	room_screen.update_room(memory.room_type)

	memory.cleanup_battle()

	var battle = Battle.new()
	canvas_layer.battle_log_tab_container.reset_for_new_battle()
	memory.battle = battle


	if memory.room_type == Rooms.BATTLE:
		memory.battle.turn_time = 15
	memory.battle.turn_time_left = memory.battle.turn_time


	for player in memory.get_all_players():
		player.battle_profile = BattleProfile.new()
		player.enemy_upgrades_this_room = 0
		player.refresh_count = 0
		player.left_room = false


	character_manager.try_to_rest()
	memory.spawn_enemies()


	for enemy in battle.enemies_to_battle:
		battle_manager.process_entering_combat(battle, enemy)

	reset_enemy_containers(battle)
	battle.update_enemy_selection()

	SaveSystem.load_data(phantom_memory, SaveSystem.get_data(memory))

	battle.setup_in_progress = false






func reset_enemy_containers(battle: Battle) -> void :
	for child in room_screen.enemy_container_holder.get_children():
		room_screen.enemy_container_holder.remove_child(child)
		child.queue_free()

	for idx in battle.enemies_to_battle.size():
		var enemy_container: EnemyContainer = preload("res://scenes/ui/enemy_container/enemy_container.tscn").instantiate()
		var next_enemy: Enemy = battle.next_enemies[idx]
		var enemy: Enemy = battle.enemies_to_battle[idx]
		room_screen.enemy_container_holder.add_child(enemy_container)

		if not is_instance_valid(enemy) or enemy.out_of_combat:
			enemy_container.hide()
			continue

		enemy_container.set_texture(enemy.resource.texture)

		if is_instance_valid(next_enemy):
			enemy_container.next_enemy_texture_rect.texture = next_enemy.resource.texture
			enemy_container.next_enemy_layer.show()

		UIManager.update_enemy(battle, idx)

	room_screen.enemy_container_holder.update(1.0)

	process_cover()





func fix_confusion_effect() -> void :
	var local_player: Player = memory.local_player

	if local_player.battle_profile.is_confused():
		canvas_layer.room_screen.set_confusion(true)
		return

	canvas_layer.room_screen.set_confusion(false)




func update_enemy_containers(battle: Battle) -> void :
	for idx in room_screen.enemy_container_holder.get_child_count():
		UIManager.update_enemy(battle, idx)




func change_floor_number(amount: int, silent: bool):
	var local_player: Player = memory.local_player

	if amount > 0 and not silent:
		play_sfx(preload("res://assets/sfx/difficulity_level_increase.wav"), -2.5)
		play_sfx(preload("res://assets/sfx/enter_the_dungeon.wav"), 2.5)


	for floor_to_add in amount:
		memory.floor_number = max(0, memory.floor_number + 1)

	for player in memory.get_all_players():
		player.floor_number = memory.floor_number
		player.floor_refresh_count = 0
		character_manager.add_diamonds(player, 1, true)

		for idx in player.market.challenge_locked_indexes:
			var discount_multiply: float = 1 + (0.1 * amount)
			player.market.items[idx].discount = minf(0.95, player.market.items[idx].discount * discount_multiply)


	if memory.floor_number % 5 == 0:
		UserData.create_backup(memory_slot_idx)


	frozen_run_time = memory.run_time
	run_time_freeze = 1.0

	memory.room_idx = 0


	if memory.game_mode == GameModes.CHALLENGE:
		for floor_number in memory.floor_number:
			var achievement_name: String = local_player.adventurer.name.to_upper() + "_" + (AdventurerBorder.Type.keys()[AdventurerBorder.get_type(local_player.adventurer, floor_number)] as String).to_upper()
			ISteam.get_achievement(achievement_name)

	ISteam.update_rich_presence_floor(memory.local_player.floor_number)


	if not memory.game_mode == GameModes.PRACTICE:
		UserData.profile.set_floor_record(
			memory.local_player.adventurer, 
			memory.floor_number
			)




	UIManager.update_player_status_effects(get_selected_player())
	UIManager.update_difficulity_progress_bar()
	UIManager.update_partner_containers()

	update_item_slots()
	setup_new_room()
	update_music()





func update_music() -> void :
	var start_track: Music = memory.get_music_start_track()
	start_track.fade_speed = 1.75

	AudioManager.play_music(start_track)
	await get_tree().create_timer(start_track.stream.get_length()).timeout

	if AudioManager.music_player_priority[0].stream == memory.get_music_start_track().stream:
		AudioManager.play_music(memory.get_music_loop_track())






func create_upgrade_effect(slot: Slot) -> void :
	var position: Vector2 = UI.get_rect(canvas_layer.get_item_texture_rect(slot)).get_center()
	canvas_layer.vfx_manager.create_upgrade_effect(position)
	AudioManager.play_sfx_at(preload("res://assets/sfx/hammer.wav"), position, -2.5, 1.25)
	await get_tree().create_timer(0.05).timeout
	AudioManager.play_sfx_at(preload("res://assets/sfx/gain_xp.wav"), position, -5.0)







func update_all_ui():
	if not is_instance_valid(memory.local_player):
		return

	var battle_speed_container: BattleSpeedContainer = canvas_layer.room_screen.battle_speed_container
	var selected_adventurer: Adventurer = get_selected_adventurer()
	var selected_player: Player = get_selected_player()

	canvas_layer.equipment_slot_preview_container.update_slots(selected_adventurer.sockets)

	var equipment_locked: bool = character_manager.can_swap_equipment(selected_player) == ItemPressResult.Type.DISABLED
	for preview_equipmnet_slot in canvas_layer.equipment_slot_preview_container.equipment_slot_preview_nodes:
		preview_equipmnet_slot.update_texture(equipment_locked)


	canvas_layer.update_health_info(selected_player)
	canvas_layer.update_armor_info(selected_player)

	UIManager.update_player_status_effects(selected_player)
	UIManager.update_mana_info(selected_player)

	UIManager.update_gold_coins(selected_player)
	UIManager.update_diamonds(selected_player)
	UIManager.update_difficulity_progress_bar()
	UIManager.update_player_portraits(selected_player)
	UIManager.update_partner_containers()
	update_stat_info()

	update_parter_container_lock()

	battle_speed_container.set_battle_speed(options.battle_speed)
	update_item_slots()






func update_upgrade_mark_visuals(selected_player: Player) -> void :
	for item_container in memory.get_item_containers(selected_player):
		for index in item_container.items.size():
			var slot: Slot = Slot.new(item_container, index)
			var item: Item = slot.get_item()

			if not is_instance_valid(item):
				continue

			if item.is_reforge:
				continue



			var success: bool = false
			for test_item_container in memory.get_item_containers(memory.local_player):
				if success:
					break

				for test_index in test_item_container.items.size():
					var test_slot: Slot = Slot.new(test_item_container, test_index)
					var test_item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(test_slot)
					var test_item: Item = test_slot.get_item()

					if not is_instance_valid(test_item):
						continue

					if not is_instance_valid(test_item_texture_rect):
						continue

					if test_slot == slot:
						continue

					if test_item.is_tinker_kit:
						continue

					if not ItemManager.can_merge(test_slot, slot):
						continue

					success = true
					break




			if success:
				var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)

				if not is_instance_valid(item_texture_rect):
					continue

				var next_rarity: int = mini(item.rarity + 1, ItemRarity.Type.DIVINE)
				var outline_color: Color = ItemRarity.get_outline_color(next_rarity)
				if outline_color == Color.TRANSPARENT:
					outline_color = Color("#0b0f17")

				item_texture_rect.set_upgrade_mark_main_color(ItemRarity.get_font_color(next_rarity))
				item_texture_rect.set_upgrade_mark_outline_color(outline_color)
				item_texture_rect.upgrade_mark_texture_rect.show()







func update_item_slots() -> void :
	var selected_player: Player = get_selected_player()
	var item_containers: Array[ItemContainer] = selected_player.get_item_containers()
	item_containers.push_back(memory.dismantle)

	if canvas_layer.loot_stash_popup_container.visible:
		item_containers.push_back(memory.local_player.loot_stash)


	canvas_layer.update_item_slots(item_containers, ItemManager.dragged_item_slot)
	for item_container in item_containers:
		for idx in item_container.items.size():
			process_burnout_visuals(selected_player, Slot.new(item_container, idx))

	update_upgrade_mark_visuals(selected_player)
	hover_info_update_request = true

	process_equipment_swap()






func update_stat_info() -> void :
	if not is_instance_valid(memory.local_player):
		return

	var selected_player: Player = get_selected_player()

	UIManager.update_stats_scroll_container(selected_player)
	canvas_layer.update_health_info(selected_player)
	canvas_layer.update_armor_info(selected_player)
	UIManager.update_attack_container()










func create_equip_warning(text: String) -> void :
	var set_limit_warning = preload("res://scenes/ui/equip_warning/equip_warning.tscn").instantiate()
	set_limit_warning.position = Vector2(90, 100)
	set_limit_warning.text = text
	canvas_layer.warning_holder.add_child(set_limit_warning)





func get_selected_player() -> Player:
	if is_instance_valid(locked_partner):
		return locked_partner


	for partner_container_holder in [room_screen.partner_container_holder]:
		if partner_container_holder.hovered_partner_idx == -1:
			continue

		var partner: Player = memory.partners[partner_container_holder.hovered_partner_idx]
		if is_instance_valid(partner):
			return partner


	if not is_instance_valid(memory.local_player):
		return null

	return memory.local_player




func get_selected_adventurer() -> Adventurer:
	var selected_player: Player = get_selected_player()
	return selected_player.adventurer




func get_hovered_slot() -> Slot:
	if not is_instance_valid(memory.local_player):
		return Empty.slot


	for idx in memory.partners.size():
		for partner_container_holder in [room_screen.partner_container_holder]:
			var parter_container: PartnerContainer = partner_container_holder.get_child(idx)
			if UI.is_hovered(parter_container):
				return Slot.new(ItemContainer.new(ItemContainerResources.PARTNER))


	for item_container_module in get_tree().get_nodes_in_group("item_container_module"):
		item_container_module = item_container_module as ItemContainerModule
		if UI.is_hovered(item_container_module.get_parent()):
			return Slot.new(ItemContainer.new(item_container_module.item_container_resource))


	if UI.is_hovered(canvas_layer.hub_action_panel.sell_container):
		return Slot.new(ItemContainer.new(ItemContainerResources.SELL))

	if UI.is_hovered(canvas_layer.hub_action_panel.split_container):
		return Slot.new(ItemContainer.new(ItemContainerResources.SPLIT))


	for container in ItemContainerResources.GAMEPLAY_ITEM_CONTAINERS:
		var item_slots: Array[ItemSlot] = canvas_layer.get_item_slots(container)
		for idx in item_slots.size():
			var item_slot: ItemSlot = item_slots[idx]
			var is_hovered: bool = false

			if UI.is_hovered(item_slot):
				is_hovered = true

			if not is_hovered and item_slot.has_item_texture():
				var item_texture_rect = item_slot.get_item_texture_rect()
				if item_texture_rect.hovering:
					is_hovered = true

			if not is_hovered:
				continue

			var slot = Slot.new()
			slot.index = idx

			for player_container in memory.local_player.get_item_containers():
				if player_container.resource == container:
					slot.item_container = player_container

			match container:
				ItemContainerResources.DISMANTLE: slot.item_container = memory.dismantle

			return slot


	return Empty.slot





func play_sfx(audio_stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void :
	var tone_event: ToneEventResource = ToneEventResource.new()
	var tone = Tone.new(audio_stream, volume_db)
	tone_event.tones.push_back(tone)
	tone.pitch_min = pitch_scale
	tone.pitch_max = pitch_scale
	AudioManager.play_event(tone_event, name)




func setup_rng() -> void :
	RNGManager.gameplay_rand.state = memory.gameplay_rand_state
	RNGManager.market_rand.state = memory.market_rand_state
	RNGManager.enemy_rand.state = memory.enemy_rand_state
	RNGManager.set_base_seed(memory.tower_seed)


func save() -> void :
	memory.last_save_time = Time.get_datetime_string_from_system()
	memory.gameplay_rand_state = RNGManager.gameplay_rand.state
	memory.market_rand_state = RNGManager.market_rand.state
	memory.enemy_rand_state = RNGManager.enemy_rand.state
	UserData.save_memory_slot(memory_slot_idx)



func reset_battle_manager() -> void :
	battle_manager.queue_free()
