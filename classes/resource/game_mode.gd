class_name GameMode extends Resource


@export var name: StringName

@export var has_achievements: bool = false
@export var team_based: bool = false
@export var base_room_count: int = 4
@export var last_floor: int = -1

@export var game_mode_script: GDScript


func get_script_instance() -> GameModeScript:
    return game_mode_script.new()

func get_translated_name() -> String:
    return T.get_translated_string(name.to_lower(), "Game Mode Name")

func get_id() -> String:
    return name.to_lower()
