extends AbilityScript






func can_activate() -> bool:
    var hits_received: int = 0

    for turn in character.battle_profile.get_valid_turns():
        hits_received += turn.hits_received.size()

    return hits_received >= 3


func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)

    var bonus_armor: BonusStat = BonusStat.new(Stats.ARMOR, character.get_stat_amount(Stats.HEALTH)[0])
    character_manager.add_temp_stat(character, bonus_armor)
    await battle_manager.create_battle_animation_timer(0.25)
