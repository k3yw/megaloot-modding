extends GameLogicScript









func initialize() -> void :
    if memory.battle.current_turn == 1:
        await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.INVULNERABILITY)
