extends GameLogicScript






func _init(arg_arr: Array = []) -> void :
    super._init(arg_arr)

    character.counter_attacked.connect( func(target: Character):
        await battle_procesor.try_to_counter_attack(memory.battle, character, target, DamageData.Source.VENGEFUL_EDGE)
    )
