extends GameLogicScript






func _init(arg_arr: Array = []) -> void :
    super._init(arg_arr)

    character.parried.connect( func(target: Character):
        await battle_procesor.try_to_apply_status_effect(target, character, StatusEffects.STUN)
    )
