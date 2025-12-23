class_name Player extends Character

@warning_ignore("unused_signal")
signal item_added_to_recent_market_items(item_resource: ItemResource)
signal item_added_to_buy_history(item_resource: ItemResource)
signal ability_learned(ability: AbilityResource)

const RECENT_MARKET_ITEMS_SIZE: int = 75
const BUY_HISTORY_SIZE: int = 75

var enemy_upgrade: ItemContainer = ItemContainer.new(ItemContainerResources.ENEMY_UPGRADE, 1)
var mystic_trader: ItemContainer = ItemContainer.new(ItemContainerResources.MYSTIC_TRADER, 5)
var loot_stash: ItemContainer = ItemContainer.new(ItemContainerResources.LOOT_STASH, 15)
var merchant: ItemContainer = ItemContainer.new(ItemContainerResources.MERCHANT, 5)
var market: ItemContainer = ItemContainer.new(ItemContainerResources.MARKET, 4)

var adventurer: Adventurer = Empty.adventurer
var learned_abilities: Array[AbilityResource] = []

var banished_items: Array[ItemResource] = []
var banned_items: Array[ItemResource] = []

var used_items: Array[GameObjectCounter] = []


var recent_market_items: Array[ItemResource] = []
var recently_sold: Array[ItemResource] = []
var buy_history: Array[ItemResource] = []
var sell_stack: Array[Item] = []

var last_battle_items: Array[Item] = []
var market_pool: Array[Item] = []

var floor_refresh_count: int = 0
var loot_drop_chance: int = 10
var refresh_count: int = 0


var chosen_room: RoomResource = RoomResource.new()
var enemy_upgrades_this_room: int = 0
var merchant_level: int = 0
var left_room: bool = false

var team: Team.Type = Team.Type.NULL


var profile_id: String = ""
var client_id: int = 0




static func get_from_profile_id(players: Array[Player], arg_profile_id: String) -> Player:
	for player in players:
		if player.profile_id == arg_profile_id:
			return player

	return null


func initialize() -> void :
	inventory.item_removing.connect( func(item: Item):
		if item.resource.is_artifact:
			await inventory.item_removed
			cache_stats()
		)

	inventory.item_added.connect( func(item: Item, _idx: int):
		if not is_instance_valid(item):
			return
		if item.resource.is_artifact:
			cache_stats()
		)

	equipment.item_added.connect( func(item: Item, _idx: int): process_item_acquire(item))
	character_id = profile_id




func unlock_artifacts() -> void :
	for item in inventory.get_items():
		item.drag_locked = false

func lock_artifacts() -> void :
	for item in inventory.get_items():
		if item.resource.is_special:
			if item.resource.bonus_stats.size() > 0:
				item.drag_locked = true




func activate_insightus(slot: Slot) -> void :
	var item: Item = slot.get_item()
	transformed_stats.push_back(item.transform_stat)


func adapt_stat(slot: Slot) -> void :
	var item: Item = slot.get_item()
	adapted_stats.push_back(item.resource.stat_to_adapt)



func can_learn_ability(ability_to_learn: AbilityResource) -> bool:
	if learned_abilities.has(ability_to_learn):
		return false

	if learned_abilities.size() >= adventurer.abilities_to_learn_size:
		return false

	return true



func learn_ability(slot: Slot) -> void :
	var item: Item = slot.get_item()
	learned_abilities.push_back(item.resource.ability_to_learn)
	ability_learned.emit(item.resource.ability_to_learn)


func banish_item(slot: Slot) -> void :
	var item: Item = slot.get_item()
	if not banished_items.has(item.resource):
		banished_items.push_back(item.resource)
		
func buyout_item(slot: Slot) -> void :
	var item: Item = slot.get_item()
	banned_items = banned_items.filter(func(value): return value.name != item.resource.name)


func remove_banish(item_resource: ItemResource) -> void :
	Net.call_func(MultiplayerManager.remove_banish, [client_id, item_resource.resource_path])
	banished_items.erase(item_resource)




func get_used_item_counter(item_resource: ItemResource) -> GameObjectCounter:
	for used_item in used_items:
		if used_item.item_resource == item_resource:
			return used_item

	return null



func get_requirement_locked_items(pool: Array[ItemResource]) -> Array[ItemResource]:
	var requirement_locked_items: Array[ItemResource] = []

	for item in pool:
		for unlock_requirement in item.unlock_requirements:
			var condition_met: bool = false

			if is_instance_valid(unlock_requirement.item_resource):
				for used_item in used_items:
					if used_item.item_resource == unlock_requirement.item_resource:
						if used_item.amount >= unlock_requirement.completed_battles:
							condition_met = true

			if not condition_met:
				requirement_locked_items.push_back(item)
				break


	return requirement_locked_items




func get_normal_item_pool() -> Array[ItemResource]:
	var original_extra_pool: Array[ItemResource] = Items.get_resources(Items.MARKET, floor_number)
	var items_to_skip: Array[ItemResource] = get_requirement_locked_items(original_extra_pool) + banished_items + banned_items
	var owned_item_resources: Array[ItemResource] = get_owned_item_resources()
	var extra_pool: Array[ItemResource] = original_extra_pool.duplicate()
	var weights: PackedFloat32Array = []
	
	var items: Array[ItemResource] = []



	for item in items_to_skip:
		original_extra_pool.erase(item)
		extra_pool.erase(item)


	for item in extra_pool:
		var weight: float = 1.0 / (recent_market_items.count(item) + 1)
		weights.push_back(weight)
	owned_item_resources.shuffle()


	for idx in mini(2, owned_item_resources.size()):
		var item: ItemResource = owned_item_resources[idx]
		if item.is_essential():
			continue

		if item.is_tome():
			continue

		if item.is_special:
			continue

		if banished_items.has(item):
			continue

		if items_to_skip.has(item):
			continue

		if Math.rand_success(90):
			continue

		items.push_back(item)


	var rand = RandomNumberGenerator.new()
	while items.size() < market.items.size():
		if extra_pool.is_empty():
			break
		var idx: int = rand.rand_weighted(weights)
		items.push_back(extra_pool.pop_at(idx))
		weights.remove_at(idx)


	original_extra_pool.shuffle()
	for _i in clampi(5 - items.size(), 0, 5):
		items.push_back(original_extra_pool.pick_random())


	return items






func set_last_battle_items(new_last_battle_items: Array[Item]) -> void :
	last_battle_items = new_last_battle_items

	for item in new_last_battle_items:
		for counter in used_items:
			if not counter.item_resource == item.resource:
				continue

			counter.amount += 1
			break

		used_items.push_back(GameObjectCounter.new(item.resource, 1))




func process_item_acquire(item: Item) -> void :
	if not is_instance_valid(item):
		return



func can_select_enemy(team_in_battle: Team.Type) -> bool:
	return team == team_in_battle






func find_item(item_resource: ItemResource) -> Slot:
	for idx in inventory.items.size():
		var item: Item = inventory.items[idx]
		if not is_instance_valid(item):
			continue

		if item.resource == item_resource:
			return Slot.new(inventory, idx)

	for idx in loot_stash.items.size():
		var item: Item = loot_stash.items[idx]
		if not is_instance_valid(item):
			continue

		if item.resource == item_resource:
			return Slot.new(loot_stash, idx)

	return null





func apply_adventurer(arg_adventurer: Adventurer) -> void :
	adventurer = arg_adventurer
	doubled_stat = adventurer.doubled_stat
	base_passive = adventurer.passive

	for bonus_stat in adventurer.bonus_stats:
		change_stat_amount(stats, Stat.new([bonus_stat]))

	equipment.sockets = adventurer.sockets.duplicate()

	update_stats()



func add_to_buy_history(item_resource: ItemResource) -> void :
	buy_history.push_back(item_resource)
	if buy_history.size() > BUY_HISTORY_SIZE:
		buy_history.pop_front()

	item_added_to_buy_history.emit(item_resource)


func add_to_recent_market_items(item_resource: ItemResource) -> void :
	recent_market_items.push_back(item_resource)
	if recent_market_items.size() > RECENT_MARKET_ITEMS_SIZE:
		recent_market_items.pop_front()

	item_added_to_recent_market_items.emit(item_resource)




func get_owned_item_resources() -> Array[ItemResource]:
	var item_containers: Array[ItemContainer] = [
		loot_stash, 
		inventory, 
		equipment, 
	]

	var owned_item_resources: Array[ItemResource] = []
	for container in item_containers:
		for item in container.get_items():
			if not owned_item_resources.has(item.resource):
				owned_item_resources.push_back(item.resource)

	return owned_item_resources




func get_item_containers() -> Array[ItemContainer]:
	return [
		inventory, 
		equipment, 
		loot_stash, 
		market, 
		merchant, 
		mystic_trader, 
		enemy_upgrade
		]



func cleanup() -> void :
	super.cleanup()

	if is_instance_valid(merchant):
		merchant.cleanup()
		merchant.free()

	if is_instance_valid(enemy_upgrade):
		enemy_upgrade.cleanup()
		enemy_upgrade.free()

	if is_instance_valid(market):
		market.cleanup()
		market.free()

	if is_instance_valid(loot_stash):
		loot_stash.cleanup()
		loot_stash.free()

	for used_item in used_items:
		used_item.free()
