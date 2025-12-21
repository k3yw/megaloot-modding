extends AbilityScript





func get_ability_target(battle: Battle, character: Character) -> Character:
    var selected_enemy: Enemy = battle.get_selected_enemy()

    if character is Player:
        return selected_enemy

    return battle.battling_player

    return null



func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)

    var character_to_target: Character = get_ability_target(memory.battle, character)

    if await battle_procesor.try_to_apply_status_effect(character_to_target, character, StatusEffects.SILENCE):
        await battle_manager.create_battle_animation_timer(0.45)



func can_activate() -> bool:
    var target: Character = get_ability_target(memory.battle, character)

    if not is_instance_valid(target):
        return false

    if target.battle_profile.has_active_status_effect_resource(StatusEffects.SILENCE):
        return false

    return true
