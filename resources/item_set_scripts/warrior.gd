extends GameLogicScript






func _init(arg_arr: Array = []) -> void :
    super._init(arg_arr)

    if not is_instance_valid(character):
        return

    character.attacked.connect(_on_attacked)
    character.got_attacked.connect(_on_got_attacked)

    if character.get_active_specializations().has(Specializations.QUICKBLADE):
        character.parried.connect( func(_target: Character):
            character.add_stat(character.battle_profile.stats, Stat.new([Stats.TOTAL_ATTACKS, 1]))
            if character == memory.local_player:
                gameplay_state.create_stat_added_popup(BonusStat.new(Stats.TOTAL_ATTACKS, 1, false))
        )



func _on_attacked(_target: Character) -> void :
        await battle_procesor.try_to_apply_status_effect(character, null, StatusEffects.COMBAT_INSIGHT, 1)


func _on_got_attacked(_attacker: Character) -> void :
    if not Character.get_item_set_count(character, ItemSets.WARRIOR) >= 4:
        return
    await battle_procesor.try_to_apply_status_effect(character, null, StatusEffects.COMBAT_INSIGHT, 1)
