class_name StatUtils








static func multiply(stat_amount: float, modifier_amount: float) -> float:
    var new_amount: float = stat_amount * modifier_amount * 0.01

    if new_amount < 1.0:
        return ceilf(new_amount)

    return floorf(new_amount)




static func modify(stat_amount: float, modifier_amount: float) -> float:
    var new_amount: float = stat_amount * (100.0 + modifier_amount) * 0.01
    return roundf(new_amount * 10.0) / 10.0








static func try_to_add_stat(array_ref: Array[Stat], stat: Stat) -> void :
    if not is_instance_valid(stat.resource) or stat.resource.name.is_empty():
        return

    for array_stat in array_ref:
        if not is_instance_valid(array_stat):
            continue

        if array_stat.resource == stat.resource:
            return

    array_ref.push_back(stat)




static func set_stat_amount(array_ref: Array[Stat], stat: Stat) -> void :
    if not is_instance_valid(stat.resource) or stat.resource.name.is_empty():
        return

    for array_stat in array_ref:
        if not is_instance_valid(array_stat):
            continue

        if array_stat.try_to_set_stat(stat):
            return

    try_to_add_stat(array_ref, stat)




static func change_stat_amount(array_ref: Array[Stat], stat: Stat) -> void :
    if not is_instance_valid(stat) or not is_instance_valid(stat.resource) or stat.resource.name.is_empty():
        return

    for idx in array_ref.size():
        var array_stat: Stat = array_ref[idx]
        if not is_instance_valid(array_stat):
            continue

        if stat.try_to_change_stat(array_stat):
            array_ref[idx] = stat
            array_stat.free()
            return

    try_to_add_stat(array_ref, stat)





static func get_attack_type(arg_attack_type: StatResource) -> StatResource:
    match arg_attack_type:
        Stats.MAGIC_DAMAGE: return Stats.MAGIC_ATTACK
        Stats.FREEZE_DAMAGE: return Stats.FREEZE_ATTACK
        Stats.ARMOR_DAMAGE: return Stats.ARMORED_ATTACK
        Stats.PHYSICAL_DAMAGE: return Stats.PHYSICAL_ATTACK

    return null
