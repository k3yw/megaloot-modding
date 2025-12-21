extends GameLogicScript





func initialize() -> void :
    if not is_instance_valid(character):
        return

    battle_procesor.turn_completed.connect( func(turn_type: BattleTurn.Type):
        if not turn_type == BattleTurn.Type.STANCE:
            return

        if Character.get_item_set_count(character, ItemSets.ANCIENT_SHELL) >= 3:
            battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.EPHEMERAL_SHELL)

        if Character.get_item_set_count(character, ItemSets.ANCIENT_SHELL) >= 5:
            character.battle_profile.remove_matching_status_effects(StatusEffects.EPHEMERAL_ARMOR)
        )
