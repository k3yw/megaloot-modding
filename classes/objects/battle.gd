class_name Battle extends Object

enum TurnType{ATTACKING, DEFENDING}

var curr_turn_type: TurnType = TurnType.ATTACKING
var next_enemies: Array[Enemy] = [null, null, null]
var enemies_to_battle: Array[Enemy] = []

var turn_in_progress: bool = false
var setup_in_progress: bool = true

var force_complete: bool = false
var completed: bool = false

var initial_selected_enemy_idx: int = 1
var selected_enemy_idx: int = 1

var battling_player: Player = null

var turn_time: float = 30.0
var turn_time_left: float = turn_time

var current_turn: int = 0





func remove_enemy(idx: int) -> void :
    next_enemies[idx] = null
    enemies_to_battle.remove_at(idx)


func has_enemy_in_combat() -> bool:
    for enemy_to_battle in enemies_to_battle:
        if not EnemyUtils.is_valid(enemy_to_battle):
            continue

        if not enemy_to_battle.out_of_combat:
            return true

    return false


func clear_invalid_enemies() -> void :
    for idx in range(enemies_to_battle.size() - 1, -1, -1):
        var enemy: Enemy = enemies_to_battle[idx]
        if EnemyUtils.is_valid(enemy):
            continue

        next_enemies[idx] = null
        enemies_to_battle.remove_at(idx)




func get_next_turn_type() -> Battle.TurnType:
    match curr_turn_type:
        Battle.TurnType.ATTACKING:
            return Battle.TurnType.DEFENDING

        Battle.TurnType.DEFENDING:
            return Battle.TurnType.ATTACKING

    return Battle.TurnType.ATTACKING








func get_enemy_from_character(character: Character) -> Enemy:
    for enemy in enemies_to_battle:
        if not EnemyUtils.is_valid(enemy):
            continue

        if enemy == character:
            return enemy

    return null




func get_enemy_characters_in_combat() -> Array[Character]:
    var enemy_characters_in_combat: Array[Character] = []

    for enemy in get_enemies_in_combat():
        enemy_characters_in_combat.push_back(enemy)

    return enemy_characters_in_combat




func get_enemies_in_combat() -> Array[Enemy]:
    var enemies_in_combat: Array[Enemy] = []

    for enemy in enemies_to_battle:
        if not EnemyUtils.is_valid(enemy):
            continue

        if enemy.out_of_combat:
            continue

        enemies_in_combat.push_back(enemy)

    return enemies_in_combat



func has_enemies_to_battle() -> bool:
    var has: bool = get_enemies_in_combat().size()

    if not next_enemies == [null, null, null]:
        has = true

    return has




func get_random_enemy_in_combat() -> Enemy:
    var enemies_in_combat: Array[Enemy] = get_enemies_in_combat()

    if enemies_in_combat.size():
        return enemies_in_combat[RNGManager.pick_random(RNGManager.gameplay_rand, enemies_in_combat.size())]

    return null




func get_adjacent_enemy_characters_in_combat(enemy_character: Character) -> Array[Character]:
    var adjacent_enemy_characters_in_combat: Array[Character] = []
    var starting_idx: int = get_enemy_idx_from_character(enemy_character)


    for idx in range(starting_idx, -1, -1):
        if idx == starting_idx:
            continue
        var enemy: Enemy = enemies_to_battle[idx]
        if not EnemyUtils.is_valid(enemy):
            continue

        if enemy.out_of_combat:
            continue

        adjacent_enemy_characters_in_combat.push_back(enemy)
        break


    for idx in range(starting_idx, enemies_to_battle.size(), 1):
        if idx == starting_idx:
            continue
        var enemy: Enemy = enemies_to_battle[idx]
        if not EnemyUtils.is_valid(enemy):
            continue

        if enemy.out_of_combat:
            continue

        adjacent_enemy_characters_in_combat.push_back(enemy)
        break


    return adjacent_enemy_characters_in_combat







func get_enemies_in_combat_idx() -> PackedInt64Array:
    var enemies_in_combat_idx: PackedInt64Array = []

    for enemy_idx in enemies_to_battle.size():
        var enemy: Enemy = enemies_to_battle[enemy_idx]
        if not EnemyUtils.is_valid(enemy):
            continue

        if enemy.out_of_combat:
            continue

        enemies_in_combat_idx.push_back(enemy_idx)

    return enemies_in_combat_idx



func get_aggresive_enemies_idx() -> PackedInt64Array:
    var attacking_enemies_idx: PackedInt64Array = []

    for enemy_idx in get_enemies_in_combat_idx():
        var enemy: Enemy = enemies_to_battle[enemy_idx]
        if not enemy.can_battle():
            continue

        attacking_enemies_idx.push_back(enemy_idx)

    return attacking_enemies_idx



func get_partner_damage_reduction() -> float:
    var reduction: float = 1.0 - ((current_turn - 1) * 0.01)

    if current_turn <= 1:
        reduction = 1.0

    if current_turn == 2:
        reduction = 1.0 - 0.0001

    return 1.0 - maxf(0.45, reduction)




func update_enemy_selection() -> void :
    if not enemies_to_battle.size():
        return


    if not initial_selected_enemy_idx == -1:
        initial_selected_enemy_idx = wrapi(initial_selected_enemy_idx, 0, enemies_to_battle.size())

    if not selected_enemy_idx == -1:
        selected_enemy_idx = wrapi(selected_enemy_idx, 0, enemies_to_battle.size())


    var selected_enemy: Enemy = enemies_to_battle[selected_enemy_idx]
    if not get_enemy_characters_in_combat().size():
        return

    if not is_instance_valid(next_enemies[selected_enemy_idx]) and not selected_enemy_idx == -1:
        if is_instance_valid(selected_enemy) and selected_enemy.out_of_combat:
            selected_enemy_idx = wrapi(selected_enemy_idx + 1, 0, enemies_to_battle.size())




func get_selected_enemy() -> Enemy:
    update_enemy_selection()

    if enemies_to_battle.size():
        return enemies_to_battle[initial_selected_enemy_idx]

    return null



func get_enemy_idx_from_character(enemy_character: Character) -> int:
    for enemy_idx in enemies_to_battle.size():
        var enemy: Enemy = enemies_to_battle[enemy_idx]
        if enemy == enemy_character:
            return enemy_idx

    return -1



func arthurs_mark_present() -> bool:
    for enemy in get_enemies_in_combat():
        if enemy.battle_profile.has_active_status_effect_resource(StatusEffects.ARTHURS_MARK):
            return true

    return false


func cleanup_enemies() -> void :
    for enemy in enemies_to_battle:
        if not EnemyUtils.is_valid(enemy):
            continue
        enemy.cleanup()
        enemy.free()

    for enemy in next_enemies:
        if not EnemyUtils.is_valid(enemy):
            continue

        enemy.cleanup()
        enemy.free()


func cleanup() -> void :
    cleanup_enemies()
