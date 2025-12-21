extends GameLogicScript





func initialize() -> void :
    if not is_instance_valid(character):
        return
    character.attacked.connect(_on_attacked)


func _on_attacked(_target: Character) -> void :
    character.change_stat_amount(character.battle_profile.get_curr_turn().stats, Stat.new([Stats.ACCURACY, -10]))
