extends GameLogicScript









func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.stat_changed.connect( func(stat_resource: StatResource, old_amount: float):
        if not stat_resource == Stats.ACTIVE_ARMOR:
            return

        var new_amount: float = character.get_stat_amount(Stats.ACTIVE_ARMOR)[0]
        var armor_changed: float = old_amount - new_amount
        if armor_changed > 0.0:
            character_manager.add_temp_stat(character, BonusStat.new(Stats.MAX_HEALTH, armor_changed))
        )
