extends GameLogicScript









func initialize() -> void :
    if not is_instance_valid(character):
        return
    battle_procesor.turn_completed.connect(_on_turn_completed)




func _on_turn_completed(_turn_type: BattleTurn.Type) -> void :
    for opponent in memory.get_opponents(character):
        var weakness_amount: float = opponent.battle_profile.get_status_effect_amount(StatusEffects.WEAKNESS)
        var curse_amount: float = opponent.battle_profile.get_status_effect_amount(StatusEffects.CURSE)

        if curse_amount > 0.0:
            opponent.battle_profile.remove_matching_status_effects(StatusEffects.CURSE)
            opponent.try_to_add_status_effect(null, StatusEffects.BLACK_CURSE, curse_amount)

        if weakness_amount > 0.0:
            opponent.battle_profile.remove_matching_status_effects(StatusEffects.WEAKNESS)
            opponent.try_to_add_status_effect(null, StatusEffects.ENERVATION, weakness_amount)
