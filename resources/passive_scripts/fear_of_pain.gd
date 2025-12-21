extends GameLogicScript







func get_ignored_targets(passive_source: Character) -> Array[Character]:
    if not is_instance_valid(passive_source):
        return []

    if not passive_source == character:
        return []

    var ignored_targets: Array[Character] = []

    for opponent in memory.get_opponents(passive_source):
        var turn: BattleTurn = opponent.battle_profile.get_curr_turn()
        if turn.health_damage_taken > 0.0\
or turn.health_damage_taken > 0.0:
            ignored_targets.push_back(opponent)


    return ignored_targets
