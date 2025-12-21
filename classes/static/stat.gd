class_name Stat extends Object



var resource: StatResource = StatResource.new()

var base_boosting_sets: Array[ItemSetResource] = []
var modifier_boosting_sets: Array[ItemSetResource] = []

var base_amount: float = 0.0
var modifier_amount: float = 0.0
var negative_amount: float = 0.0

var base_amounts: Array[float] = []



static func sort_by_name(a: Stat, b: Stat) -> bool:
    return a.resource.name < b.resource.name





func _init(args: Array = []) -> void :
    if args.is_empty():
        return

    if is_instance_valid(args[0]) and args[0] is Stat:
        set_stat(args[0])

    if args[0] is StatResource:
        if args[1] >= 0:
            base_amount = args[1]

        if args[1] < 0:
            negative_amount = args[1] * -1

        resource = args[0]


    if args[0] is BonusStat and is_instance_valid(args[0]):
        assign_bonus_stat(args[0])





func assign_bonus_stat(bonus_stat: BonusStat) -> void :
    resource = bonus_stat.resource

    if bonus_stat.is_modifier:
        modifier_boosting_sets = bonus_stat.boosting_sets.duplicate()
        modifier_amount += bonus_stat.amount
        return

    if bonus_stat.amount < 0:
        negative_amount -= bonus_stat.amount
        return

    base_boosting_sets = bonus_stat.boosting_sets.duplicate()
    base_amount += bonus_stat.amount



func set_stat(stat: Stat) -> void :
    resource = stat.resource

    base_boosting_sets = stat.base_boosting_sets.duplicate()
    modifier_boosting_sets = stat.modifier_boosting_sets.duplicate()

    base_amount = stat.base_amount
    modifier_amount = stat.modifier_amount
    negative_amount = stat.negative_amount



func try_to_set_stat(stat: Stat) -> bool:
    if not stat.resource == resource:
        return false
    set_stat(stat)
    return true


func set_rarity(rarity: int) -> void :
    modifier_amount = Stats.get_amount_from_rarity(modifier_amount, rarity)
    base_amount = Stats.get_amount_from_rarity(base_amount, rarity)


func try_to_change_stat(stat: Stat) -> bool:
    if not stat.resource == resource:
        return false

    base_amount += stat.base_amount
    if stat.base_amount > 0.0:
        for boosting_set in stat.base_boosting_sets:
            if base_boosting_sets.has(boosting_set):
                continue
            base_boosting_sets.push_back(boosting_set)

    modifier_amount += stat.modifier_amount
    if stat.modifier_amount > 0.0:
        for boosting_set in stat.modifier_boosting_sets:
            if modifier_boosting_sets.has(boosting_set):
                continue
            modifier_boosting_sets.push_back(boosting_set)

    negative_amount += stat.negative_amount
    return true





func get_bonus_stats() -> Array[BonusStat]:
    var bonus_stats: Array[BonusStat] = []

    if base_amount > 0.0:
        var bonus_stat = BonusStat.new(resource, base_amount)
        bonus_stat.boosting_sets = base_boosting_sets.duplicate()
        bonus_stats.push_back(bonus_stat)

    if modifier_amount > 0.0:
        var bonus_stat = BonusStat.new(resource, modifier_amount, true)
        bonus_stat.boosting_sets = modifier_boosting_sets.duplicate()
        bonus_stats.push_back(bonus_stat)

    return bonus_stats
