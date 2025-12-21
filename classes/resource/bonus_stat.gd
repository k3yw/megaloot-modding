@tool
class_name BonusStat extends Resource




@export var boosting_sets: Array[ItemSetResource] = []
@export var resource: StatResource
@export var amount: float = 1.0
@export var is_modifier: bool



func _init(arg_resource: StatResource = null, arg_amount: float = 1.0, arg_is_modifier: bool = false) -> void :
    resource = arg_resource
    amount = arg_amount
    is_modifier = arg_is_modifier




func is_same_as(arg_bonus_stat: BonusStat) -> bool:
    boosting_sets.erase(null)

    if not boosting_sets.size() == arg_bonus_stat.boosting_sets.size():
        return false

    for boosting_set in boosting_sets:
        if not arg_bonus_stat.boosting_sets.has(boosting_set):
            return false

    if not resource == arg_bonus_stat.resource:
        return false

    if not is_modifier == arg_bonus_stat.is_modifier:
        return false

    return true


static func add_to_array(arr: Array[BonusStat], bonus_stat: BonusStat) -> void :
    for arr_stat in arr:
        if not arr_stat.resource == bonus_stat.resource:
            continue

        if not arr_stat.is_modifier == bonus_stat.is_modifier:
            continue

        arr_stat.amount += bonus_stat.amount
        for boosting_set in bonus_stat.boosting_sets:
            if not arr_stat.boosting_sets.has(boosting_set):
                arr_stat.boosting_sets.push_back(boosting_set)
        return

    if bonus_stat.amount > 0:
        arr.push_back(bonus_stat)




static func apply_stat(bonus_stat: BonusStat, stat: Stat) -> void :
    bonus_stat.boosting_sets = stat.modifier_boosting_sets.duplicate()
    bonus_stat.boosting_sets += stat.base_boosting_sets.duplicate()
    bonus_stat.resource = stat.resource

    if stat.modifier_amount > 0:
        bonus_stat.is_modifier = true
        bonus_stat.amount = stat.modifier_amount
        return

    if stat.negative_amount > 0:
        bonus_stat.amount -= stat.negative_amount
        return

    bonus_stat.amount = stat.base_amount





func get_amount_from_rarity(rarity: int) -> float:
    return Stats.get_amount_from_rarity(amount, rarity)





func get_bb_container_data() -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var rules: Array[Format.Rules] = [Format.Rules.USE_PREFIX]

    if resource.is_percentage or is_modifier:
        rules.push_back(Format.Rules.PERCENTAGE)

    var amount_str: String = Format.number(amount, rules)

    bb_container_data.push_back(BBContainerData.new(amount_str))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(Stats.get_bb_container_data(resource))

    return bb_container_data
