extends GameLogicScript






func _init(arg_arr: Array = []) -> void :
    super._init(arg_arr)

    character.attack_hit.connect( func(_target: Character, _damage_data: DamageData):
        character.add_stat(character.battle_profile.stats, Stat.new([Stats.CRIT_CHANCE, 5]))
    )
