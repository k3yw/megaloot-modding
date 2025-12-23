extends Node

enum TurnRequestResult{OK, INVALID_TURN, OLD_TURN}


var state_sync_queue: Array[StateSyncData] = []
var methods_queue: Array[Callable] = []



var received_room_actions: Array[RoomActionData] = []
var received_states: Array[PackedInt64Array] = []
var confirmed_turns: Dictionary = {}

var room_action_buffer: Array[RoomActionData] = []



class StateSyncData extends Object:
	var enemies_to_battle: Array[Enemy] = []
	var next_enemies: Array[Enemy] = []
	var floor_state: PackedInt64Array



class RoomActionData extends Object:
	var rng_states: PackedInt64Array
	var room_action: RoomAction.Type
	var turn_type: BattleTurn.Type
	var selected_enemy_idx: int
	var client_id: int = -1
	var floor_number: int
	var turn_number: int
	var room_idx: int

	func get_floor_state() -> PackedInt64Array:
		return [floor_number, room_idx, turn_number] as PackedInt64Array

	func is_outdated(floor_state: PackedInt64Array) -> bool:
		if floor_number < floor_state[0]:
			return true

		if floor_number == floor_state[0]:
			if room_idx < floor_state[1]:
				return false

			if room_idx == floor_state[1]:
				if turn_number < floor_state[2]:
					return false

		return false



func _ready() -> void :
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

	StateManager.state_changed.connect( func():
		clear_all_sync_data()
	)


	GDSync.expose_func(try_to_add_to_room_action_buffer)
	GDSync.expose_func(send_request_to_dismantle)
	GDSync.expose_func(send_accept_dismantle)
	GDSync.expose_func(pop_from_sell_stack)
	GDSync.expose_func(send_skip_dismantle)
	GDSync.expose_func(add_to_buy_history)
	GDSync.expose_func(add_to_turn_queue)
	GDSync.expose_func(sync_locked_items)
	GDSync.expose_func(add_to_sell_stack)
	GDSync.expose_func(clear_sell_stack)
	GDSync.expose_func(set_battle_speed)
	GDSync.expose_func(send_room_action)
	GDSync.expose_func(send_dismantle)
	GDSync.expose_func(remove_banish)
	GDSync.expose_func(upgrade_enemy)
	GDSync.expose_func(confirm_turn)
	GDSync.expose_func(discard_turn)
	GDSync.expose_func(process_turn)
	GDSync.expose_func(remove_item)
	GDSync.expose_func(enter_tower)
	GDSync.expose_func(update_item)
	GDSync.expose_func(toggle_item)
	GDSync.expose_func(sync_state)
	GDSync.expose_func(leave_room)
	GDSync.expose_func(send_item)
	GDSync.expose_func(sync_gold_coins)
	GDSync.expose_func(sync_diamonds)
	GDSync.expose_func(add_item)


	while true:
		var curr_state = StateManager.get_current_state()
		await process_methods_queue(curr_state)
		await process_room_action_queue(curr_state)

		await get_tree().process_frame




func process_methods_queue(curr_state: Node) -> void :
	for idx in range(methods_queue.size() - 1, -1, -1):
		var method: Callable = methods_queue[idx]

		if not is_instance_valid(curr_state):
			return

		if not curr_state is GameplayState:
			return

		await method.call()
		methods_queue.remove_at(idx)



func clear_all_sync_data() -> void :
	for state in state_sync_queue:
		state.free()
	state_sync_queue.clear()
	confirmed_turns.clear()
	received_states.clear()
	clear_old_room_actions()



func clear_old_room_actions() -> void :
	for room_action_data in room_action_buffer:
		room_action_data.free()
	received_room_actions.clear()
	room_action_buffer.clear()




func process_room_action_queue(curr_state: Node) -> void :
	var room_action_queue: Array[RoomActionData] = room_action_buffer.duplicate()
	var curr_idx: int = room_action_queue.size()
	room_action_buffer.clear()


	while room_action_queue.size() > 0:
		await get_tree().process_frame
		curr_idx -= 1
		if curr_idx < 0:
			curr_idx = room_action_queue.size() - 1

		var room_action_data: RoomActionData = room_action_queue[curr_idx]

		print("turn to process: ", room_action_data.floor_number, ", ", room_action_data.room_idx, ", ", room_action_data.turn_number)


		if not can_process_turn():
			for room_action in room_action_queue:
				room_action.free()
			room_action_queue.clear()
			return

		curr_state = curr_state as GameplayState

		print("curr turn: ", 
		curr_state.memory.floor_number, ", ", 
		curr_state.memory.room_idx, ", ", 
		curr_state.memory.battle.current_turn)

		if not is_instance_valid(curr_state.memory.battle):
			continue

		var battle_manager: BattleManager = curr_state.battle_manager
		var battle: Battle = curr_state.memory.battle
		print("processing turn: ", battle.current_turn)


		while room_action_data.floor_number > curr_state.memory.floor_number or room_action_data.room_idx > curr_state.memory.room_idx:
			print("recieved future state")
			var has_curr_state: bool = false
			for test_room_action in room_action_queue:
				if test_room_action.get_floor_state() == curr_state.memory.get_floor_state():
					has_curr_state = true
					break

			if not has_curr_state:
				await curr_state.battle_manager.clear_room(curr_state.memory.battle)
				await curr_state.try_to_advance(curr_state.memory.battle)

		if not is_instance_valid(battle):
			continue

		if room_action_data.is_outdated(curr_state.memory.get_floor_state()):
			print("removing outdated room_action_data")
			remove_from_room_action_queue(room_action_queue, curr_idx)
			continue

		if not room_action_data.floor_number == curr_state.memory.floor_number:
			print("processing turn failed code: 1")
			continue

		if not room_action_data.room_idx == curr_state.memory.room_idx:
			print("processing turn failed code: 2")
			continue

		if not room_action_data.turn_number == battle.current_turn:
			print("processing turn failed code: 3")
			continue


		match room_action_data.room_action:
			RoomAction.Type.END_GAME:
				await curr_state.try_to_end_game()
				return

			RoomAction.Type.BATTLE:
				if not await try_to_accept_turn(room_action_data):
					continue
				await process_state_sync(curr_state)

			RoomAction.Type.OPEN_CHEST:
				var player: Player = curr_state.memory.get_player_from_client_id(room_action_data.client_id)
				await curr_state.open_chest(curr_state.memory.battle, player)

			RoomAction.Type.SKIP_CHEST:
				var player: Player = curr_state.memory.get_player_from_client_id(room_action_data.client_id)
				await curr_state.leave_chest_room(curr_state.memory.battle, player)

			RoomAction.Type.ACTIVATE_ENDLESS:
				curr_state.memory.is_endless = true
				leave_room(-1, true)


		remove_from_room_action_queue(room_action_queue, curr_idx)



func process_state_sync(curr_state: GameplayState) -> void :
	if Lobby.is_lobby_owner():
		return

	while not state_sync_queue.size():
		await get_tree().process_frame

	for idx in range(state_sync_queue.size() - 1, -1, -1):
		var state_sync_data: StateSyncData = state_sync_queue[idx]

		if not can_process_turn() or not is_instance_valid(curr_state):
			for state in state_sync_queue:
				state.free()
			state_sync_queue.clear()
			return

		var battle: Battle = curr_state.memory.battle

		if not is_instance_valid(state_sync_data):
			print("removing invalid enemy sync data")
			state_sync_queue.remove_at(idx)
			state_sync_data.free()
			break


		if await process_state_sync_data(state_sync_data, battle):
			state_sync_queue.remove_at(idx)
			state_sync_data.free()








func can_process_turn() -> bool:
	var curr_state = StateManager.get_current_state()

	if not is_instance_valid(curr_state):
		return false

	if not curr_state is GameplayState:
		return false

	curr_state = curr_state as GameplayState

	return true







func remove_from_room_action_queue(room_action_queue: Array[RoomActionData], idx: int) -> void :
	if room_action_queue.size() - 1 < idx:
		return

	var room_action_data: RoomActionData = room_action_queue[idx]
	room_action_queue.remove_at(idx)
	room_action_data.free()




func process_state_sync_data(state_sync_data: StateSyncData, battle: Battle) -> bool:
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return false
	curr_state = curr_state as GameplayState


	if not state_sync_data.floor_state[0] == curr_state.memory.floor_number:
		print("old state sync, error: 1")
		if state_sync_data.floor_state[0] < curr_state.memory.floor_number:
			return true
		return false

	if not state_sync_data.floor_state[1] == curr_state.memory.room_idx:
		print("old state sync, error: 2")
		if state_sync_data.floor_state[1] < curr_state.memory.room_idx:
			return true
		return false

	if not state_sync_data.floor_state[2] == battle.current_turn:
		print("old state sync, error: 3")
		if state_sync_data.floor_state[2] < battle.current_turn:
			return true
		return false


	battle.cleanup_enemies()
	battle.enemies_to_battle = state_sync_data.enemies_to_battle
	battle.next_enemies = state_sync_data.next_enemies


	var visible_enemy_containers: Array[EnemyContainer] = curr_state.room_screen.enemy_container_holder.get_visible_containers()
	if not visible_enemy_containers.size() == battle.get_enemies_in_combat().size():
		curr_state.reset_enemy_containers(battle)


	for idx in 3:
		UIManager.update_enemy(battle, idx)


	await curr_state.battle_manager.try_to_complete_battle(battle)
	await curr_state.try_to_advance(battle)
	return true




func enter_tower(sender_id: int = -1) -> void :
	var curr_state = StateManager.get_current_state()

	while not curr_state is GameplayState:
		await get_tree().process_frame
		if not curr_state is GameplayState:
			return

	if not curr_state.memory.room_idx == -1:
		return

	print("log: entering the tower")
	curr_state.advance()

	if sender_id == -1:
		Net.call_func(enter_tower, [sender_id])





func set_battle_speed(new_battle_speed: int) -> void :
	var curr_state = StateManager.get_current_state()

	if not is_instance_valid(curr_state) or not curr_state is GameplayState:
		methods_queue.push_front(set_battle_speed.bind(new_battle_speed))
		return

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	var battle_speed_container: BattleSpeedContainer = curr_state.canvas_layer.room_screen.battle_speed_container
	curr_state.options.battle_speed = new_battle_speed as Options.BattleSpeed
	battle_speed_container.set_battle_speed(curr_state.options.battle_speed)
	curr_state.options.save()





func sync_gold_coins(sender_id: int, gold_coins: float) -> void :
	var curr_state = StateManager.get_current_state()
	var selected_player: Player = null
	var partner: Player = null


	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	selected_player = curr_state.get_selected_player()

	if selected_player == curr_state.memory.local_player:
		selected_player = null

	partner = curr_state.memory.get_partner(sender_id)


	if is_instance_valid(partner):
		partner.gold_coins = gold_coins

		if is_instance_valid(selected_player):
			UIManager.update_gold_coins(selected_player)






func sync_diamonds(sender_id: int, diamonds: float) -> void :
	var curr_state = StateManager.get_current_state()
	var selected_player: Player = null
	var partner: Player = null


	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	selected_player = curr_state.get_selected_player()

	if selected_player == curr_state.memory.local_player:
		selected_player = null

	partner = curr_state.memory.get_partner(sender_id)


	if is_instance_valid(partner):
		partner.diamonds = diamonds

		if is_instance_valid(selected_player):
			UIManager.update_diamonds(selected_player)







func sync_locked_items(sender_id: int, container_resource_path: String, challenge_locked_indexes: PackedInt64Array, locked_indexes: PackedInt64Array) -> void :
	var curr_state = StateManager.get_current_state()
	var partner: Player = null

	curr_state = curr_state as GameplayState
	partner = curr_state.memory.get_partner(sender_id)

	if is_instance_valid(partner):
		match container_resource_path:
			ItemContainerResources.MERCHANT.resource_path: partner.merchant.locked_indexes = locked_indexes
			ItemContainerResources.MARKET.resource_path:
				partner.market.challenge_locked_indexes = challenge_locked_indexes
				partner.market.locked_indexes = locked_indexes






func update_item(sender_id: int, container_resource_path: String, item_data: Dictionary, idx: int) -> void :
	var curr_state = StateManager.get_current_state()
	var selected_player: Player = null
	var partner: Player = null

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	var battle: Battle = curr_state.memory.battle
	while not is_instance_valid(battle):
		await get_tree().process_frame

	while battle.turn_in_progress:
		await get_tree().process_frame

	selected_player = curr_state.get_selected_player()
	if selected_player == curr_state.memory.local_player:
		selected_player = null

	partner = curr_state.memory.get_partner(sender_id)


	var item: Item = Item.new()
	SaveSystem.load_data(item, item_data)
	if item_data == {}:
		item = null


	if not is_instance_valid(partner):
		return

	for container in partner.get_item_containers():
		if not container_resource_path == container.resource.resource_path:
			continue
		container.items[idx] = item

	if container_resource_path == ItemContainerResources.EQUIPMENT.resource_path:
		curr_state.character_manager.try_to_rest()


	if is_instance_valid(selected_player):
		UIManager.update_item_slots()






func add_item(sender_id: int, container_resource_path: String, item_data: Dictionary, idx: int) -> void :
	var curr_state = StateManager.get_current_state()
	var selected_player: Player = null
	var partner: Player = null


	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	selected_player = curr_state.get_selected_player()
	if selected_player == curr_state.memory.local_player:
		selected_player = null

	partner = curr_state.memory.get_partner(sender_id)


	if not is_instance_valid(partner):
		return

	var item: Item = Item.new()
	SaveSystem.load_data(item, item_data)
	if item_data == {}:
		item = null


	for container in partner.get_item_containers():
		if not container_resource_path == container.resource.resource_path:
			continue
		container.add_item_at(idx, item)

	match container_resource_path:
		ItemContainerResources.EQUIPMENT.resource_path:
			curr_state.character_manager.try_to_rest()


	if is_instance_valid(selected_player):
		UIManager.update_item_slots()




func remove_item(sender_id: int, container_resource_path: String, idx: int, cause: ItemContainer.ItemRemoveCause) -> void :
	var curr_state = StateManager.get_current_state()
	var selected_player: Player = null

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	var partner: Player = curr_state.memory.get_partner(sender_id)

	selected_player = curr_state.get_selected_player()
	if selected_player == curr_state.memory.local_player:
		selected_player = null


	if not is_instance_valid(partner):
		return

	for container in partner.get_item_containers():
		if not container_resource_path == container.resource.resource_path:
			continue

		match cause:
			ItemContainer.ItemRemoveCause.BANISHED:
				partner.banish_item(Slot.new(container, idx))
				break
				
			ItemContainer.ItemRemoveCause.BUYOUT:
				partner.buyout_item(Slot.new(container, idx))
				break

			ItemContainer.ItemRemoveCause.INSIGHTUS_ACTIVATED:
				activate_insightful(sender_id, Slot.new(container, idx))
				break

			ItemContainer.ItemRemoveCause.STAT_ADPTED:
				adapt_stat(sender_id, Slot.new(container, idx))
				break

			ItemContainer.ItemRemoveCause.MERCHANT_UPGRADED:
				upgrade_merchant(sender_id)
				break

			ItemContainer.ItemRemoveCause.LEARNED_ABILITY:
				partner.learn_ability(Slot.new(container, idx))
				break

		container.remove_item_at(idx)
		break


	if curr_state is GameplayState:
		if container_resource_path == ItemContainerResources.EQUIPMENT.resource_path:
			curr_state.character_manager.try_to_rest()

	if is_instance_valid(selected_player):
		UIManager.update_item_slots()




func remove_banish(sender_id: int, item_resource_path: String) -> void :
	var curr_state = StateManager.get_current_state()


	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	partner.banished_items.erase(load(item_resource_path))




func add_to_buy_history(sender_id: int, item_resource_path: String) -> void :
	var curr_state = StateManager.get_current_state()


	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	partner.add_to_buy_history(load(item_resource_path))



func add_to_recent_market_items(sender_id: int, item_resource_path: String) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	partner.add_to_recent_market_items(load(item_resource_path))



func upgrade_merchant(sender_id: int) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	partner.merchant_level += 1




func activate_insightful(sender_id: int, slot: Slot) -> void :
	var curr_state = StateManager.get_current_state()


	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	curr_state.activate_insightus(partner, slot)



func adapt_stat(sender_id: int, slot: Slot) -> void :
	var curr_state = StateManager.get_current_state()


	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	curr_state.adapt_stat(partner, slot)



func add_to_sell_stack(sender_id: int, item_data: Dictionary) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	var item: Item = Item.new()
	SaveSystem.load_data(item, item_data)
	partner.sell_stack.push_back(item)





func pop_from_sell_stack(sender_id: int) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	partner.sell_stack.pop_front()



func clear_sell_stack(sender_id: int) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	var partner: Player = curr_state.memory.get_partner(sender_id)
	if not is_instance_valid(partner):
		return

	partner.sell_stack.clear()






func send_item(sender_id: int, item_data: Dictionary) -> void :
	var curr_state = StateManager.get_current_state()
	var partner: Player = null

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	partner = curr_state.memory.get_partner(sender_id)

	var sender_name: String = ""
	if is_instance_valid(partner):
		sender_name = partner.get_translated_log_name()

	var item: Item = Item.new()
	SaveSystem.load_data(item, item_data)
	curr_state.character_manager.add_loot(item)
	curr_state.canvas_layer.create_item_received_popup(item, sender_name)









func toggle_item(sender_id: int, idx: int) -> void :
	var curr_state = StateManager.get_current_state()
	var selected_player: Player = null
	var partner: Player = null

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	selected_player = curr_state.get_selected_player()
	if selected_player == curr_state.memory.local_player:
		selected_player = null

	partner = curr_state.memory.get_partner(sender_id)


	if is_instance_valid(partner):
		curr_state.toggle_item(partner, idx)






func sync_state(enemies_to_battle: Array[Dictionary], next_enemies: Array[Dictionary], floor_state: PackedInt64Array) -> void :
	if received_states.has(floor_state):
		return
	received_states.push_back(floor_state)

	print("received state sync: ", floor_state)

	var state_sync_data = StateSyncData.new()
	state_sync_data.floor_state = floor_state


	for enemy_data in enemies_to_battle:
		var enemy: Enemy = Enemy.new()
		SaveSystem.load_data(enemy, enemy_data)
		state_sync_data.enemies_to_battle.push_back(enemy)
		enemy.cache_stats()

	for enemy_data in next_enemies:
		if enemy_data == {}:
			state_sync_data.next_enemies.push_back(null)
			continue

		var enemy: Enemy = Enemy.new()
		SaveSystem.load_data(enemy, enemy_data)
		state_sync_data.next_enemies.push_back(enemy)
		enemy.cache_stats()

	state_sync_queue.push_front(state_sync_data)





func send_turn(battle: Battle, turn_type: BattleTurn.Type) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	print(self, ": send_turn")

	if curr_state.memory.partners.is_empty():
		var battle_manager: BattleManager = curr_state.battle_manager
		await battle_manager.make_a_turn(battle, curr_state.memory.local_player, turn_type)
		return

	var floor_state: PackedInt64Array = curr_state.memory.get_floor_state()
	var selected_enemy_idx: int = battle.selected_enemy_idx

	if not Lobby.is_lobby_owner():
		var client_id: int = Lobby.get_client_id()
		print("sending turn: ", selected_enemy_idx)
		curr_state.character_manager.actions_blocked = true

		Net.call_func(process_turn, [client_id, selected_enemy_idx, turn_type, floor_state], [Lobby.get_host()])
		return

	process_turn(Lobby.get_host(), battle.selected_enemy_idx, turn_type, floor_state)





func discard_turn() -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	curr_state.character_manager.actions_blocked = false



func process_turn(sender_id: int, selected_enemy_idx: int, turn_type: BattleTurn.Type, floor_state: PackedInt64Array) -> void :
	var curr_state = StateManager.get_current_state()

	print("processing turn sender id: ", sender_id)
	if sender_id == -1:
		sender_id = Lobby.get_host()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	if not sender_id == Lobby.get_host():
		var player: Player = curr_state.memory.get_partner(sender_id)
		var turn_request_result: TurnRequestResult = turn_request_valid(player, selected_enemy_idx, floor_state)
		print(player.get_translated_log_name(), " sent turn request", " : ", selected_enemy_idx)

		if not turn_request_result == OK:
			Net.call_func(discard_turn, [], [sender_id])
			print("discarding turn, error: ", turn_request_result)
			return


	add_to_turn_queue(sender_id, selected_enemy_idx, turn_type, floor_state, RNGManager.get_states())

	confirmed_turns[floor_state] = []
	while confirmed_turns[floor_state].size() < curr_state.memory.partners.size():
		for partner in curr_state.memory.partners:
			if (confirmed_turns[floor_state] as Array).has(partner.client_id):
				continue
			Net.call_func(add_to_turn_queue, [sender_id, selected_enemy_idx, turn_type, floor_state, RNGManager.get_states()], [partner.client_id])
			print("sending add_to_turn_queue: ", floor_state)

		await get_tree().create_timer(1.0).timeout
		if not confirmed_turns.has(floor_state):
			break





func turn_request_valid(player: Player, selected_enemy_idx: int, floor_state: PackedInt64Array) -> TurnRequestResult:
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return TurnRequestResult.INVALID_TURN
	curr_state = curr_state as GameplayState

	var battle_manager: BattleManager = curr_state.battle_manager
	var battle: Battle = curr_state.memory.battle

	if floor_state[0] == curr_state.memory.floor_number and floor_state[1] == curr_state.memory.room_idx:
		if not battle_manager.has_battle_actions(player, selected_enemy_idx) == OK:
			return TurnRequestResult.INVALID_TURN


	if floor_state[0] < curr_state.memory.floor_number:
		return TurnRequestResult.OLD_TURN

	if floor_state[1] < curr_state.memory.room_idx:
		return TurnRequestResult.OLD_TURN

	if not is_instance_valid(battle):
		return TurnRequestResult.INVALID_TURN

	if floor_state[2] < battle.current_turn:
		return TurnRequestResult.OLD_TURN


	return TurnRequestResult.OK




func add_to_turn_queue(player_client_id: int, selected_enemy_idx: int, turn_type: BattleTurn.Type, floor_state: PackedInt64Array, rng_states: PackedInt64Array = []) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	var player: Character = curr_state.memory.get_partner(player_client_id)

	if not is_instance_valid(player):
		player = curr_state.memory.local_player
		if not is_instance_valid(player):
			return

	if not Lobby.is_lobby_owner():
		confirm_turn(Lobby.get_client_id(), floor_state)

	print("adding turn to queue: ", floor_state)

	var room_action_data = RoomActionData.new()
	room_action_data.floor_number = floor_state[0]
	room_action_data.room_idx = floor_state[1]
	room_action_data.turn_number = floor_state[2]
	room_action_data.selected_enemy_idx = selected_enemy_idx
	room_action_data.room_action = RoomAction.Type.BATTLE
	room_action_data.client_id = player.client_id
	room_action_data.rng_states = rng_states
	room_action_data.turn_type = turn_type

	try_to_add_to_room_action_buffer(SaveSystem.get_data(room_action_data))
	room_action_data.free()





func try_to_add_to_room_action_buffer(room_action_data_dict: Dictionary) -> bool:
	var buffered_room_action_data: RoomActionData = RoomActionData.new()
	var room_action_data: RoomActionData = RoomActionData.new()
	SaveSystem.load_data(buffered_room_action_data, room_action_data_dict)
	SaveSystem.load_data(room_action_data, room_action_data_dict)

	var floor_state: PackedInt64Array = room_action_data.get_floor_state()
	var is_limited_to_one: bool = true

	if room_action_data.room_action == RoomAction.Type.SKIP_CHEST:
		is_limited_to_one = false

	if is_limited_to_one:
		for received_room_action in received_room_actions:
			if not received_room_action.room_action == room_action_data.room_action:
				continue

			if received_room_action.get_floor_state() == floor_state:
				buffered_room_action_data.free()
				room_action_data.free()
				return false


	room_action_buffer.push_front(buffered_room_action_data)
	received_room_actions.push_front(room_action_data)

	return true








func try_to_accept_turn(room_action_data: RoomActionData) -> bool:
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return false
	curr_state = curr_state as GameplayState


	var player: Player = curr_state.memory.get_player_from_client_id(room_action_data.client_id)
	var player_to_battle: Character = curr_state.memory.get_player_to_battle()
	var has_battle_actions_result: int = curr_state.battle_manager.has_battle_actions(player, room_action_data.selected_enemy_idx)

	if not has_battle_actions_result == OK:
		print("has battle actions failed code: ", has_battle_actions_result)

	if not [OK, BattleManager.BattleActionFailResult.MP_PHANTOM].has(has_battle_actions_result):
		print("processing turn failed code: 4")
		return false


	if is_instance_valid(player_to_battle) and not player_to_battle == player:
		print("processing turn error code: 5")


	var battle_manager: BattleManager = curr_state.battle_manager
	var battle: Battle = curr_state.memory.battle
	print("accepting turn: ", battle.current_turn)

	RNGManager.sync_rng_states(room_action_data.rng_states)
	battle.initial_selected_enemy_idx = room_action_data.selected_enemy_idx
	await battle_manager.make_a_turn(battle, player, room_action_data.turn_type)

	return true







func send_request_to_dismantle(sender_id: int = -1) -> void :
	var curr_state = StateManager.get_current_state()
	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	if not curr_state.memory.dismantling_player_id.is_empty():
		return

	if Lobby.is_lobby_owner():
		Net.call_func(send_accept_dismantle, [sender_id])
		send_accept_dismantle(sender_id)
		return


	Net.call_func(send_request_to_dismantle, [sender_id], [Lobby.get_host()])




func send_accept_dismantle(sender_id: int) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState


	if curr_state.memory.local_player.client_id == sender_id:
		curr_state.memory.dismantling_player_id = curr_state.memory.local_player.profile_id
		return

	print("accepted dismantle request: ", sender_id)
	var partner: Player = curr_state.memory.get_partner(sender_id)
	if is_instance_valid(partner):
		curr_state.memory.dismantling_player_id = partner.profile_id





func send_dismantle(item_data: Dictionary) -> void :
	var curr_state = StateManager.get_current_state()
	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	var item: Item = Item.new()
	SaveSystem.load_data(item, item_data)
	curr_state.dismantle_item(item, false)



func send_skip_dismantle(replicate: bool = false) -> void :
	var curr_state = StateManager.get_current_state()
	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	if replicate:
		Net.call_func(send_skip_dismantle, [])

	curr_state.advance()





func send_room_action(sender_id: int, room_action: RoomAction.Type, floor_state: PackedInt64Array) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	if not is_instance_valid(curr_state.memory.battle):
		return

	if not Lobby.is_lobby_owner():
		Net.call_func(send_room_action, [sender_id, room_action, floor_state], [Lobby.get_host()])
		return

	var room_action_data = RoomActionData.new()
	room_action_data.floor_number = floor_state[0]
	room_action_data.room_idx = floor_state[1]
	room_action_data.turn_number = floor_state[2]
	room_action_data.room_action = room_action
	room_action_data.client_id = sender_id

	var room_action_data_dict: Dictionary = SaveSystem.get_data(room_action_data)
	room_action_data.free()

	if try_to_add_to_room_action_buffer(room_action_data_dict):
		Net.call_func(try_to_add_to_room_action_buffer, [room_action_data_dict])








func leave_room(sender_id: int = -1, skip_animation: bool = false) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	var player: Player = curr_state.memory.get_player_from_client_id(sender_id)
	var battle: Battle = curr_state.memory.battle

	if sender_id == -1:
		Net.call_func(leave_room, [Lobby.get_client_id()])
		player = curr_state.memory.local_player
		if is_instance_valid(player.enemy_upgrade.items[0]):
			curr_state.take_item(Slot.new(player.enemy_upgrade, 0))

	if player == curr_state.memory.local_player and curr_state.memory.game_mode == GameModes.PVP:
		var gold_reward: float = Balance.get_time_gold_reward(
			maxf(0.0, battle.turn_time_left), 
			battle.turn_time, 
			curr_state.memory.floor_number
			)

		curr_state.character_manager.add_gold(gold_reward)

	if curr_state.memory.room_type == Rooms.ENEMY_UPGRADE:
		curr_state.skip_enemy_upgrade(player)
		return

	curr_state.try_to_leave_room(player, skip_animation)





func upgrade_enemy(sender_id: int, item_data: Dictionary, enemy_idx: int) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	var player: Player = curr_state.memory.get_player_from_client_id(sender_id)
	if sender_id == -1:
		Net.call_func(upgrade_enemy, [Lobby.get_client_id(), item_data, enemy_idx])
		player = curr_state.memory.local_player

	var item: Item = Item.new()
	SaveSystem.load_data(item, item_data)

	var enemy_upgrade: EnemyUpgrade = EnemyUpgrade.new()
	enemy_upgrade.enemy_resource = curr_state.memory.battle.enemies_to_battle[enemy_idx].resource

	var stats: Array[BonusStat] = item.get_stats_to_dismantle(Stats.ENEMY_UPGRADE_FILTER)
	for bonus_stat in stats:
		StatUtils.try_to_add_stat(enemy_upgrade.stats, Stat.new([bonus_stat]))

	curr_state.enemy_manager.upgrade_enemy(player.team, enemy_upgrade)
	player.enemy_upgrade.remove_item_at(0)
	player.enemy_upgrades_this_room += 1
	curr_state.update_item_slots()





func can_activate_item(character: Character, item: Item, turn_type: BattleTurn.Type) -> bool:
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return false
	curr_state = curr_state as GameplayState

	var memory: Memory = curr_state.memory

	if character.battle_profile.is_stunned():
		return false

	if not ItemUtils.is_valid(item):
		return false

	if not is_instance_valid(memory.battle):
		return false

	var battle: Battle = memory.battle

	if is_instance_valid(battle):
		if battle.completed:
			return false

		if memory.room_type == Rooms.ENTRANCE:
			return false


	if not item.resource.is_essential():
		return false

	if turn_type == BattleTurn.Type.STANCE and not item.resource.activation_effect.activates_during_skip:
		return false

	var armor_percent_to_restore: int = item.resource.activation_effect.armor_percent_to_restore
	var status_effect: BonusStatusEffect = item.resource.activation_effect.status_effect
	var mana_to_regenerate: int = item.resource.activation_effect.mana_to_regenerate
	var remaining_uses: int = item.get_remaining_uses()


	if is_instance_valid(item.resource.activation_effect.ability):
		return curr_state.character_manager.can_use_ability(battle, character, item.resource.activation_effect.ability) == Character.UseAbilityResult.SUCCESS


	if is_instance_valid(status_effect) and character.battle_profile.get_status_effect_amount(status_effect.resource) == status_effect.resource.limit:
		return false

	if armor_percent_to_restore and character.get_missing_armor() == 0:
		return false

	if mana_to_regenerate and character.get_missing_mana() == 0:
		return false

	if not remaining_uses:
		return false

	return true





func confirm_turn(sender_id: int, floor_state: PackedInt64Array) -> void :
	var curr_state = StateManager.get_current_state()

	if not curr_state is GameplayState:
		return
	curr_state = curr_state as GameplayState

	if Lobby.is_lobby_owner():
		(confirmed_turns[floor_state] as Array).push_back(sender_id)
		print("confirming turn: ", confirmed_turns[floor_state])
		return

	Net.call_func(confirm_turn, [Lobby.get_client_id(), floor_state], [Lobby.get_host()])
	print("sending confirm turn: ", floor_state)
