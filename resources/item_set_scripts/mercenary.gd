extends GameLogicScript





func initialize() -> void :
    if not is_instance_valid(character):
        return

    if Character.get_item_set_count(character, ItemSets.MERCENARY) > 0:
        character.about_to_attack.connect( func(target: Character, damage_data: DamageData):
            if target.get_health_percent() > 90:
                damage_data.apply_multiplier(1.25 + (character.get_stat_amount(Stats.LUCK)[0] * 0.01))
            )

    if Character.get_item_set_count(character, ItemSets.MERCENARY) >= 3:
        character.about_to_start_attacking.connect( func(targets: Array[Character]):
            for target in targets:
                if target.get_health_percent() > 90:
                    character.add_stat(character.battle_profile.get_curr_turn().stats, Stat.new([Stats.TOTAL_ATTACKS, 1]))
            )
