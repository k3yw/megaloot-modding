extends AbilityScript






func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)
    character_manager.add_temp_stat(character, BonusStat.new(Stats.TOTAL_ATTACKS), true)
