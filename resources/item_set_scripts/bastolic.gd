extends GameLogicScript





func initialize() -> void :
    if not is_instance_valid(character):
        return

    if Character.get_item_set_count(character, ItemSets.BASTOLIC) > 0:
        character.dealt_damage.connect( func(damage_result: DamageResult):
            if damage_result.source == DamageData.Source.BASTOLIC:
                return
            if damage_result.source == DamageData.Source.ZEPHYRON:
                return
            var damage: float = ceilf(character.get_stat_amount(Stats.HEALTH)[0] * 0.05)
            var rand_enemy: Enemy = memory.battle.get_random_enemy_in_combat()
            var damage_data: DamageData = DamageData.new(DamageData.Source.BASTOLIC, Stats.MAGIC_DAMAGE, damage)
            await battle_procesor.try_to_damage_character(rand_enemy, character, damage_data)
            )

    if Character.get_item_set_count(character, ItemSets.BASTOLIC) >= 2:
        character.received_damage.connect( func(damage_result: DamageResult):
            if not character.get_turn_size() == 1:
                return

            if not damage_result.damage_type == Stats.MAGIC_DAMAGE:
                return

            character_manager.add_temp_stat(character, BonusStat.new(Stats.MAX_HEALTH, damage_result.total_damage))
            )
