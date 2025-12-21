extends GameLogicScript






func _init(arg_arr: Array = []) -> void :
    super._init(arg_arr)




func get_abilities() -> Array[Ability]:
    var abilities: Array[Ability] = []

    if not memory.get_all_players().has(character):
        return []

    var selected_enemy: Enemy = memory.battle.get_selected_enemy()
    if is_instance_valid(selected_enemy) and is_instance_valid(selected_enemy.get_ability()):
        abilities.push_back(Ability.new(selected_enemy.get_ability(), true))

    return abilities
