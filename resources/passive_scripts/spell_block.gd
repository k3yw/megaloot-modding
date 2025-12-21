extends GameLogicScript








func initialize() -> void :
    var target: Enemy = null

    for enemy in gameplay_state.memory.battle.enemies_to_battle:
        if not is_instance_valid(enemy.get_ability()):
            continue

        if enemy.battle_profile.is_silenced():
            continue

        target = enemy
        break

    if not is_instance_valid(target):
        return

    if await battle_procesor.try_to_apply_status_effect(target, character, StatusEffects.SILENCE):
        await battle_manager.create_battle_animation_timer(0.45)
