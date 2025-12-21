extends GameLogicScript







func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.received_damage.connect( func(damage_result: DamageResult):
        var old_health_percent: float = Math.get_percentage(character.get_max_health(), character.get_health() + damage_result.direct_damage)
        var new_health_percent: float = character.get_health_percent()

        if old_health_percent >= 45 and new_health_percent < 45:
            for opponent in memory.get_opponents(character):
                await battle_procesor.try_to_apply_status_effect(opponent, character, StatusEffects.CONFUSION)
        )
