extends GameLogicScript





func initialize() -> void :
    var opponents: Array[Character] = memory.get_opponents(character)

    for opponent in opponents:
        var character_attack_damage_data: DamageData = character.get_attack_damage_data(DamageData.Source.ATTACK)
        var opponent_attack_damage_data: DamageData = opponent.get_attack_damage_data(DamageData.Source.ATTACK)
        character.apply_damage_output_boosters(character_attack_damage_data)
        opponent.apply_damage_output_boosters(character_attack_damage_data)

        var character_attack_damage: float = character_attack_damage_data.damage
        var opponent_attack_damage: float = opponent_attack_damage_data.damage

        character_attack_damage_data.free()
        opponent_attack_damage_data.free()

        if character_attack_damage > opponent_attack_damage:
            await battle_procesor.try_to_apply_status_effect(opponent, character, StatusEffects.FEAR)


    if Character.get_item_set_count(character, ItemSets.DARKNESS) >= 4 and character.get_turn_size() == 1:
        await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.MADNESS)
