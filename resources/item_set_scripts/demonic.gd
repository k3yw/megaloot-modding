extends GameLogicScript







func initialize() -> void :
    if Character.get_item_set_count(character, ItemSets.DEMONIC) < 3:
        return

    if character.get_turn_size() == 1:
        await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.MULTI_ATTACK_CHARGE)
