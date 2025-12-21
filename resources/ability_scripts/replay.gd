extends AbilityScript








func can_activate() -> bool:
    for turn in character.battle_profile.get_valid_turns():
        for ability in turn.abilities:
            if ability.mimicked:
                return true

    return false



func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)

    var turns: Array[BattleTurn] = character.battle_profile.get_valid_turns()
    var mimicked_ability: Ability = null

    turns.pop_back()

    for turn in turns:
        if is_instance_valid(mimicked_ability):
            break
        for ability in turn.abilities:
            if ability.mimicked:
                mimicked_ability = ability
                break

    await battle_procesor.activate_ability(memory.battle, character, mimicked_ability, false)
    await battle_manager.create_battle_animation_timer(0.25)
