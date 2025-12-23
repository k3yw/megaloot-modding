class_name MarketManager extends GameplayComponent

enum ItemType{
	NORMAL, 
	BANISHED, 
	STAT_ADAPTER, 
	TOME, 
	BUYOUT
	}




func process_market_slots():
	var selected_player: Player = gameplay_state.get_selected_player()

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


		item_texture_rect.activation_texture_bar.hide()
		item_texture_rect.max_progress = 0


		if not can_buy_item(slot.item_container, slot.index):
			item_texture_rect.max_progress = 1
			item_texture_rect.curr_progress = 1


		item_texture_rect.lock_texture_rect.visible = false

		if slot.item_container.challenge_locked_indexes.has(slot.index):
			(item_texture_rect.lock_texture_rect.material as ShaderMaterial).set_shader_parameter("type", GlobalColors.Type.HIGHLIGHT_COLOR)
			item_texture_rect.lock_texture_rect.visible = true

		if slot.item_container.locked_indexes.has(slot.index):
			(item_texture_rect.lock_texture_rect.material as ShaderMaterial).set_shader_parameter("type", GlobalColors.Type.PRIMARY_COLOR)
			item_texture_rect.lock_texture_rect.visible = true


		if not is_instance_valid(market_item.resource):
			continue

		if market_item.is_banish:
			continue
			
		if market_item.is_buyout:
			continue

		item_texture_rect.highlight_texture_rect.hide()

		for item in selected_player.get_owned_items():
			if not item.resource == market_item.resource:
				continue

			item_texture_rect.highlight_texture_rect.show()
			item_texture_rect.highlight_texture_rect.modulate = Color("#2a2a35")


		for item in UserData.profile.get_selected_build().get_items():
			if not item.resource == market_item.resource:
				continue

			item_texture_rect.highlight_texture_rect.modulate = Color("#f5c182")
			item_texture_rect.highlight_texture_rect.show()




func process_hub_action_panel() -> void :
	canvas_layer.market_margin.show()
	canvas_layer.hub_action_panel.hide()

	if not is_instance_valid(ItemManager.dragged_item_slot):
		return

	if not is_instance_valid(ItemManager.dragged_item_slot.item_container):
		return

	if ItemManager.dragged_item_slot.item_container.resource == ItemContainerResources.MARKET:
		return

	var dragged_item: Item = ItemManager.dragged_item_slot.get_item()


	if not is_instance_valid(dragged_item):
		return


	var text: String = T.get_translated_string("deforge").to_lower()
	if dragged_item.reforge_level == 0:
		text = T.get_translated_string("split").to_lower()

	canvas_layer.hub_action_panel.split_container.show()

	if dragged_item.is_reforge or dragged_item.reforge_level == 0 and dragged_item.rarity == ItemRarity.Type.COMMON:
		canvas_layer.hub_action_panel.split_container.hide()

	canvas_layer.hub_action_panel.split_label.text = text


	canvas_layer.hub_action_panel.set_price(get_sell_price(dragged_item))


	canvas_layer.market_margin.hide()
	canvas_layer.hub_action_panel.show()





func process_market_refresh_button():
	var market_refresh_button: GenericButton = canvas_layer.market_refresh_button
	var can_refresh: bool = can_refresh_market()

	market_refresh_button.visible = not canvas_layer.hub_action_panel.visible
	market_refresh_button.disabled = not can_refresh

	if market_refresh_button.is_pressed:
		try_to_refresh_market()

	market_refresh_button.refresh_price = get_refresh_price().amount



func get_refresh_price() -> Price:
	var amount: float = Math.big_round(memory.get_market_refresh_price(memory.local_player.refresh_count))
	if memory.floor_number == 0 and memory.room_idx == -1:
		amount = 2

	return Price.new(Stats.GOLD, amount)



func can_refresh_market() -> bool:
	var refresh_price: Price = get_refresh_price()
	var can_refresh: bool = character_manager.can_pay(refresh_price)
	var dragged_item: Item = ItemManager.dragged_item_slot.get_item()

	if refresh_price.amount <= 0:
		can_refresh = false

	if is_instance_valid(dragged_item):
		can_refresh = false

	if memory.local_player.died:
		can_refresh = false


	return can_refresh





func try_to_refresh_market() -> void :
	var can_refresh: bool = can_refresh_market()

	if not can_refresh:
		return

	var price: Price = get_refresh_price()
	character_manager.pay(price, false)
	refresh_market()

	memory.local_player.floor_refresh_count += 1
	memory.local_player.refresh_count += 1




func try_to_refresh_merchant() -> void :
	var can_refresh: bool = memory.local_player.diamonds > 0

	if not can_refresh:
		return

	var price: Price = Price.new(Stats.DIAMOND, 1)
	character_manager.pay(price, false)
	refresh_market(ItemContainerResources.MERCHANT)



func try_to_refresh_mystic_trader() -> void :
	var can_refresh: bool = memory.local_player.diamonds > 0

	if not can_refresh:
		return

	var price: Price = Price.new(Stats.DIAMOND, 1)
	character_manager.pay(price, false)
	refresh_market(ItemContainerResources.MYSTIC_TRADER)







func get_buy_price(item: Item) -> Price:
	if not is_instance_valid(item):
		return Price.new(Stats.GOLD, 0.0)

	return item.get_buy_price()






func can_buy_item(item_container: ItemContainer, idx: int) -> bool:
	var slot: Slot = Slot.new(item_container, idx)
	var market_item: Item = slot.get_item()
	var local_player: Player = memory.local_player

	if not is_instance_valid(market_item):
		return false

	if not gameplay_state.get_selected_player() == local_player:
		return false

	if local_player.left_room:
		return false


	var buy_price: Price = get_buy_price(market_item)
	if not character_manager.can_pay(buy_price):
		return false

	if local_player.died:
		return false

	if local_player.inventory.is_full():
		if not market_item.is_banish or not market_item.is_buyout:
			var slots_to_merge: Array[Slot] = ItemManager.get_slots_to_merge(local_player, slot, ItemManager.MergeSource.MARKET)
			if not slots_to_merge.size():
				return false

	if memory.partners.size():
		if local_player.is_phantom:
			return false

	return true





func try_to_buy_item(item_container: ItemContainer, idx: int) -> bool:
	var market_slot = Slot.new(item_container, idx)
	var local_player: Player = memory.local_player

	if not is_instance_valid(local_player):
		return false

	if not gameplay_state.get_selected_player() == local_player:
		return false

	var inv_empty_slot: Slot = Slot.new(local_player.inventory, local_player.inventory.get_first_empty_idx())
	var item: Item = market_slot.get_item()
	var merged: bool = false

	if not is_instance_valid(item):
		return false

	var new_buy_price: Price = get_buy_price(item)

	if not can_buy_item(item_container, idx):
		return false


	character_manager.pay(new_buy_price, false)
	if item.is_banish:
		var market_index: int = market_slot.index
		gameplay_state.banish_item(local_player, market_slot)
		await get_tree().create_timer(0.45).timeout
		refresh_market(ItemContainerResources.MARKET, [market_index], false)
		return true
		
	if item.is_buyout:
		var market_index: int = market_slot.index
		gameplay_state.buyout_item(local_player, market_slot)
		await get_tree().create_timer(0.45).timeout
		refresh_market(ItemContainerResources.MARKET, [market_index], false)
		return true

	if item.resource == Items.MERCHANT_UPGRADE:
		var market_index: int = market_slot.index
		gameplay_state.upgrade_merchant(local_player, market_slot)
		return true


	var slots_to_merge: Array[Slot] = ItemManager.get_slots_to_merge(local_player, market_slot, ItemManager.MergeSource.MARKET)
	if slots_to_merge.size():
		ItemManager.merge(slots_to_merge[0], slots_to_merge[1])
		merged = true


	if not merged:
		if inv_empty_slot.index == -1:
			return false
		ItemManager.try_to_swap_items(inv_empty_slot, market_slot)

	item.discount = 0.0

	unlock_item(market_slot)

	if market_slot.item_container == local_player.market:
		local_player.market.items[market_slot.index] = null
		await_market_idx_refresh(market_slot.index)

		if local_player.sell_stack.size():
			Net.call_func(MultiplayerManager.pop_from_sell_stack, [Lobby.get_client_id()], [Lobby.get_host()])
			await_add_from_sell_stack(market_slot.index)

		if memory.game_mode == GameModes.PRACTICE:
			local_player.market.items[market_slot.index] = Item.new(item)

		memory.local_player.add_to_buy_history(item.resource)


	gameplay_state.update_all_ui_requested = true
	return true



func await_market_idx_refresh(idx: int) -> void :
	await get_tree().process_frame
	await get_tree().process_frame
	refresh_market(ItemContainerResources.MARKET, [idx], false)



func await_add_from_sell_stack(idx: int) -> void :
	var local_player: Player = memory.local_player
	await get_tree().process_frame
	await get_tree().process_frame

	if not is_instance_valid(local_player):
		return

	local_player.market.add_item_at(idx, local_player.sell_stack.pop_front())



func get_sell_price(item: Item) -> float:
	if not is_instance_valid(item):
		return 0.0

	var base_sell_price: float = item.get_buy_price(false).amount * 0.25

	if item.is_phantom:
		return 1.0

	return floorf(maxf(1, base_sell_price))





func sell_dragged_item() -> void :
	var dragged_item: Item = ItemManager.dragged_item_slot.get_item()

	if not is_instance_valid(dragged_item):
		return

	try_to_sell_items([ItemManager.dragged_item_slot])




func can_sell_item(slot: Slot) -> bool:
	var sellable_item_containers: Array[ItemContainer] = [
		memory.local_player.loot_stash, 
		memory.local_player.equipment, 
		memory.local_player.inventory
		]

	if not sellable_item_containers.has(slot.item_container):
		return false

	if slot.item_container == memory.local_player.equipment and not character_manager.can_swap_equipment(memory.local_player) == ItemPressResult.Type.SWAP:
		return false

	return true




func try_to_sell_items(slots: Array[Slot]) -> void :
	var to_reset_stats: bool = false
	var price: float = 0.0

	for slot in slots:
		if not can_sell_item(slot):
			continue

		var item: Item = slot.get_item()
		if not is_instance_valid(item):
			continue

		if item.drag_locked:
			continue

		Net.call_func(MultiplayerManager.add_to_sell_stack, [Lobby.get_client_id(), SaveSystem.get_data(item)], [Lobby.get_host()])
		memory.local_player.sell_stack.push_back(item)

		price += get_sell_price(item)

		if slot.item_container == memory.local_player.equipment:
			to_reset_stats = true

		slot.remove_item()
		ItemManager.discard_dragged_item()

	if to_reset_stats:
		character_manager.try_to_rest()

	character_manager.add_gold(price)





func make_initial_refresh() -> void :
	var market_size: int = memory.local_player.market.items.size()
	var weapon_idx: int = RNGManager.market_rand.randi_range(0, market_size - 1)
	var starting_weapon_resource: ItemResource = null
	var market_idxes: Array = range(market_size)
	market_idxes.erase(weapon_idx)

	for idx in range(Items.LIST.size() - 1, -1, -1):
		var item: ItemResource = Items.LIST[idx]
		if not item.socket_type == SocketTypes.WEAPON:
			continue
		starting_weapon_resource = item

	var rand_weapon: Item = ItemManager.create_item(starting_weapon_resource, 0, 0)
	memory.local_player.market.items[weapon_idx] = rand_weapon

	refresh_market(ItemContainerResources.MARKET, market_idxes)






func refresh_market(market_type: ItemContainerResource = ItemContainerResources.MARKET, market_item_idx_arr: Array = [], clear_sell_stack: bool = true) -> void :

	match market_type:
		ItemContainerResources.MARKET: refresh_local_market(market_item_idx_arr, clear_sell_stack)
		ItemContainerResources.MYSTIC_TRADER: refresh_mystic_trader(market_item_idx_arr)
		ItemContainerResources.MERCHANT: refresh_merchant()

	gameplay_state.update_all_ui_requested = true








func refresh_local_market(market_item_idx_arr: Array, clear_sell_stack: bool) -> void :
	var curr_floor_market_size: int = Items.get_resources(Items.MARKET, memory.floor_number).size()
	var reforge_chance: float = minf(0.075, 0.00275 * memory.floor_number)
	var local_player: Player = memory.local_player

	if market_item_idx_arr.is_empty():
		market_item_idx_arr = range(local_player.market.items.size())

	clear_shop(market_item_idx_arr, local_player.market)



	if clear_sell_stack:
		Net.call_func(MultiplayerManager.clear_sell_stack, [Lobby.get_client_id()], [Lobby.get_host()])
		local_player.sell_stack.clear()


	var normal_market_pool: Array[ItemResource] = local_player.get_normal_item_pool()

	var rolled_buyout = false
	for idx in market_item_idx_arr.size():
		var arr_idx: int = market_item_idx_arr[idx]
		var market_item: Item = local_player.market.items[arr_idx]
		if is_instance_valid(market_item):
			continue

		var base_banish_chance: int = ceili(float(curr_floor_market_size - local_player.banished_items.size()) * 0.045)
		var banish_chance_multiplier: int = 1.0 + (floorf(float(memory.floor_number)) * 0.1)
		var banished_chance: int = mini(45, base_banish_chance * banish_chance_multiplier)

		var item_resource: ItemResource = normal_market_pool[idx]
		var item_type: ItemType = ItemType.NORMAL
		var new_market_item: Item = null

		var buyout_chance = 5.0

		if local_player.get_owned_item_resources().has(item_resource):
			banished_chance *= 0.25

		if curr_floor_market_size - local_player.banished_items.size() < 5:
			banished_chance = 0.0

		if local_player.get_owned_items().size() == 0:
			banished_chance = 0.0


		if Math.rand_success(banished_chance, RNGManager.market_rand):
			item_type = ItemType.BANISHED
		elif rolled_buyout == false and local_player.banned_items.size() > 0 and Math.rand_success(buyout_chance, RNGManager.market_rand):
			rolled_buyout = true
			item_resource = local_player.banned_items[randi_range(0, local_player.banned_items.size() - 1)]
			item_type = ItemType.BUYOUT
		
		match item_type:
			ItemType.NORMAL:
				new_market_item = ItemManager.create_item(item_resource, memory.floor_number)
				new_market_item.rarity = Balance.get_market_rarity(item_resource, memory.floor_number)

				if RNGManager.market_rand.randf() < reforge_chance:
					new_market_item.roll_reforge(memory.floor_number, 1)

				local_player.add_to_recent_market_items(new_market_item.resource)


			ItemType.BANISHED:
				new_market_item = ItemManager.create_item(item_resource)
				new_market_item.is_banish = true
				
			ItemType.BUYOUT:
				new_market_item = ItemManager.create_item(item_resource)
				new_market_item.is_buyout = true
				new_market_item.rarity = ItemRarity.Type.DIVINE


		local_player.market.add_item_at(arr_idx, new_market_item)







func refresh_merchant() -> void :
	var market_item_pool: Array[ItemResource] = Items.get_resources(Items.MARKET, memory.floor_number)
	var artifact_item_pool: Array[ItemResource] = Items.ARTIFACTS
	var local_player: Player = memory.local_player
	var merchant_size: int = local_player.merchant.items.size()
	var base_market_pool: Array[ItemResource] = []

	clear_shop(range(local_player.merchant.items.size()), local_player.merchant)

	for banned_item in local_player.banned_items:
		market_item_pool.erase(banned_item)

	for banished_item in local_player.banished_items:
		market_item_pool.erase(banished_item)

	for index in merchant_size:
		if local_player.merchant.locked_indexes.has(index):
			continue
		local_player.merchant.remove_item_at(index)

	artifact_item_pool.shuffle()
	market_item_pool.shuffle()

	base_market_pool = market_item_pool.duplicate()

	var essential_indexes: Array = range(merchant_size)
	essential_indexes.shuffle()
	essential_indexes.resize(mini(artifact_item_pool.size(), randi_range(1, 3)))


	for idx in local_player.merchant.items.size():
		if local_player.merchant.locked_indexes.has(idx):
			continue

		var item_resource: ItemResource = null
		var pool: Array[ItemResource] = market_item_pool

		if essential_indexes.has(idx):
			pool = artifact_item_pool

		var rarity: ItemRarity.Type = ItemRarity.Type.COMMON
		var reforged_passive: Passive = null
		var reforged_stat: Array[Stat] = []
		var reforge_level: int = 0
		var discount: float = 0.0


		item_resource = pool.pop_back()
		rarity = Balance.get_market_rarity(item_resource, memory.floor_number)
		rarity += randi_range(1, 2)

		if market_item_pool.is_empty():
			market_item_pool = base_market_pool.duplicate()

		var new_market_item: Item = ItemManager.create_item(item_resource, memory.floor_number)

		if Math.rand_success(25):
			discount = maxf(0.45, discount)

		if essential_indexes.has(idx):
			discount = 0.0

		if new_market_item.resource.is_special:
			discount = 0.0


		if idx == local_player.merchant.items.size() - 1 and local_player.merchant_level == 0 and memory.floor_number > 0:
			new_market_item = ItemManager.create_item(Items.MERCHANT_UPGRADE)
			discount = 0.0


		rarity = mini(rarity, ItemRarity.Type.DIVINE) as ItemRarity.Type
		new_market_item.discount = discount
		new_market_item.rarity = rarity

		if new_market_item.can_reforge():
			new_market_item.roll_reforge(memory.floor_number, 1)
		elif new_market_item.can_convert_into_tinker_kit():
			new_market_item.convert_to_tinker_kit()

		local_player.merchant.add_item_at(idx, new_market_item)







func refresh_mystic_trader(market_item_idx_arr: Array = []) -> void :
	var stat_adapter_item_pool: Array[ItemResource] = Items.get_resources(Items.STAT_ADAPTERS, memory.floor_number)
	var tome_item_pool: Array[ItemResource] = Items.get_resources(Items.TOMES, memory.floor_number)
	var market_item_pool: Array[ItemResource] = Items.get_resources(Items.MARKET, memory.floor_number)
	var local_player: Player = memory.local_player
	var mystic_trader_size: int = local_player.mystic_trader.items.size()


	for idx in range(tome_item_pool.size() - 1, -1, -1):
		var tome: ItemResource = tome_item_pool[idx]
		if not local_player.can_learn_ability(tome.ability_to_learn):
			tome_item_pool.remove_at(idx)

	for idx in range(stat_adapter_item_pool.size() - 1, -1, -1):
		var stat_arapter: ItemResource = stat_adapter_item_pool[idx]
		if local_player.adapted_stats.has(stat_arapter.stat_to_adapt):
			stat_adapter_item_pool.remove_at(idx)


	if market_item_idx_arr.is_empty():
		market_item_idx_arr = range(mystic_trader_size)

	clear_shop(market_item_idx_arr, local_player.mystic_trader)

	var special_item_arr: Array[ItemType] = []

	if stat_adapter_item_pool.size() > 0:
		special_item_arr.push_back(ItemType.STAT_ADAPTER)

	for _i in mini(tome_item_pool.size(), randi_range(1, 3)):
		special_item_arr.push_back(ItemType.TOME)

	while special_item_arr.size() < local_player.mystic_trader.items.size():
		special_item_arr.push_back(ItemType.NORMAL)


	special_item_arr.shuffle()
	market_item_pool.shuffle()


	for idx in local_player.mystic_trader.items.size():
		if local_player.mystic_trader.locked_indexes.has(idx):
			continue

		var item_resource: ItemResource = market_item_pool.pop_back()
		var is_special: bool = false
		match special_item_arr[idx]:
			ItemType.STAT_ADAPTER:
				stat_adapter_item_pool.shuffle()
				var stat_adapter: ItemResource = stat_adapter_item_pool.pop_back()
				item_resource = stat_adapter
				is_special = true

			ItemType.TOME:
				tome_item_pool.shuffle()
				var tome: ItemResource = tome_item_pool.pop_back()
				item_resource = tome
				is_special = true


		var new_market_item: Item = ItemManager.create_item(item_resource, memory.floor_number)


		if not is_special:
			var rarity: ItemRarity.Type = ItemRarity.Type.COMMON
			rarity += randi_range(1, 2)
			rarity = Balance.get_market_rarity(item_resource, memory.floor_number + 10)
			new_market_item.rarity = rarity
			new_market_item.roll_reforge(memory.floor_number + 10, 1)
			new_market_item.convert_to_tinker_kit(false)



		var insightus: Item = ItemManager.create_insightus(memory.floor_number)

		var failed: bool = false
		if local_player.transformed_stats.has(insightus.transform_stat):
			failed = true

		for item in local_player.mystic_trader.items:
			if not is_instance_valid(item):
				continue
			if item.transform_stat == insightus.transform_stat:
				failed = true

		if not failed:
			new_market_item = insightus



		local_player.mystic_trader.add_item_at(idx, new_market_item)







func clear_shop(market_item_idx_arr: Array, item_container: ItemContainer) -> void :
	var local_player: Player = memory.local_player

	if market_item_idx_arr.size() == item_container.items.size():
		for index in item_container.items.size():
			if item_container.challenge_locked_indexes.has(index):
				continue

			if item_container.locked_indexes.has(index):
				continue

			var item: Item = item_container.items[index]
			if not is_instance_valid(item):
				continue

			item_container.remove_item_at(index)

		gameplay_state.update_item_slots()






func toggle_item_lock(slot: Slot) -> void :
	if not is_instance_valid(slot.get_item()):
		return

	if slot.item_container.challenge_locked_indexes.has(slot.index):
		return

	if slot.item_container.locked_indexes.has(slot.index):
		unlock_item(slot)
		return

	lock_item(slot)






func lock_item(slot: Slot) -> void :
	if slot.item_container.challenge_locked_indexes.has(slot.index):
		return

	if slot.item_container.locked_indexes.has(slot.index):
		return

	var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)
	slot.item_container.locked_indexes.push_back(slot.index)

	if not memory.partners.is_empty():
		Net.call_func(MultiplayerManager.sync_locked_items, [
			Lobby.get_client_id(), 
			slot.item_container.resource.resource_path, 
			slot.item_container.challenge_locked_indexes, 
			slot.item_container.locked_indexes, 
			])

	if not is_instance_valid(item_texture_rect):
		return


	var tone_event: ToneEventResource = ToneEventResource.new()
	tone_event.tones.push_back(Tone.new(preload("res://assets/sfx/lock_item.wav"), -4.5))
	tone_event.space_type = ToneEventResource.SpaceType._2D
	tone_event.position = item_texture_rect.global_position
	AudioManager.play_event(tone_event, name)

	gameplay_state.hover_info_update_request = true




func unlock_item(slot: Slot) -> void :
	if not slot.item_container.locked_indexes.has(slot.index):
		if not slot.item_container.challenge_locked_indexes.has(slot.index):
			return

	var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)
	var arr_idx: int = slot.item_container.locked_indexes.find(slot.index)
	if not arr_idx == -1:
		slot.item_container.locked_indexes.remove_at(arr_idx)

	arr_idx = slot.item_container.challenge_locked_indexes.find(slot.index)
	if not arr_idx == -1:
		slot.item_container.challenge_locked_indexes.remove_at(arr_idx)

	if not memory.partners.is_empty():
		Net.call_func(MultiplayerManager.sync_locked_items, [
			Lobby.get_client_id(), 
			slot.item_container.resource.resource_path, 
			slot.item_container.challenge_locked_indexes, 
			slot.item_container.locked_indexes, 
			])

	if not is_instance_valid(item_texture_rect):
		return

	var tone_event: ToneEventResource = ToneEventResource.new()
	tone_event.tones.push_back(Tone.new(preload("res://assets/sfx/unlock_item.wav"), -4.5))
	tone_event.space_type = ToneEventResource.SpaceType._2D
	tone_event.position = item_texture_rect.global_position
	AudioManager.play_event(tone_event, name)

	gameplay_state.hover_info_update_request = true
