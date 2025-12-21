extends AbilityScript






func can_activate() -> bool:
    var targets: Array[Character] = memory.get_opponents(character)

    for idx in range(targets.size() - 1, -1, -1):
        var target: Character = targets[idx]
        if target.battle_profile.has_active_status_effect_resource(StatusEffects.DEBUFF_IMMUNITY):
            targets.remove_at(idx)

    if not targets.size():
        return false

    return true



func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)

    for opponent in memory.get_opponents(character):
        if await battle_procesor.try_to_apply_status_effect(opponent, character, StatusEffects.CONFUSION, 2):
            await battle_manager.create_battle_animation_timer(0.45)
