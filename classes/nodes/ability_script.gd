class_name AbilityScript extends GameplayComponent



var battle_procesor: BattleProcesor = null
var character: Character = null


func _init(arg_gameplay_state: GameplayState, arg_character: Character) -> void :
    set_gameplay_state(arg_gameplay_state)
    character = arg_character


func can_activate() -> bool:
    return true


func get_status_effects_on_hit(_arg_character: Character) -> Array[StatusEffect]:
    var status_effects_on_hit: Array[StatusEffect] = []
    return status_effects_on_hit


func activate(arg_battle_procesor: BattleProcesor) -> void :
    battle_procesor = arg_battle_procesor

    await battle_manager.create_battle_animation_timer(0.25)
    gameplay_state.play_ability_sound(gameplay_state.get_viewport().get_visible_rect().get_center())
