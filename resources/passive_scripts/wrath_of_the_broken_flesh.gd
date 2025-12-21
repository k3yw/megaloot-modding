extends GameLogicScript







func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.received_damage.connect( func(damage_result: DamageResult):
        if damage_result.direct_damage > 0.0:
            await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.FURY)
        )
