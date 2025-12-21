extends AbilityScript








func can_activate() -> bool:
    for turn in character.battle_profile.get_valid_turns():
        if turn.parries > 0:
            return true

    return false


func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)

    await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.MULTI_ATTACK_CHARGE)
    await battle_manager.create_battle_animation_timer(0.25)
    await battle_procesor.try_to_apply_status_effect(character, character, StatusEffects.STUN_ATTACK_CHARGE)
    await battle_manager.create_battle_animation_timer(0.25)
