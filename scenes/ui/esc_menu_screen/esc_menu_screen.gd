class_name EscMenuScreen extends MarginContainer



@export var resume_button: GenericButton
@export var save_and_exit_button: GenericButton
@export var restart_button: GenericButton
@export var options_button: GenericButton
@export var library_button: GenericButton

@export var library_holder: Control



func _ready() -> void :
    StateManager.state_changed.connect(_on_state_changed)
    hide()



func _on_state_changed() -> void :
    hide()
