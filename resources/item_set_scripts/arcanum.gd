extends GameLogicScript





func initialize() -> void :
    if not is_instance_valid(character):
        return

    battle_procesor.turn_completed.connect( func(_turn_type: BattleTurn.Type):
        if Character.get_item_set_count(character, ItemSets.ARCANUM) >= 2:
            character_manager.refill_magic_shield(character)
        )

    character.killed_target.connect( func(target: Character):
        if Character.get_item_set_count(character, ItemSets.ARCANUM) >= 4:
            character_manager.refill_magic_shield(character)
        )
