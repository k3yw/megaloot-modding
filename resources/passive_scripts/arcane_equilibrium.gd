extends GameLogicScript









func initialize() -> void :
    if not is_instance_valid(character):
        return
    battle_procesor.turn_completed.connect(_on_turn_completed)




func _on_turn_completed(_turn_type: BattleTurn.Type) -> void :
    var characters_in_combat: Array[Character] = memory.battle.get_enemy_characters_in_combat()
    characters_in_combat.push_back(memory.battle.battling_player)

    for character in characters_in_combat:
        if not character.battle_profile.has_active_status_effect_resource(StatusEffects.INVULNERABILITY):
            continue
        character.battle_profile.remove_matching_status_effects(StatusEffects.INVULNERABILITY)
        character.refill_magic_shield()
