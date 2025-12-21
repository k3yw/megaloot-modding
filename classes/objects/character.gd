class_name Character extends Object

enum UseAbilityResult{SUCCESS, FAIL, MANA}

signal stat_changed(stat: StatResource, old_amount: float)

signal about_to_start_attacking(targets: Array[Character])
signal about_to_receive_damage(attacker: Character, damage_data: DamageData)
signal about_to_deal_damage(target: Character, damage_data: DamageData)

signal attack_avoided(attacker: Character, damage_data: DamageData)
signal about_to_attack(target: Character, damage_data: DamageData)
signal attack_hit(target: Character, damage_data: DamageData)
signal recieved_status_effect(status_effect: StatusEffect)
signal received_damage(damage_result: DamageResult)
signal dealt_damage(damage_result: DamageResult)
signal counter_attacked(target: Character)
signal got_attacked(attacker: Character)
signal killed_target(target: Character)
signal attacked(target: Character)
signal parried(target: Character)
signal gold_coins_changed(new_amount: float)
signal diamonds_changed(new_amount: float)
signal magic_shield_broke
signal missed


var base_passive: Passive = Passive.new()

var transformed_stats: Array[StatResource] = []

var adapted_stats: Array[StatResource] = []


var specializations: Array[Specialization] = []
var active_trials: Array[Trial] = []
var stats: Array[Stat] = []

var doubled_stat: StatResource = StatResource.new()

var equipment_stats: Array[Stat] = []

var inventory: ItemContainer = ItemContainer.new(ItemContainerResources.INVENTORY, Slot.INVENTORY_SLOTS_PER_PAGE)
var equipment: ItemContainer = ItemContainer.new(ItemContainerResources.EQUIPMENT, 8)


var battle_profile: BattleProfile = BattleProfile.new()

var gold_coins_earned: float = 0
var gold_coins_spent: float = 0
var gold_coins: float = 0
var diamonds: float = 0


var battle_log_name: Array[String] = []
var character_id: String = ""
var floor_number: int = 0


var is_phantom: bool = false
var died: bool = false


var stat_change_process_requested: bool = false
var cached_stats: Dictionary = {}





static func get_item_set_count(character: Character, item_set: ItemSetResource) -> int:
    if not is_instance_valid(character) or item_set == ItemSets.GENERIC:
        return 0

    var count: int = ItemUtils.get_item_set_count(character.get_equipment_items(false), item_set)
    count += character.battle_profile.active_item_sets.count(item_set)

    if count > 0:
        count += ItemUtils.get_item_set_count(character.get_equipment_items(false), ItemSets.GENERIC)
        count += character.battle_profile.active_item_sets.count(ItemSets.GENERIC)

    return count



static func get_gold_coins(character: Character) -> float:
    if not is_instance_valid(character):
        return 0.0

    return character.gold_coins


static func get_diamonds(character: Character) -> float:
    if not is_instance_valid(character):
        return 0.0

    return character.diamonds





func get_translated_log_name() -> String:
    if battle_log_name.size() == 0:
        return ""

    if battle_log_name.size() == 2:
        return T.get_translated_string(battle_log_name[0], battle_log_name[1])

    return battle_log_name[0]




func change_stat_amount(array_ref: Array[Stat], stat: Stat) -> void :
    var curr_amount: float = get_stat_amount(stat.resource)[0]
    stat.negative_amount = minf(stat.negative_amount, curr_amount)

    StatUtils.change_stat_amount(array_ref, stat)
    stat_change_process_requested = true
    cache_stats()

    stat_changed.emit(stat.resource, curr_amount)




func set_stat_amount(stat: StatResource, amount: float) -> void :
    var curr_amount: float = get_stat_amount(stat)[0]
    StatUtils.set_stat_amount(stats, Stat.new([stat, amount]))
    stat_changed.emit(stat, curr_amount)



func change_gold_coins(amount: float) -> void :
    gold_coins += amount
    gold_coins_changed.emit(gold_coins)


func change_diamonds(amount: float) -> void :
    diamonds += amount
    diamonds_changed.emit(diamonds)


func add_stat(arr: Array[Stat], stat: Stat) -> void :
    if not is_instance_valid(stat):
        return

    cache_stats()

    var old_amount: float = get_stat_amount(stat.resource)[0]
    var value_stat: StatResource = null
    var new_amount: float = 0

    change_stat_amount(arr, stat)
    new_amount = get_stat_amount(stat.resource)[0]


    match stat.resource:
        Stats.ARMOR: value_stat = Stats.ACTIVE_ARMOR
        Stats.MAX_HEALTH: value_stat = Stats.HEALTH
        Stats.MAX_MANA: value_stat = Stats.MANA

    if is_instance_valid(value_stat):
        change_stat_amount(stats, Stat.new([value_stat, maxf(0, new_amount - old_amount)]))







func can_use_ability(ability: AbilityResource) -> UseAbilityResult:
    if not is_instance_valid(ability):
        return UseAbilityResult.FAIL

    if battle_profile.has_active_status_effect_resource(StatusEffects.SILENCE):
        return UseAbilityResult.FAIL

    if ability.use_limit and battle_profile.get_used_ability_count(ability) >= ability.use_limit:
        return UseAbilityResult.FAIL

    if battle_profile.free_ability_uses <= 0:
        if ability.mana_cost and ability.mana_cost > get_mana():
            return UseAbilityResult.MANA

    return UseAbilityResult.SUCCESS





func get_active_specializations() -> Array[Specialization]:
    var active_item_sets: Array[ItemSetResource] = get_active_item_sets()
    var active_specializations: Array[Specialization] = []


    for active_item_set in active_item_sets:
        if not Specializations.LIST.has(active_item_set):
            continue

        for specialization in Specializations.LIST[active_item_set].arr:
            if not is_instance_valid(specialization.synergy_item_set):
                continue

            if not active_item_sets.has(specialization.synergy_item_set):
                continue

            active_specializations.push_back(specialization)


    return active_specializations






func get_active_item_sets() -> Array[ItemSetResource]:
    var active_item_sets: Array[ItemSetResource] = battle_profile.active_item_sets.duplicate()

    if not is_instance_valid(equipment):
        return active_item_sets

    for active_item_set in equipment.get_active_item_sets():
        if active_item_sets.has(active_item_set):
            continue

        active_item_sets.push_back(active_item_set)

    return active_item_sets





func get_equipment_items(include_burnout: bool = true) -> Array[Item]:
    var equipment_items: Array[Item] = []

    if is_instance_valid(equipment):
        for item in equipment.get_items():
            if not include_burnout and item.has_burnout():
                continue
            equipment_items.push_back(item)

    return equipment_items




func get_limited_active_item_sets() -> Array[ItemSetResource]:
    var limited_active_item_sets: Array[ItemSetResource] = equipment.get_active_item_sets()

    for item_set in battle_profile.active_item_sets:
        limited_active_item_sets.erase(item_set)

    return limited_active_item_sets




func get_stats_from_items() -> Array[Stat]:
    for stat in equipment_stats:
        stat.free()
    equipment_stats.clear()

    var items: Array[Item] = get_equipment_items()

    for item in inventory.get_items():
        if item.resource.is_special:
            for bonus_stat in item.resource.bonus_stats:
                StatUtils.change_stat_amount(equipment_stats, Stat.new([bonus_stat]))

    for idx in items.size():
        var item: Item = items[idx]

        for bonus_stat in item.get_bonus_stats():
            StatUtils.change_stat_amount(equipment_stats, Stat.new([bonus_stat]))

            for supporting_idx in items.size():
                var supporting_item: Item = items[supporting_idx]
                for boosting_set in bonus_stat.boosting_sets:
                    if not supporting_item.get_set_resources().has(boosting_set):
                        continue

                    if supporting_idx == idx:
                        continue

                    StatUtils.change_stat_amount(equipment_stats, Stat.new([bonus_stat]))


    return equipment_stats






func get_all_stat_arr() -> Array:
    var curr_turn: BattleTurn = battle_profile.get_curr_turn()
    var all_stat_arr: Array = [stats, battle_profile.external_stats, battle_profile.stats, curr_turn.stats]
    var active_abilites: Array[Ability] = curr_turn.abilities


    for ability in active_abilites:
        var stat_arr: Array[Stat] = []

        if not is_instance_valid(ability):
            continue

        if not is_instance_valid(ability.resource):
            continue

        for bonus_stat in ability.resource.bonus_stats_while_active:
            stat_arr.push_back(Stat.new([bonus_stat]))
        all_stat_arr.push_back(stat_arr)

    return all_stat_arr








func cache_stat(stat: Stat) -> void :
    cached_stats[stat.resource]["base_amount"] += stat.base_amount
    cached_stats[stat.resource]["modifier_amount"] += stat.modifier_amount
    cached_stats[stat.resource]["negative_amount"] += stat.negative_amount




func cache_stats() -> void :
    cached_stats.clear()

    for stat_resource in Stats.LIST:
        cached_stats[stat_resource] = {
            "modifier_amount": 0, 
            "base_amount": 0, 
            "negative_amount": 0, 
            "final_amount": 0, 
            }

    for stat_arr in get_all_stat_arr():
        for stat in stat_arr:
            if not is_instance_valid(stat):
                continue

            stat = stat as Stat

            cache_stat(stat)


    for stat in get_stats_from_items():
        stat = stat as Stat

        if not is_instance_valid(stat):
            continue

        cache_stat(stat)


    for item_set in get_active_item_sets():
        for _i in Character.get_item_set_count(self, item_set):
            if item_set.bonus_stats.size() <= _i:
                continue

            var bonus_stat_arr = item_set.bonus_stats[_i]
            if is_instance_valid(bonus_stat_arr):
                bonus_stat_arr = bonus_stat_arr as BonusStatsArray
                for bonus_stat in bonus_stat_arr.bonus_stats:
                    cache_stat(Stat.new([bonus_stat]))


    for passive in get_passives():
        for bonus_stat in passive.bonus_stats:
            var stat: Stat = Stat.new([bonus_stat])
            cache_stat(stat)
            stat.free()

    recalculate_cached_stats()





func recalculate_cached_stats() -> void :
    var active_specializations: Array[Specialization] = get_active_specializations()
    var curr_turn: BattleTurn = battle_profile.get_curr_turn()
    var active_item_sets: Array[ItemSetResource] = []
    var passives: Array[Passive] = get_passives()


    for stat_resource in Stats.LIST:
        cached_stats[stat_resource]["final_amount"] = StatUtils.modify(cached_stats[stat_resource]["base_amount"], cached_stats[stat_resource]["modifier_amount"])
        cached_stats[stat_resource]["final_amount"] -= cached_stats[stat_resource]["negative_amount"]

    active_item_sets = get_active_item_sets()


    for item_set in get_active_item_sets():
        if is_instance_valid(item_set.game_logic_script):
            var logic_script: GameLogicScript = item_set.game_logic_script.new()
            logic_script.character = self
            for bonus_stat in logic_script.get_bonus_stats():
                if bonus_stat.is_modifier:
                    cached_stats[bonus_stat.resource]["modifier_amount"] += bonus_stat.amount
                    continue
                cached_stats[bonus_stat.resource]["base_amount"] += bonus_stat.amount

            logic_script.free()


    var elemental_power: float = cached_stats[Stats.ELEMENTAL_POWER]["final_amount"]
    var active_armor: float = cached_stats[Stats.ACTIVE_ARMOR]["final_amount"]
    var max_health: float = cached_stats[Stats.MAX_HEALTH]["final_amount"]
    var wisdom: float = cached_stats[Stats.WISDOM]["final_amount"]
    var greed: float = cached_stats[Stats.GREED]["final_amount"]

    var bonus_multiplier_adaptive_attack: float = 0.0
    var bonus_base_adaptive_attack: float = 0.0

    if is_instance_valid(doubled_stat) and cached_stats.has(doubled_stat):
        cached_stats[doubled_stat]["base_amount"] *= 2


    for stat_resource in Stats.LIST:
        match stat_resource:
            Stats.TENACITY:
                if passives.has(Passives.FREEDOM_DRIVE) and battle_profile.has_active_status_effect_resource(StatusEffects.INVULNERABILITY):
                    cached_stats[stat_resource]["base_amount"] += 100

            Stats.ACCURACY:
                if battle_profile.has_active_status_effect_resource(StatusEffects.BLINDNESS):
                    cached_stats[stat_resource]["base_amount"] -= 100

                if battle_profile.has_active_status_effect_resource(StatusEffects.CONFUSION):
                    cached_stats[stat_resource]["base_amount"] -= 100


            Stats.PHYSICAL_ATTACK:
                if active_item_sets.has(ItemSets.DEMONIC):
                    cached_stats[stat_resource]["modifier_amount"] += roundf(max_health / 25)

            Stats.ARMOR:
                if transformed_stats.has(Stats.ELDERSHIP):
                    cached_stats[stat_resource]["base_amount"] += wisdom

            Stats.CRIT_CHANCE:
                if active_item_sets.has(ItemSets.POVERTY) and get_health_percent() < 25:
                    cached_stats[stat_resource]["base_amount"] += 75


            Stats.CRITICAL_DAMAGE:
                if active_item_sets.has(ItemSets.HUNTER):
                    var excess_crit: float = maxf(0.0, cached_stats[Stats.CRIT_CHANCE]["base_amount"] - 100)
                    cached_stats[stat_resource]["base_amount"] += 10.0 * excess_crit


            Stats.CINDER_DAMAGE:
                cached_stats[stat_resource]["modifier_amount"] += elemental_power
                if active_item_sets.has(ItemSets.MAGMA):
                    cached_stats[stat_resource]["base_amount"] += ceilf(max_health * 0.1)

            Stats.TOXICITY:
                cached_stats[stat_resource]["modifier_amount"] += elemental_power

            Stats.ELECTRICITY:
                cached_stats[stat_resource]["modifier_amount"] += elemental_power


            Stats.AGILITY:
                var multiply_amount: int = 1

                cached_stats[stat_resource]["base_amount"] *= multiply_amount

                if battle_profile.is_slowed():
                    cached_stats[stat_resource]["negative_amount"] += 100

                cached_stats[stat_resource]["negative_amount"] += maxf(0.0, active_armor)


            Stats.FAITH:
                cached_stats[stat_resource]["negative_amount"] += maxf(0.0, greed)


            Stats.LETHALITY:
                if active_item_sets.has(ItemSets.CATACLYSM):
                    cached_stats[stat_resource]["base_amount"] += 45

            Stats.TOTAL_ATTACKS:
                if curr_turn.is_used_ability(Abilities.TRIPLE_ATTACK):
                    cached_stats[stat_resource]["base_amount"] += 2

                if active_specializations.has(Specializations.DESERTER):
                    cached_stats[stat_resource]["base_amount"] += floorf(float(floor_number + 1) / 10)


                if active_item_sets.has(ItemSets.SWIFTNESS):
                    var multiply_amount: int = 2

                    cached_stats[stat_resource]["base_amount"] *= multiply_amount

                if battle_profile.has_active_status_effect_resource(StatusEffects.EXHAUSTION):
                    cached_stats[stat_resource]["base_amount"] = minf(1.0, cached_stats[stat_resource]["base_amount"])

            Stats.MAX_MANA:
                if passives.has(Passives.MANAFLOW):
                    cached_stats[stat_resource]["base_amount"] = 1


        if adapted_stats.has(stat_resource):
            bonus_multiplier_adaptive_attack += cached_stats[stat_resource]["modifier_amount"]
            bonus_base_adaptive_attack += cached_stats[stat_resource]["base_amount"]

            cached_stats[stat_resource]["modifier_amount"] = 0
            cached_stats[stat_resource]["base_amount"] = 0


        cached_stats[stat_resource]["final_amount"] = StatUtils.modify(cached_stats[stat_resource]["base_amount"], cached_stats[stat_resource]["modifier_amount"])







    var final_physical_attack: float = cached_stats[Stats.PHYSICAL_ATTACK]["final_amount"]
    var final_armor: float = cached_stats[Stats.ARMOR]["final_amount"]

    for stat_resource in Stats.LIST:
        match stat_resource:
            Stats.ADAPTIVE_ATTACK:
                cached_stats[stat_resource]["final_amount"] += StatUtils.modify(bonus_base_adaptive_attack, bonus_multiplier_adaptive_attack)
                if passives.has(Passives.LIBERATION):
                    cached_stats[stat_resource]["final_amount"] += final_armor

            Stats.PHYSICAL_ATTACK:
                if active_specializations.has(Specializations.CHROMASPITE):
                    cached_stats[stat_resource]["final_amount"] = ceilf(cached_stats[stat_resource]["final_amount"] * 0.25)

            Stats.ARMOR:
                if passives.has(Passives.EMPTY_BASTION):
                    cached_stats[stat_resource]["final_amount"] *= 8

                if passives.has(Passives.LIBERATION):
                    cached_stats[stat_resource]["final_amount"] = 0

            Stats.TOXICITY:
                if active_specializations.has(Specializations.CHROMASPITE):
                    cached_stats[stat_resource]["final_amount"] += floorf(final_physical_attack * 0.75)

            Stats.CRIT_CHANCE:
                if active_item_sets.has(ItemSets.HUNTER):
                    cached_stats[stat_resource]["base_amount"] = minf(100.0, cached_stats[stat_resource]["base_amount"])



    for stat_resource in Stats.LIST:

        if not stat_resource.max_amount == -1:
            cached_stats[stat_resource]["final_amount"] = minf(float(stat_resource.max_amount), cached_stats[stat_resource]["final_amount"])


        cached_stats[stat_resource]["final_amount"] -= cached_stats[stat_resource]["negative_amount"]
        if not stat_resource.ignore_minimum_amount:
            cached_stats[stat_resource]["final_amount"] = maxf(stat_resource.minimum_amount, cached_stats[stat_resource]["final_amount"])

        cached_stats[stat_resource]["final_amount"] = ceilf(cached_stats[stat_resource]["final_amount"])








func get_stat_amount(stat_resource: StatResource) -> Array[float]:
    if not is_instance_valid(stat_resource):
        return [0, 0, 0]

    if not cached_stats.has(stat_resource):
        return [0, 0, 0]

    return [cached_stats[stat_resource]["final_amount"], cached_stats[stat_resource]["base_amount"], cached_stats[stat_resource]["modifier_amount"]]







func get_attack_type() -> StatResource:
    var attacks: Array[float] = [get_physical_attack(), get_magic_attack(), get_freeze_attack(), get_armored_attack()]
    var chosen_idx: int = attacks.find(attacks.max())

    match chosen_idx:
        1: return Stats.MAGIC_ATTACK
        2: return Stats.FREEZE_ATTACK
        3: return Stats.ARMORED_ATTACK

    return Stats.PHYSICAL_ATTACK




func get_attack_damage_type() -> StatResource:
    match get_attack_type():
        Stats.MAGIC_ATTACK: return Stats.MAGIC_DAMAGE
        Stats.FREEZE_ATTACK: return Stats.FREEZE_DAMAGE
        Stats.ARMORED_ATTACK: return Stats.ARMOR_DAMAGE

    return Stats.PHYSICAL_DAMAGE










func get_status_effects_on_hit() -> Array[StatusEffect]:
    var active_item_sets: Array[ItemSetResource] = get_active_item_sets()
    var turn: BattleTurn = battle_profile.get_curr_turn()
    var status_effects_on_hit: Array[StatusEffect] = []

    var electricity: float = get_stat_amount(Stats.ELECTRICITY)[0]
    var toxicity: float = get_stat_amount(Stats.TOXICITY)[0]
    var dazzle: float = get_stat_amount(Stats.DAZZLE)[0]


    if turn.is_used_ability(Abilities.TOXIC_ATTACK):
        status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.POISON, 1))

    if electricity:
        status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.ELECTRO_CHARGE, electricity))

    if toxicity:
        status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.POISON, toxicity))

    if dazzle:
        status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.SPARKLE, dazzle))

    if turn.is_used_ability(Abilities.STUN_ATTACK) or turn.is_used_ability(Abilities.STUN_STRIKE) or turn.is_used_ability(Abilities.HEADBUTT):
        status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.STUN))

    if turn.is_used_ability(Abilities.CONFUSION_STRIKE):
        status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.CONFUSION, 2))


    return status_effects_on_hit




func get_adjacent_status_effects_on_hit() -> Array[StatusEffect]:
    var status_effects_on_hit: Array[StatusEffect] = []
    var electricity: float = get_stat_amount(Stats.ELECTRICITY)[0]

    if electricity:
        var status_effect = StatusEffect.new(StatusEffects.ELECTRO_CHARGE, maxf(1, roundi(float(electricity) * 0.25)))
        status_effects_on_hit.push_back(status_effect)


    return status_effects_on_hit







func heal(amount: float) -> float:
    var curr_turn: BattleTurn = battle_profile.get_curr_turn()
    var new_amount: float = amount

    if not get_active_item_sets().has(ItemSets.FLESH):
        new_amount = minf(get_missing_health(), new_amount)

    if battle_profile.is_cursed():
        new_amount *= 0.75

    new_amount = roundf(new_amount)

    curr_turn.percent_health_recovered += Math.get_percentage(get_max_health(), new_amount)
    curr_turn.health_recovered += new_amount
    change_health(new_amount)


    return new_amount








func try_to_add_status_effect(applier: Character, status_effect_resource: StatusEffectResource, amount: float = 1.0) -> bool:
    var new_amount: float = amount

    if not status_effect_resource.limit == -1:
        new_amount = minf(status_effect_resource.limit, amount)
        for status_effect in battle_profile.get_active_status_effects():
            if status_effect.resource == status_effect_resource:
                new_amount = minf(maxf(0, status_effect_resource.limit - status_effect.amount), new_amount)

    if not new_amount:
        return false

    var curr_turn: BattleTurn = battle_profile.get_curr_turn()
    match status_effect_resource:
        StatusEffects.STUN:
            curr_turn.stopped_attacking = true

    if is_instance_valid(applier):
        StatusEffect.add(applier.battle_profile.get_curr_turn().applied_status_effects, status_effect_resource, new_amount)
    StatusEffect.add(curr_turn.received_status_effects, status_effect_resource, new_amount)
    StatusEffect.add(battle_profile.active_status_effects, status_effect_resource, new_amount)

    cache_stats()

    return true





func set_status_effect_amount(status_effect_resource: StatusEffectResource, amount: float) -> void :
    if battle_profile.removed_status_effects.has(status_effect_resource):
        battle_profile.remove_matching_status_effects(status_effect_resource)
        return

    for status_effect in battle_profile.active_status_effects:
        if not is_instance_valid(status_effect):
            return

        if status_effect.resource == status_effect_resource:
            status_effect.amount = amount

            if amount <= 0:
                battle_profile.active_status_effects.erase(status_effect)

            return


    if amount <= 0:
        return

    var status_effect = StatusEffect.new(status_effect_resource, amount)
    battle_profile.active_status_effects.push_back(status_effect)

    cache_stats()








func try_to_crit(rand: RandomNumberGenerator, damage_type: StatResource) -> bool:
    if transformed_stats.has(Stats.OMNI_CRIT_CHANCE):
        return Math.rand_success(get_crit_chance(), rand)

    if damage_type == Stats.PHYSICAL_DAMAGE:
        return Math.rand_success(get_crit_chance(), rand)

    return false



func modify_status_effect_resource(status_effect_resource: StatusEffectResource) -> StatusEffectResource:




    return status_effect_resource





func try_to_dodge(rand: RandomNumberGenerator) -> bool:
    if battle_profile.is_marked_by_arthur():
        return false

    if battle_profile.is_stunned():
        return false


    var agility: float = get_stat_amount(Stats.AGILITY)[0]

    if get_active_item_sets().has(ItemSets.SCOUT) and agility > 0.0:
        return true

    if Math.rand_success(agility, rand):
        return true


    return false





func try_to_reduce_damage(initial_damage: float) -> float:
    var damage_to_reduce: float = 0.0

    if is_equal_approx(initial_damage, 0.0):
        return damage_to_reduce

    if battle_profile.has_active_status_effect_resource(StatusEffects.MALICE_SHIELD):
        battle_profile.consume_stack(StatusEffects.MALICE_SHIELD)
        damage_to_reduce += get_stat_amount(Stats.MALICE)[0] + 1.0

    if damage_to_reduce >= initial_damage:
        return damage_to_reduce

    if battle_profile.has_active_status_effect_resource(StatusEffects.ARMOR_SHIELD):
        battle_profile.consume_stack(StatusEffects.ARMOR_SHIELD)
        damage_to_reduce += get_stat_amount(Stats.ARMOR)[0] + 1.0

    return damage_to_reduce



func try_to_hit(target: Character, damage_accuracy: float) -> bool:
    var accuracy: float = damage_accuracy
    if target.battle_profile.has_active_status_effect_resource(StatusEffects.ELUSIVE):
        accuracy -= 100
    return Math.rand_success(accuracy, RNGManager.gameplay_rand)


func try_to_block() -> bool:
    if battle_profile.is_marked_by_arthur():
        return false

    if base_passive == Passives.IRONCLAD:
        return true

    return false








func try_to_parry() -> bool:
    if battle_profile.is_marked_by_arthur():
        return false

    if battle_profile.is_stunned():
        return false

    if battle_profile.has_timeout():
        return false

    if battle_profile.get_curr_turn().is_used_ability(Abilities.REPULSE):
        return true

    if battle_profile.get_status_effect_amount(StatusEffects.COMBAT_INSIGHT) >= 5:
        battle_profile.remove_matching_status_effects(StatusEffects.COMBAT_INSIGHT, 5)
        return true


    return false







func try_to_multi_attack() -> bool:
    var curr_turn: BattleTurn = battle_profile.get_curr_turn()

    for status_effect in curr_turn.get_consumed_stacks():
        if status_effect.resource == StatusEffects.MULTI_ATTACK_CHARGE:
            return true

    return false




func get_all_equipment_slots() -> Array[Slot]:
    var equipment_slots: Array[Slot] = []

    for index in equipment.items.size():
        equipment_slots.push_back(Slot.new(equipment, index))

    return equipment_slots



func get_all_inventory_slots() -> Array[Slot]:
    var inventory_slots: Array[Slot] = []

    for index in inventory.items.size():
        inventory_slots.push_back(Slot.new(inventory, index))

    return inventory_slots


func get_all_item_slots() -> Array[Slot]:
    return get_all_equipment_slots() + get_all_inventory_slots()


func get_equipped_weapon() -> Item:
    for item in ItemUtils.get_valid_items(equipment.items):
        if item.resource.socket_type == SocketTypes.WEAPON:
            return item

    return null









func get_owned_items() -> Array[Item]:
    var owned_equipment: Array[Item] = []

    for item in ItemUtils.get_valid_items(inventory.items):
        owned_equipment.push_back(item)

    for item in ItemUtils.get_valid_items(equipment.items):
        owned_equipment.push_back(item)

    return owned_equipment





func has_weapon() -> bool:
    for item in ItemUtils.get_valid_items(get_owned_items()):
        if item.resource.socket_type == SocketTypes.WEAPON:
            return true

    return false



func reset_health() -> void :
    set_health(get_max_health())


func reset_active_armor() -> void :
    if get_passives().has(Passives.EMPTY_BASTION):
        set_active_armor(0.0)
        return
    set_active_armor(get_stat_amount(Stats.ARMOR)[0])



func update_stats():
    set_health(get_max_health())


func refill_magic_shield() -> void :
    set_status_effect_amount(StatusEffects.MAGIC_SHIELD, 3)

func break_magic_shield() -> void :
    set_status_effect_amount(StatusEffects.MAGIC_SHIELD, 0)
    battle_profile.get_curr_turn().magic_shields_broke_on_self += 1
    await Await.emit(magic_shield_broke)

func has_magic_shield() -> bool:
    return battle_profile.get_status_effect_amount(StatusEffects.MAGIC_SHIELD) > 0


func is_invulnerable() -> bool:
    return battle_profile.has_active_status_effect_resource(StatusEffects.INVULNERABILITY)







func get_recovery() -> float:
    return get_stat_amount(Stats.RECOVERY)[0]


func get_penetration() -> float:
    return clampf(get_stat_amount(Stats.PENETRATION)[0], 0, 100)


func get_toxicity() -> float:
    return get_stat_amount(Stats.TOXICITY)[0]




func get_crit_chance() -> int:
    return int(get_stat_amount(Stats.CRIT_CHANCE)[0])




func get_max_health() -> float:
    var max_health: float = get_stat_amount(Stats.MAX_HEALTH)[0]
    return maxf(1.0, roundf(max_health))

func get_health() -> float:
    return floorf(get_stat_amount(Stats.HEALTH)[0])




func get_mana() -> int:
    return int(get_stat_amount(Stats.MANA)[0])

func get_max_mana() -> int:
    return int(get_stat_amount(Stats.MAX_MANA)[0])









func get_health_percent() -> float:
    return Math.get_percentage(get_max_health(), get_health())






func get_physical_damage(base_damage: float) -> float:
    var fury: float = battle_profile.get_status_effect_amount(StatusEffects.FURY)
    var physical_damage: float = base_damage + get_stat_amount(Stats.COMBAT)[0]
    physical_damage += roundf(physical_damage * fury * 0.25)

    physical_damage = StatUtils.modify(physical_damage, get_stat_amount(Stats.PHYSICAL_DAMAGE)[0])

    return physical_damage





func get_magic_damage(base_damage: float) -> float:
    if not base_damage:
        return 0

    var magic_damage: float = base_damage + get_stat_amount(Stats.WISDOM)[0]
    var active_item_sets: Array[ItemSetResource] = get_active_item_sets()
    var damage_boost: float = 0.0

    if active_item_sets.has(ItemSets.ZEPHYRON):
        damage_boost += 0.25 * get_turn_size()

    if has_magic_shield() and active_item_sets.has(ItemSets.ARCANUM):
        var damage_to_boost: float = 3.75
        damage_boost += damage_to_boost

    magic_damage += ceilf(magic_damage * damage_boost)


    magic_damage = StatUtils.modify(magic_damage, get_stat_amount(Stats.MAGIC_DAMAGE)[0])

    return magic_damage





func get_freeze_damage(base_damage: float) -> float:
    if not base_damage:
        return 0

    var freeze_damage: float = base_damage
    freeze_damage = StatUtils.modify(freeze_damage, get_stat_amount(Stats.FREEZE_DAMAGE)[0])

    return freeze_damage






func get_attack_damage() -> float:
    match get_attack_damage_type():
        Stats.ARMOR_DAMAGE: return get_armored_attack()
        Stats.FREEZE_DAMAGE: return get_freeze_attack()
        Stats.MAGIC_DAMAGE: return get_magic_attack()

    return get_physical_attack()




func get_attack_damage_data(source: DamageData.Source) -> DamageData:
    var curr_turn: BattleTurn = battle_profile.get_curr_turn()
    var attack_damage_type: StatResource = get_attack_damage_type()

    if not is_instance_valid(curr_turn.attack_type) and not curr_turn.attack_type == Empty.stat_resource:
        attack_damage_type = curr_turn.attack_type

    var damage_data = DamageData.new(
        source, 
        attack_damage_type, 
        get_attack_damage(), 
        )


    damage_data.damage += get_stat_amount(Stats.ADAPTIVE_ATTACK)[0]

    damage_data.apply_multiplier(float(get_stat_amount(Stats.POWER)[0] + 100) / 100)

    var weakness_multiplier: float = maxf(0.0, 1.0 - (float(battle_profile.get_status_effect_amount(StatusEffects.WEAKNESS)) * 0.25))
    damage_data.apply_multiplier(weakness_multiplier)

    var enervation_multiplier: float = maxf(0.0, 1.0 - (float(battle_profile.get_status_effect_amount(StatusEffects.ENERVATION)) * 0.25))
    damage_data.apply_multiplier(enervation_multiplier)

    if curr_turn.is_used_ability(Abilities.ENCHANTED_ATTACK):
        damage_data.apply_multiplier(2.0)

    return damage_data





func apply_damage_output_boosters(damage_data: DamageData) -> void :
    match damage_data.type:
        Stats.PHYSICAL_DAMAGE:
            damage_data.damage = get_physical_damage(damage_data.damage)

        Stats.MAGIC_DAMAGE:
            damage_data.damage = get_magic_damage(damage_data.damage)

        Stats.FREEZE_DAMAGE:
            damage_data.damage = get_freeze_damage(damage_data.damage)








func get_physical_attack() -> float:
    var physical_attack: float = get_stat_amount(Stats.PHYSICAL_ATTACK)[0]
    var curr_turn: BattleTurn = battle_profile.get_curr_turn()
    var max_health: float = get_max_health()

    for status_effect in curr_turn.get_consumed_stacks():
        if status_effect.resource == StatusEffects.VIMBLOW:
            physical_attack += roundf(max_health * 0.25)

        if status_effect.resource == StatusEffects.OMNI_BLITZ:
            physical_attack *= status_effect.amount + 1

    return roundf(physical_attack)




func get_magic_attack() -> float:
    var magic_attack: float = get_stat_amount(Stats.MAGIC_ATTACK)[0]
    var turn: BattleTurn = battle_profile.get_curr_turn()

    for status_effect in turn.get_consumed_stacks():
        if status_effect.resource == StatusEffects.MAGIC_BLITZ:
            magic_attack *= status_effect.amount + 1

        if status_effect.resource == StatusEffects.OMNI_BLITZ:
            magic_attack *= status_effect.amount + 1


    return roundf(magic_attack)




func get_freeze_attack() -> float:
    var freeze_attack: float = get_stat_amount(Stats.FREEZE_ATTACK)[0]
    return StatUtils.modify(freeze_attack, get_stat_amount(Stats.ELEMENTAL_POWER)[0])


func get_armored_attack() -> float:
    var armored_attack: float = get_stat_amount(Stats.ARMORED_ATTACK)[0]
    return ceilf(get_stat_amount(Stats.ACTIVE_ARMOR)[0] * armored_attack * 0.01)






func get_status_effects_per_turn() -> Array[StatusEffect]:
    var active_specializations: Array[Specialization] = get_active_specializations()
    var status_effects_per_turn: Array[StatusEffect] = []

    return status_effects_per_turn





func get_starting_status_effects() -> Array[StatusEffect]:
    var active_item_sets: Array[ItemSetResource] = get_active_item_sets()
    var armor_shields: float = get_stat_amount(Stats.ARMOR_SHIELDS)[0]
    var starting_status_effects: Array[StatusEffect] = []

    if armor_shields > 0:
        starting_status_effects.push_back(StatusEffect.new(StatusEffects.ARMOR_SHIELD, armor_shields))


    return starting_status_effects






func get_passives() -> Array[Passive]:
    var active_specializations: Array[Specialization] = get_active_specializations()
    var passives: Array[Passive] = []


    if is_instance_valid(base_passive):
        passives.push_back(base_passive)


    for item in equipment.get_items():
        if item.has_burnout():
            continue

        if is_instance_valid(item.reforged_passive) and not item.reforged_passive == Empty.passive:
            passives.push_back(item.reforged_passive)


    return passives





func is_overhealed() -> bool:
    return get_health() > get_max_health()

func is_full_health() -> bool:
    return get_health() >= get_max_health()


func set_active_armor(amount: float) -> void :
    set_stat_amount(Stats.ACTIVE_ARMOR, amount)



func set_health(amount: float) -> void :
    StatUtils.set_stat_amount(stats, Stat.new([Stats.HEALTH, amount]))



func change_health(amount: float) -> void :
    change_stat_amount(stats, Stat.new([Stats.HEALTH, amount]))
    StatUtils.set_stat_amount(stats, Stat.new([Stats.HEALTH, maxf(get_health(), 0.0)]))


func change_active_armor(amount: float) -> void :
    var active_armor: float = get_stat_amount(Stats.ACTIVE_ARMOR)[0]
    var armor: float = get_stat_amount(Stats.ARMOR)[0]
    var new_amount: float = minf(armor - active_armor, amount)
    change_stat_amount(stats, Stat.new([Stats.ACTIVE_ARMOR, new_amount]))


func change_mana(amount: float) -> void :
    change_stat_amount(stats, Stat.new([Stats.MANA, amount]))
    StatUtils.set_stat_amount(stats, Stat.new([Stats.MANA, clamp(get_mana(), 0, get_stat_amount(Stats.MAX_MANA)[0])]))





func get_guard_reduction() -> float:
    var armor: float = get_stat_amount(Stats.ARMOR)[0]
    var max_reduction: = 0.75
    var scaling: = 0.005
    return max_reduction * (1.0 - exp( - scaling * armor))



func get_missing_health() -> float:
    return get_stat_amount(Stats.MAX_HEALTH)[0] - get_stat_amount(Stats.HEALTH)[0]

func get_missing_mana() -> int:
    return get_max_mana() - get_mana()

func get_missing_armor() -> float:
    return roundf(get_stat_amount(Stats.ARMOR)[0] - get_stat_amount(Stats.ACTIVE_ARMOR)[0])


func is_first_turn() -> bool:
    return get_turn_size() == 1


func get_turn_size() -> int:
    var turn_size: int = 0

    if is_instance_valid(battle_profile):
        turn_size = battle_profile.get_valid_turns().size()

    return turn_size





func cleanup() -> void :
    ObjUtils.cleanup_arr(stats)

    if is_instance_valid(battle_profile):
        battle_profile.cleanup()
        battle_profile.free()

    if is_instance_valid(inventory):
        inventory.cleanup()
        inventory.free()

    if is_instance_valid(equipment):
        equipment.cleanup()
        equipment.free()
