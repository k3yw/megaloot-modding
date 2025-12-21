extends GameLogicScript






func get_damage_multiplier(source: DamageData.Source) -> float:
    if not source == DamageData.Source.ATTACK:
        return 1.0

    if character.battle_profile.get_curr_turn().attacks <= 5:
        return 0.01

    return 1.0
