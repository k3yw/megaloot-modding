class_name BattleProfile extends Object


var equipment: ItemContainer = ItemContainer.new(ItemContainerResources.EQUIPMENT, 8)
var removed_status_effects: Array[StatusEffectResource] = []

var active_battle_actions: Array[BattleAction] = []
var active_status_effects: Array[StatusEffect] = []

var active_item_sets: Array[ItemSetResource] = []

var turns: Array[BattleTurn] = [BattleTurn.new()]
var stats: Array[Stat] = []

var external_stats: Array[Stat] = []

var free_ability_uses: int = 0

var consumed_potions: int = 0
var stun_turns_left: int = 0




func get_valid_turns() -> Array[BattleTurn]:
    var valid_turns: Array[BattleTurn] = []

    for turn in turns:
        if not is_instance_valid(turn):
            continue
        valid_turns.push_back(turn)

    return valid_turns


func get_previous_turns() -> Array[BattleTurn]:
    var valid_turns: Array[BattleTurn] = get_valid_turns()
    if valid_turns.size():
        valid_turns.pop_back()
    return valid_turns


func get_curr_turn() -> BattleTurn:
    if not turns.size():
        return BattleTurn.new()

    if not is_instance_valid(turns.back()):
        turns[turns.size() - 1] = BattleTurn.new()

    return turns.back()


func get_last_turn() -> BattleTurn:
    var size: int = turns.size()

    if not size:
        return BattleTurn.new()

    if not size + 1:
        return BattleTurn.new()

    if not is_instance_valid(turns[size - 2]):
        return BattleTurn.new()

    return turns[size - 2]




func get_total_dodges() -> int:
    var total_dodges: int = 0
    for turn in get_valid_turns():
        total_dodges += turn.dodges
    return total_dodges




func consume_stack(status_effect_resource: StatusEffectResource, amount: float = 1) -> void :
    if not has_active_status_effect_resource(status_effect_resource):
        return

    var new_amount: float = amount
    if amount == -1:
        new_amount = get_status_effect_amount(status_effect_resource)

    StatusEffect.add(get_curr_turn().consumed_stacks, status_effect_resource, new_amount)
    remove_matching_status_effects(status_effect_resource, new_amount)




func has_timeout() -> bool:
    return has_active_status_effect_resource(StatusEffects.TIMEOUT)

func is_stunned() -> bool:
    return stun_turns_left > 0

func is_confused() -> bool:
    return has_active_status_effect_resource(StatusEffects.CONFUSION)


func is_cursed() -> bool:
    if has_active_status_effect_resource(StatusEffects.BLACK_CURSE):
        return true

    if has_active_status_effect_resource(StatusEffects.CURSE):
        return true

    return false


func is_silenced() -> bool:
    return has_active_status_effect_resource(StatusEffects.SILENCE)

func is_slowed() -> bool:
    return has_active_status_effect_resource(StatusEffects.SLOWNESS)

func is_marked_by_arthur() -> bool:
    return has_active_status_effect_resource(StatusEffects.ARTHURS_MARK)



func has_active_status_effect_resource(status_effect_resource: StatusEffectResource) -> bool:
    return StatusEffects.has_active_status_effect_resource(active_status_effects, status_effect_resource)







func get_active_status_effects(type: StatusEffectType = null) -> Array[StatusEffect]:
    var list: Array[StatusEffect] = []

    for idx in range(active_status_effects.size() - 1, -1, -1):
        var status_effect: StatusEffect = active_status_effects[idx]

        if not is_instance_valid(status_effect):
            active_status_effects.remove_at(idx)
            continue

        if is_instance_valid(type):
            if not status_effect.resource.type == type:
                continue

        list.push_back(status_effect)

    return list



func get_active_debuffs() -> Array[StatusEffectResource]:
    var active_debuffs: Array[StatusEffectResource] = []

    for status_effect in get_active_status_effects(StatusEffectTypes.DEBUFF):
        active_debuffs.push_back(status_effect.resource)

    return active_debuffs




func waken() -> void :
    for status_effect in get_active_status_effects():
        if status_effect.resource.is_temporary:
            if status_effect.resource == StatusEffects.TIMEOUT:
                continue

            if status_effect.resource == StatusEffects.STUN:
                continue

            remove_matching_status_effects(status_effect.resource, 1)

    if stun_turns_left > 0:
        process_stun()


func process_stun() -> void :
    stun_turns_left -= 1
    if stun_turns_left == 0:
        remove_matching_status_effects(StatusEffects.STUN, 1)



func remove_random_buff() -> void :
    var buffs: Array[StatusEffect] = []

    for status_effect in get_active_status_effects(StatusEffectTypes.BUFF):
        buffs.push_back(status_effect.resource)

    buffs.shuffle()

    if buffs.size():
        remove_matching_status_effects(buffs[0].resource, 1)




func remove_buffs() -> void :
    for status_effect in get_active_status_effects():
        if status_effect.resource.type == StatusEffectTypes.BUFF:
            remove_matching_status_effects(status_effect.resource)





func get_status_effect_amount(status_effect_resource: StatusEffectResource) -> float:
    for status_effect in active_status_effects:
        if not is_instance_valid(status_effect):
            continue

        if status_effect.resource == status_effect_resource:
            return roundf(status_effect.amount)

    return 0



func get_total_status_effect_amount() -> float:
    var amount: float = 0.0
    for status_effect in active_status_effects:
        if not is_instance_valid(status_effect):
            continue

        amount += status_effect.amount

    return roundf(amount)



func get_used_abilities() -> Array[AbilityResource]:
    var used_abilities: Array[AbilityResource] = []

    for turn in get_valid_turns():
        used_abilities += turn.abilities

    return used_abilities




func get_used_ability_count(ability: AbilityResource) -> int:
    var used_ability_count: int = 0

    for turn in get_valid_turns():
        if not turn.is_used_ability(ability):
            continue

        used_ability_count += 1

    return used_ability_count




func remove_matching_status_effects(arg_status_effect_resource: StatusEffectResource, amount: float = -1) -> void :
    for idx in range(active_status_effects.size() - 1, -1, -1):
        var status_effect: StatusEffect = active_status_effects[idx]
        if not is_instance_valid(status_effect):
            active_status_effects.remove_at(idx)
            continue

        var status_effect_resource: StatusEffectResource = active_status_effects[idx].resource

        if status_effect_resource == arg_status_effect_resource:
            active_status_effects[idx].amount -= amount

            if active_status_effects[idx].amount <= 0 or amount == -1:
                active_status_effects.remove_at(idx)

            return




func can_receive_status_effect(status_effect_resource: StatusEffectResource) -> bool:
    if status_effect_resource.limit == -1:
        return true

    for status_effect in get_active_status_effects():
        if status_effect.resource == status_effect_resource:
            if status_effect.amount >= status_effect_resource.limit:
                return false

    return true










func cleanup() -> void :
    if is_instance_valid(equipment):
        equipment.cleanup()
        equipment.free()

    for turn in get_valid_turns():
        turn.cleanup()

    for stat in stats:
        if not is_instance_valid(stat):
            continue
        stat.free()
