extends GameLogicScript





func initialize() -> void :
    if not is_instance_valid(character):
        return


    character.attack_hit.connect( func(target: Character, damage_data: DamageData):
        if target.battle_profile.get_curr_turn().hits_received.size() == 1:
            await battle_procesor.try_to_apply_status_effect(target, character, StatusEffects.BLEED, 8)
        )

    for opponent in memory.get_opponents(character):
        opponent.received_damage.connect( func(damage_result: DamageResult):

            if Character.get_item_set_count(character, ItemSets.VAMPIRIC) >= 3:
                if damage_result.damage_type == Stats.BLEED_DAMAGE:
                    battle_procesor.heal(character, damage_result.direct_damage)

            if Character.get_item_set_count(character, ItemSets.VAMPIRIC) >= 5:
                if damage_result.damage_type == Stats.BLEED_DAMAGE:
                    character_manager.add_temp_stat(character, BonusStat.new(Stats.POWER, damage_result.direct_damage))
            )
