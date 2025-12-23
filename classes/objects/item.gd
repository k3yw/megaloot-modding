class_name Item extends Object

const MAX_REFORGE_LEVEL: int = 6
const MAX_BURNOUT: int = 3


var resource: ItemResource = Empty.item_resource
var rarity: ItemRarity.Type: set = set_rarity
var max_rarity: ItemRarity.Type = ItemRarity.Type.DIVINE

var name_override: String = ""

var changed_this_frame: bool = false
var is_phantom: bool = false

var reforged_passive: Passive = Empty.passive
var reforged_stats: Array[Stat] = []

var transform_stat: StatResource = StatResource.new()


var is_tinker_kit: bool = false
var is_reforge: bool = false
var is_banish: bool = false
var is_buyout: bool = false

var drag_locked: bool = false
var toggled: bool = false
var uses: int = 0

var recently_used: bool = false
var burnout: int = 0

var reforge_level: int = 0
var discount: float = 0.0
var spawn_floor: int = 0





func _init(arg_item: Item = null) -> void :
	if not is_instance_valid(arg_item):
		return

	var item_data: Dictionary = SaveSystem.get_data(arg_item)
	SaveSystem.load_data(self, item_data)




func has_transformer_stat() -> bool:
	if not is_instance_valid(transform_stat):
		return false

	if transform_stat.name.is_empty():
		return false

	return true



func set_rarity(value: ItemRarity.Type) -> void :
	if not is_instance_valid(resource):
		return
	if resource.is_essential():
		return
	if resource.is_consumable():
		return
	if resource.is_special:
		return
	if not rarity == value:
		rarity = value
		changed_this_frame = true




func can_increase_rarity() -> bool:
	if max_rarity - 1 < rarity:
		return false

	if resource.is_essential():
		return false

	if resource.is_consumable():
		return false

	if resource.is_special:
		return false

	return true


func increase_rarity(amount: int) -> void :
	for _i in mini(amount, ItemRarity.Type.size() - 1):
		try_to_increase_rarity()



func try_to_increase_rarity() -> bool:
	if resource.use_custom_rarity:
		return false

	if can_increase_rarity():
		@warning_ignore("int_as_enum_without_cast")
		rarity += 1
		return true

	return false



func decrease_rarity() -> void :
	if rarity > 0:
		@warning_ignore("int_as_enum_without_cast")
		rarity -= 1


func refill() -> void :
	if not resource.is_essential():
		return

	uses = 0


func get_remaining_uses() -> int:
	if not is_instance_valid(resource):
		return 0

	if not resource.is_essential():
		return 0

	return maxi(0, resource.activation_effect.use_limit - uses)





func merge_with(item_to_merge: Item) -> void :
	if not item_to_merge.is_reforge and not is_reforge:
		try_to_increase_rarity()

	if is_instance_valid(item_to_merge.reforged_passive):
		if item_to_merge.reforged_passive.name.length():
			reforged_passive = item_to_merge.reforged_passive

	if is_tinker_kit:
		resource = item_to_merge.resource

	for stat in item_to_merge.reforged_stats:
		StatUtils.change_stat_amount(reforged_stats, stat)

	reforge_level = maxi(reforge_level, item_to_merge.reforge_level)
	is_tinker_kit = false

	if is_reforge:
		rarity = item_to_merge.rarity
		is_reforge = false




func get_buy_price(include_discount: bool = true) -> Price:
	if not is_instance_valid(resource):
		return Price.new(null, 0.0)

	if resource == Items.INSIGHTUS:
		return Price.new(Stats.DIAMOND, 3.0)

	if resource.is_stat_adapter():
		return Price.new(Stats.DIAMOND, 5.0)

	if resource.is_special or resource.is_essential() or resource.is_tome():
		return Price.new(Stats.DIAMOND, 1.0)

	var buy_price: float = resource.get_price()
	buy_price += float(spawn_floor) * 0.45

	if is_banish:
		return Price.new(Stats.GOLD, maxf(1, floorf(buy_price * 2.0)))
		
	if is_buyout:
		return Price.new(Stats.DIAMOND, 4.0)

	buy_price = buy_price * pow(2, rarity)
	if is_tinker_kit:
		buy_price *= 2

	if resource.is_consumable():
		return Price.new(Stats.GOLD, resource.consumption_effect.get_value(spawn_floor))

	buy_price *= pow(1.25, reforge_level)

	if include_discount:
		buy_price = buy_price * (1.0 - discount)


	return Price.new(Stats.GOLD, maxf(1, floorf(buy_price)))






func get_set_resources() -> Array[ItemSetResource]:
	if is_reforge:
		return [ItemSets.REFORGE]

	if is_phantom:
		return [ItemSets.PHANTOM]

	if not is_instance_valid(resource):
		return []

	return resource.set_resources





func get_bonus_stats() -> Array[BonusStat]:
	var bonus_stats: Array[BonusStat] = []

	if not is_reforge:
		for bonus_stat in resource.bonus_stats:
			var new_amount: float = bonus_stat.get_amount_from_rarity(rarity)
			if is_equal_approx(new_amount, 0.0):
				continue
			var new_bonus_stat: BonusStat = BonusStat.new(bonus_stat.resource, new_amount, bonus_stat.is_modifier)
			new_bonus_stat.boosting_sets = bonus_stat.boosting_sets.duplicate()
			BonusStat.add_to_array(bonus_stats, new_bonus_stat)

	for stat in reforged_stats:
		for bonus_stat in stat.get_bonus_stats():
			if is_equal_approx(bonus_stat.amount, 0.0) and bonus_stat.boosting_sets.is_empty():
				continue
			BonusStat.add_to_array(bonus_stats, bonus_stat)


	return bonus_stats



func convert_to_tinker_kit(reset_rarity: bool = true) -> void :
	var bonus_stats: Array[BonusStat] = get_bonus_stats()
	reforge_level = maxi(1, reforge_level)
	is_tinker_kit = true
	is_reforge = true

	remove_reforge_stats()
	for bonus_stat in bonus_stats:
		StatUtils.change_stat_amount(reforged_stats, Stat.new([bonus_stat]))

	if reset_rarity:
		set_rarity(ItemRarity.Type.COMMON)



func get_tinker_price() -> Price:
	return Price.new(Stats.DIAMOND, maxf(1, pow(2, reforge_level)))



func roll_reforge(floor_number: int, reforges: int = 0) -> void :
	for _i in reforges:
		reforge()

	var chance: float = 0.25 / (reforge_level + 1)
	for _i in floor_number:
		if Math.rand_success(chance * 100):
			chance *= 0.1
			reforge()



func reforge() -> void :
	if not can_reforge():
		return

	reforge_level += 1
	if has_reforged_passive() and reforged_stats.is_empty():
		reforge_level = 1

	for bonus_stat in resource.bonus_stats:
		if not bonus_stat.resource.max_amount == -1:
			continue

		var stat: Stat = Stat.new([bonus_stat])
		var ex: float = 1 + (float(reforge_level - 1) * 0.95)
		stat.base_amount = ceili(pow(5, ex))

		for old_stat in get_bonus_stats():
			if old_stat.resource == bonus_stat.resource:
				stat.modifier_boosting_sets = old_stat.boosting_sets.duplicate()
				stat.base_boosting_sets = old_stat.boosting_sets.duplicate()

		if not stat.base_boosting_sets.has(resource.set_resources[0]):
			stat.base_boosting_sets.push_back(resource.set_resources[0])

		if not stat.modifier_boosting_sets.has(resource.set_resources[0]):
			stat.modifier_boosting_sets.push_back(resource.set_resources[0])


		StatUtils.change_stat_amount(reforged_stats, stat)





func get_stats_to_dismantle(filter: Array[StatResource] = []) -> Array[BonusStat]:
	var stats_to_dismantle: Array[BonusStat] = []

	if is_reforge:
		return []

	for bonus_stat in get_bonus_stats():
		if filter.has(bonus_stat.resource):
			continue
		stats_to_dismantle.push_back(bonus_stat)

	return stats_to_dismantle






static func is_compatible(item_a: Item, removed_item: Item) -> bool:
	var items: Array[Item] = [item_a, removed_item]
	if item_a == removed_item:
		return false

	for item in items:
		if not is_instance_valid(item):
			return false

		if not is_instance_valid(item.resource):
			return false

		if not is_instance_valid(item.resource.socket_type):
			return false

		if item.is_phantom:
			return false

		if item.is_banish:
			return false
			
		if item.is_buyout:
			return false

	if item_a.is_tinker_kit:
		return false

	if not item_a.is_tinker_kit and not removed_item.is_tinker_kit:
		if not item_a.resource.name == removed_item.resource.name:
			return false


	if not item_a.reforged_stats.is_empty() and not removed_item.reforged_stats.is_empty():
		return false

	if item_a.has_reforged_passive() and removed_item.has_reforged_passive():
		if not item_a.reforged_passive == removed_item.reforged_passive:
			return false

	if item_a.reforged_stats.is_empty() and removed_item.is_reforge:
		return true

	if [item_a.rarity, removed_item.rarity].has(ItemRarity.Type.DIVINE):
		if not item_a.reforged_stats.is_empty() and not removed_item.reforged_stats.is_empty():
			return false

	if item_a.rarity == removed_item.rarity:
		return true

	return false





func can_upgrade() -> bool:
	if reforge_level == 0:
		return false

	return can_reforge()



func can_convert_into_tinker_kit() -> bool:
	if resource.is_essential():
		return false

	if resource.is_consumable():
		return false

	if resource.is_special:
		return false

	if is_tinker_kit:
		return false

	if is_phantom:
		return false

	return true



func can_reforge() -> bool:
	if not resource.can_reforge():
		return false

	if reforge_level >= MAX_REFORGE_LEVEL:
		return false

	if is_reforge:
		return false

	return can_convert_into_tinker_kit()




func is_infusable() -> bool:
	if resource.is_essential():
		return false

	if resource.is_consumable():
		return false

	if resource.is_special:
		return false

	if is_phantom:
		return false

	return true



func has_reforged_passive() -> bool:
	if not is_instance_valid(reforged_passive):
		return false

	if reforged_passive.name.is_empty():
		return false

	return true



func has_burnout() -> bool:
	return burnout > 0



func remove_reforge_stats() -> void :
	for stat in reforged_stats:
		if not is_instance_valid(stat):
			continue
		stat.free()
	reforged_stats.clear()


func remove_reforge() -> void :
	reforged_passive = Empty.passive
	is_reforge = false
	reforge_level = 0
	remove_reforge_stats()



func get_texture() -> Texture:
	if is_tinker_kit:
		return preload("res://assets/textures/items/tinker_kit.png")

	return resource.texture

func cleanup() -> void :
	remove_reforge()
