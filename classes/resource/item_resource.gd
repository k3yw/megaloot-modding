@tool
class_name ItemResource extends Resource


@export var name: StringName
@export var texture: Texture2D
@export var bb_script: Script
@export var socket_type: SocketType

@export var set_resources: Array[ItemSetResource] = [preload("res://resources/item_sets/generic.tres")]


@export var consumption_effect: ConsumptionEffect
@export var activation_effect: ActivationEffect
@export var ability_to_learn: AbilityResource
@export var stat_to_adapt: StatResource
@export var passive: Passive


@export_category("Balance")
@export var bonus_stats: Array[BonusStat]
@export var unlock_requirements: Array[ItemUnlockRequirement]
@export var extra_price: float = 0.0
@export var spawn_floor: int = 1


@export_category("Tweaks")
@export var hide_level: bool
@export var buy_limit: int = -1
@export var use_custom_rarity: bool
@export var custom_rarity: ItemRarity.Type
@export var reforgable: bool = true
@export var is_artifact: bool
@export var is_special: bool


func is_tome() -> bool:
    return is_instance_valid(ability_to_learn)

func is_essential() -> bool:
    return is_instance_valid(activation_effect)

func is_consumable() -> bool:
    return is_instance_valid(consumption_effect)

func is_stat_adapter() -> bool:
    return is_instance_valid(stat_to_adapt)


func get_price() -> float:
    return ((spawn_floor - 1) * 45) + extra_price



func get_unique_stat_resources() -> Array[StatResource]:
    var stat_resources: Array[StatResource] = []

    for stat in bonus_stats:
        if stat_resources.has(stat.resource):
            continue
        stat_resources.push_back(stat.resource)


    return stat_resources





func get_negative_value() -> int:
    var negative_value: int = 0

    for stat in bonus_stats:
        if stat.amount > 0:
            continue

        negative_value += abs(stat.amount)

    return negative_value





func can_reforge() -> bool:
    for stat in bonus_stats:
        if stat.resource.max_amount == -1:
            return true

    return false



func get_rand_weight() -> float:
    return 2.5 / pow(get_price(), 0.75)


func get_max_rarity(floor_number: int) -> int:
    return maxi(0, floor_number - (spawn_floor * 2)) + 1

func calculate_price(rarity: int) -> int:
    return floori(get_price() * pow(2, rarity))


func get_translated_name() -> String:
    return T.get_translated_string(name, "Item Name")
