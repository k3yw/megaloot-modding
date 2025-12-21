extends GameLogicScript






func _init(arg_arr: Array = []) -> void :
    super._init(arg_arr)

    for opponent in memory.get_opponents(character):
        opponent.missed.connect( func():
            opponent.add_stat(opponent.battle_profile.stats, Stat.new([Stats.ACCURACY, 25]))
            )
