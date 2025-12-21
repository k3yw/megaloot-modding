extends GameLogicScript









func initialize() -> void :
    if not is_instance_valid(character):
        return

    var rand_ally: Character = memory.pick_random_ally(character)
    if not is_instance_valid(rand_ally):
        return

    var rand_status_effect: StatusEffectResource = StatusEffects.get_random_status_effect(RNGManager.gameplay_rand, [StatusEffectTypes.BLESSING, StatusEffectTypes.BUFF])
    await battle_procesor.try_to_apply_status_effect(rand_ally, character, rand_status_effect)
