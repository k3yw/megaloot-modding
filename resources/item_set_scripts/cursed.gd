extends GameLogicScript









func initialize() -> void :
    if not is_instance_valid(character):
        return

    if memory.battle.current_turn == 1:
        await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.MALICE_SHIELD, 5)
        await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.CURSE)


    character.dealt_damage.connect(_on_dealt_damage)




func _on_dealt_damage(damage_result: DamageResult) -> void :
    if Character.get_item_set_count(character, ItemSets.CURSED) <= 3:
        return

    if not damage_result.damage_type == Stats.MALICE_DAMAGE:
        return

    if damage_result.source == DamageData.Source.CURSED_SET:
        return

    for opponent in memory.get_opponents(character):
        if opponent == DamageResult.get_ref(damage_result.target):
            continue

        var spread_damage: DamageData = DamageData.new(DamageData.Source.CURSED_SET, Stats.MALICE, damage_result.total_damage)
        await battle_procesor.try_to_damage_character(opponent, character, spread_damage)
