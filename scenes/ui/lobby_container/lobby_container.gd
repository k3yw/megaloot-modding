class_name LobbyContainer extends MarginContainer

signal selected


@export var selection_panel: NinePatchRect
@export var lock_texture_rect: TextureRect
@export var game_mode_label: GenericLabel
@export var players_label: GenericLabel
@export var locked_label: GenericLabel
@export var name_label: GenericLabel



var is_selected: bool = false
var hovering: bool = false

var lobby_name: String = ""




func _process(_delta: float) -> void :
    hovering = UI.is_hovered(self)
    is_selected = false


    if hovering and Input.is_action_just_pressed("press"):
        is_selected = true
        selected.emit()


func set_lobby_name(arg_lobby_name: String, custom_name: String) -> void :
    name_label.text = arg_lobby_name
    lobby_name = arg_lobby_name

    if not custom_name.is_empty():
        name_label.text = custom_name
