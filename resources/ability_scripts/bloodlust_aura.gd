extends AbilityScript








func can_activate() -> bool:
    for turn in character.battle_profile.get_valid_turns():
        if turn.percent_health_recovered >= 25:
            return true

    return false



func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)
    for enemy in memory.battle.get_enemies_in_combat():
        await battle_manager.create_battle_animation_timer(0.25)
        await battle_procesor.try_to_apply_status_effect(enemy, character, StatusEffects.MADNESS)
