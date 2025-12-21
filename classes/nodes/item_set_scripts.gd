class_name GameLogicScript extends GameplayComponent

var battle_procesor: BattleProcesor = null
var character: Character = null



func _init(arg_arr: Array = []) -> void :
    if not arg_arr.size() > 0:
        return
    set_gameplay_state(arg_arr[0])
    battle_procesor = arg_arr[1]
    character = arg_arr[2]


func get_ignored_targets(passive_source: Character) -> Array[Character]:
    var ignored_targets: Array[Character] = []
    return ignored_targets


func get_abilities() -> Array[Ability]:
    return []

func get_damage_multiplier(_source: DamageData.Source) -> float:
    return 1.0


func get_bonus_stats() -> Array[BonusStat]:
    var bonus_stats: Array[BonusStat] = []
    return bonus_stats


func initialize() -> void :
    pass
