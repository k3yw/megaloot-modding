extends AbilityScript








func can_activate() -> bool:
    for turn in character.battle_profile.get_valid_turns():
        for status_effects in turn.applied_status_effects:
            if status_effects.resource == StatusEffects.FEAR:
                return true

    return false



func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)
    for enemy in memory.battle.get_enemies_in_combat():
        if not enemy.battle_profile.has_active_status_effect_resource(StatusEffects.FEAR):
            continue

        arg_battle_procesor.steal_attack(enemy, character, 75)
        await battle_manager.create_battle_animation_timer(0.25)
