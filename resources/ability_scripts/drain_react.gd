extends AbilityScript








func can_activate() -> bool:
    for turn in character.battle_profile.get_valid_turns():
        for hit_data in turn.hits_received:
            for status_effect in hit_data.attackers_active_status_effects:
                if status_effect.resource == StatusEffects.POISON:
                    return true
    return false



func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)

    for enemy in memory.battle.get_enemies_in_combat():
        await battle_manager.create_battle_animation_timer(0.25)
        await arg_battle_procesor.try_to_apply_status_effect(enemy, character, StatusEffects.ENERVATION, 5)

    await battle_manager.create_battle_animation_timer(0.25)
