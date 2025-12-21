extends AbilityScript






func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)
    character_manager.refill_magic_shield(character)
