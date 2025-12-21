extends GameLogicScript





func initialize() -> void :
    if Character.get_item_set_count(character, ItemSets.CHROMALURE) >= 3:
        await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.TOXIC_TRANSMUTE)
