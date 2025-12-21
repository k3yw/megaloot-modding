extends GameLogicScript






func initialize() -> void :
    if character.get_turn_size() <= 3:
        await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.CLARITY)
