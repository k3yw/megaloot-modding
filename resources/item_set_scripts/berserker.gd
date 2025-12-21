extends GameLogicScript








func get_bonus_stats() -> Array[BonusStat]:
    var bonus_stats: Array[BonusStat] = []

    if not is_instance_valid(character):
        return []

    var health_percent: float = character.get_health_percent()
    if Character.get_item_set_count(character, ItemSets.BERSERKER) > 0:
        var total_attacks: float = 0

        if health_percent < 75:
            total_attacks = 1

        if health_percent < 50:
            total_attacks = 3

        if health_percent < 25:
            total_attacks = 6

        if total_attacks > 0:
            bonus_stats.push_back(BonusStat.new(Stats.TOTAL_ATTACKS, total_attacks))


    if Character.get_item_set_count(character, ItemSets.BERSERKER) > 1:
        if health_percent < 25:
            bonus_stats.push_back(BonusStat.new(Stats.TENACITY, 100.0))


    return bonus_stats
