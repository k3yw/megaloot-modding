class_name State




enum Type{BOARD, BATTLE, CHEST}



const SCENE_PATHS: Array[String] = [
    "res://scenes/states/board_state/board_state.tscn", 
    "res://scenes/states/battle_state/battle_state.tscn", 
    "res://scenes/states/chest_state/chest_state.tscn", 
]




static func get_type(scene_path: String) -> int:
    return SCENE_PATHS.find(scene_path)
