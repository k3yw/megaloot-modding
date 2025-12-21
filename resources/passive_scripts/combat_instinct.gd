extends GameLogicScript






func get_damage_multiplier(source: DamageData.Source) -> float:
    if not source == DamageData.Source.PARRY:
        return 1.0

    if Character.get_item_set_count(character, ItemSets.WARRIOR) >= 3:
        return 2.0

    return 1.0
