class_name GameplayComponent extends Node

var options: Options = OptionsManager.options

var character_manager: CharacterManager = null
var canvas_layer: GameplayCanvasLayer = null
var gameplay_state: GameplayState = null
var battle_manager: BattleManager = null
var enemy_manager: EnemyManager = null
var room_screen: RoomScreen = null
var memory: Memory = null



func set_gameplay_state(arg_gameplay_state: GameplayState) -> void :
    room_screen = arg_gameplay_state.canvas_layer.room_screen
    character_manager = arg_gameplay_state.character_manager
    battle_manager = arg_gameplay_state.battle_manager
    enemy_manager = arg_gameplay_state.enemy_manager
    canvas_layer = arg_gameplay_state.canvas_layer
    gameplay_state = arg_gameplay_state
    memory = arg_gameplay_state.memory
