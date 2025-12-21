class_name Options extends RefCounted

enum BattleSpeed{X1, X2, X4, X8}

const BINDINGS: Array[String] = [
    "quick_buy_item_1", 
    "quick_buy_item_2", 
    "quick_buy_item_3", 
    "quick_buy_item_4", 

    "sort_inventory", 
    "refresh_market", 
    "sell_item", 

    "primary_action", 
    "base_ability", 
    "learned_ability_1", 
    "learned_ability_2", 
    "stance", 

    "select_left_enemy", 
    "select_right_enemy", 
]


const BASE_RESOLUTION: Vector2i = Vector2i(640, 360)
const FILE_NAME: String = "options.txt"


var speedrun_api_key: String = ""


var window_mode: WindowMode.Type = WindowMode.Type.WINDOWED
var generate_translation_csv: bool = false
var resolution: Array = [0, 0]
var brightness: float = 1.0
var contrast: float = 1.0
var music_volume_db: float = -2.5
var sfx_volume_db: float = -2.5
var tooltip_lock_time: float = 0.75
var v_sync: bool = true

var chromatic_aberration: bool = true
var display_run_time: bool = false
var screen_shake: bool = true
var scan_lines: bool = true


var keyboard_input_map: Dictionary = {}
var joypoad_input_map: Dictionary = {}

var current_language: int = 0
var current_screen: int = 0

var battle_speed: BattleSpeed = BattleSpeed.X2
var selected_speedrun_category: String = ""






func _init() -> void :
    resolution = [1280, 720]




func update_input_map() -> void :
    for action_name in BINDINGS:
        var action_events: Array[InputEvent] = InputMap.action_get_events(action_name)

        for action_event in action_events:

            match InputMode.get_active_type():
                InputMode.Type.KEYBOARD:
                    if keyboard_input_map.has(action_name):
                        continue
                    keyboard_input_map[action_name] = action_event
                    break

                InputMode.Type.JOYPAD:
                    if joypoad_input_map.has(action_name):
                        continue
                    joypoad_input_map[action_name] = action_event
                    break




func save() -> void :
    SaveSystem.save_json(self, Options.get_save_path())





static func get_supported_resolutions() -> Array[Vector2i]:
    var screen_size: Vector2i = DisplayServer.screen_get_size()
    var supported_resolutions: Array[Vector2i] = []
    var curr_idx: int = 0


    while true:
        curr_idx += 1
        var curr_resolution: Vector2i = Vector2i(640, 360) * curr_idx

        if screen_size.x < curr_resolution.x or screen_size.y < curr_resolution.y:
            break

        supported_resolutions.push_back(curr_resolution)


    return supported_resolutions







static func get_save_path() -> String:
    return File.get_user_file_dir() + "/" + FILE_NAME
