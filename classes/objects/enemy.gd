class_name Enemy extends Character

var resource: EnemyResource = EnemyResource.new()
var encounter_probability: float = 1

var player_trials: Array[Trial] = []
var upgrade_stats: Array[Stat] = []

var player_count: int
var battle_count: int
var spawn_floor: int

var out_of_combat: bool
var level: int

var immune_to: String = ""




func _init(arg_enemy: Enemy = null) -> void :
    if not is_instance_valid(arg_enemy):
        return

    battle_profile.active_status_effects = arg_enemy.battle_profile.active_status_effects.duplicate()
    battle_count = arg_enemy.battle_count
    spawn_floor = arg_enemy.spawn_floor
    level = arg_enemy.level

    resource = arg_enemy.resource

    update_all()





func transform_to_elite(arg_level: int = 1):
    level = arg_level
    update_all()



func set_spawn_floor(amount: int) -> void :
    spawn_floor = amount
    update_all()






func update_all():
    ObjUtils.cleanup_arr(stats)

    battle_log_name = [resource.name, "Enemy Name"] as Array[String]

    var total_attacks: float = 1.0
    var armor: float = 0.0

    StatUtils.set_stat_amount(stats, Stat.new([Stats.ACCURACY, 100]))
    if player_trials.has(Trials.CONFRONTATION):
        total_attacks += 1

    for stat in resource.base_stats:
        var new_amount: float = stat.amount

        if new_amount == -1:
            continue

        match stat.resource:
            Stats.MAX_HEALTH:
                new_amount = get_new_max_health(stat.amount)
                if player_trials.has(Trials.RESILIENCE):
                    armor += maxf(1.0, new_amount)

            Stats.ARMOR:
                armor += get_new_armor(stat.amount)
                continue

            Stats.TOTAL_ATTACKS:
                total_attacks += stat.amount
                continue

            Stats.PHYSICAL_ATTACK: new_amount = get_new_physical_attack(stat.amount)
            Stats.MAGIC_ATTACK: new_amount = get_new_magical_attack(stat.amount)
            Stats.FREEZE_ATTACK: new_amount = get_new_freeze_attack(stat.amount)
            Stats.CINDER_DAMAGE: new_amount = get_new_cinder_damage(stat.amount)
            Stats.ELECTRICITY: new_amount = get_new_electricity(stat.amount)
            Stats.LIFE_STEAL: new_amount = get_new_life_steal(stat.amount)
            Stats.RECOVERY: new_amount = get_new_recovery(stat.amount)
            Stats.TOXICITY: new_amount = get_new_toxicity(stat.amount)
            Stats.AGILITY: new_amount = get_new_agility(stat.amount)
            Stats.MALICE: new_amount = get_new_malice(stat.amount)
            Stats.DAZZLE: new_amount = get_new_dazzle(stat.amount)
            Stats.FAITH: new_amount = get_new_faith(stat.amount)

        StatUtils.set_stat_amount(stats, Stat.new([stat.resource, new_amount]))


    StatUtils.set_stat_amount(stats, Stat.new([Stats.TOTAL_ATTACKS, total_attacks]))
    StatUtils.set_stat_amount(stats, Stat.new([Stats.ARMOR, armor]))

    for stat in upgrade_stats:
        var new_stat: Stat = Stat.new()
        new_stat.set_stat(stat)
        StatUtils.change_stat_amount(stats, new_stat)

    cache_stats()


    StatUtils.set_stat_amount(stats, Stat.new([Stats.MANA, get_stat_amount(Stats.MAX_MANA)[0]]))


    set_active_armor(get_stat_amount(Stats.ARMOR)[0])
    set_health(get_max_health())


    battle_profile.active_item_sets = resource.active_item_sets.duplicate()


    for idx in level:
        if resource.stats_per_level.size() < idx + 1:
            break

        for bonus_stat in resource.stats_per_level[idx].bonus_stats:
            if not is_instance_valid(bonus_stat):
                continue
            StatUtils.change_stat_amount(stats, Stat.new([bonus_stat]))


    cache_stats()





func get_passives() -> Array[Passive]:
    var passives: Array[Passive] = super.get_passives()

    for idx in level + 1:
        if resource.passives.size() < idx + 1:
            break

        var passive: Passive = resource.passives[idx]
        if not is_instance_valid(passive):
            continue

        passives.push_back(passive)

    return passives




func get_new_stat_amount(base_stat: float, floor_scaling: float = 0.175) -> float:
    var stat: float = base_stat * (1.0 + (float((spawn_floor + level) - 1) * floor_scaling))
    var growth: float = 1.0 + (float(spawn_floor - resource.floor_number) * 0.01)

    stat *= pow(1.0 + (float(spawn_floor) * 0.00021), spawn_floor)
    stat *= (1 + (float(battle_count) * 0.045))
    stat = pow(stat, growth)

    return roundf(stat)







func get_new_max_health(base_max_health: float) -> float:
    var max_health: float = get_new_stat_amount(base_max_health)
    max_health = max_health * (1.0 + (float(player_count) * 0.75))

    return roundf(max_health)


func get_new_armor(base_armor: float) -> float:
    var armor: float = get_new_stat_amount(base_armor)
    armor = armor * (1.0 + (float(player_count) * 0.5))

    return roundf(armor)


func get_new_toughness(base_toughness: float) -> float:
    var toughness: float = base_toughness + (level * 5)
    return ceilf(toughness)


func get_new_recovery(base_recovery: float) -> float:
    var recovery: float = base_recovery + (level * 5)
    return ceilf(recovery)





func get_new_physical_attack(base_physical_attack: float) -> float:
    var physical_attack: float = get_new_stat_amount(base_physical_attack, 0.145)
    return roundf(physical_attack)


func get_new_magical_attack(base_magical_attack: float) -> float:
    var magical_attack: float = get_new_stat_amount(base_magical_attack, 0.145)
    return roundf(magical_attack)


func get_new_freeze_attack(base_freeze_attack: float) -> float:
    var freeze_attack: float = get_new_stat_amount(base_freeze_attack, 0.145)
    return roundf(freeze_attack)


func get_new_toxicity(base_toxicity: float) -> float:
    var toxicity: float = get_new_stat_amount(base_toxicity)
    return roundf(toxicity)

func get_new_electricity(base_electricity: float) -> float:
    var electricity: float = get_new_stat_amount(base_electricity)
    return roundf(electricity)

func get_new_malice(base_malice: float) -> float:
    var malice: float = get_new_stat_amount(base_malice)
    return roundf(malice)


func get_new_agility(base_agility: float) -> float:
    var agility: float = base_agility + (level * 25)
    return ceilf(agility)


func get_new_life_steal(base_life_steal: float) -> float:
    var life_steal: float = base_life_steal + (level * 5)
    return ceilf(life_steal)





func get_new_cinder_damage(base_cinder_damage: float) -> float:
    var cinder_damage: float = pow(float(base_cinder_damage), Balance.ENEMY_SCALE_RATE)
    cinder_damage += 1.0 + (battle_count * 0.045)

    if level:
        cinder_damage *= 2 * level

    return ceilf(cinder_damage)




func get_new_dazzle(base_dazzle: float) -> float:
    var dazzle: float = pow(float(base_dazzle), Balance.ENEMY_SCALE_RATE)
    dazzle *= 1.0 + (battle_count * 0.085)

    if level:
        dazzle *= 2 * level

    return ceilf(dazzle)





func get_new_faith(base_faith: float) -> float:
    var faith: float = pow(
        float(base_faith * battle_count) * 0.2, 
        Balance.SCALE_RATE
        )

    if level:
        faith *= 1.45 * level

    return maxf(ceilf(faith), base_faith)

















func get_ability() -> AbilityResource:
    for idx in mini(resource.abilities.size(), level + 1):
        var ability: AbilityResource = resource.abilities[idx]
        if not is_instance_valid(ability):
            continue
        return ability

    return null


func can_battle() -> bool:
    if get_stat_amount(Stats.TOTAL_ATTACKS)[0] > 0:
        return true

    if is_instance_valid(get_ability()):
        return true

    return false


func cleanup() -> void :
    ObjUtils.cleanup_arr(upgrade_stats)
    super.cleanup()
