class_name MainMenuState extends Node

@onready var main_canvas_layer = $CanvasLayer

@export var hide_on_tab: Array[Control] = []

@export var title_label: Label
@export var menu_item_emitter: MenuItemEmitter
@export var enter_the_tower_button: GenericButton
@export var profile_button: GenericButton
@export var options_button: GenericButton
@export var library_button: GenericButton
@export var workshop_button: GenericButton
@export var credits_button: GenericButton
@export var quit_button: GenericButton
@export var phase_label: GenericLabel



var hide_main_canvas_layer: bool




func _ready() -> void :
    quit_button.visible = not OS.has_feature("web")
    if System.is_demo():
        phase_label.text = "DEMO"
        return

    phase_label.text = System.get_version()


func _input(_event: InputEvent) -> void :
    if Input.is_action_just_pressed("toggle_ui"):
        for node in hide_on_tab:
            node.visible = not node.visible





func _process(_delta: float) -> void :
    enter_the_tower_button.disabled = buttons_disabled()
    workshop_button.disabled = buttons_disabled()
    profile_button.disabled = buttons_disabled()
    library_button.disabled = buttons_disabled()
    quit_button.disabled = buttons_disabled()

    main_canvas_layer.visible = not hide_main_canvas_layer







func buttons_disabled() -> bool:
    return StateManager.is_changing_state
