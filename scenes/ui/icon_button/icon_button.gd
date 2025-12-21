class_name IconButton extends MarginContainer

signal pressed

@export var icon_texture_rect: TextureRect


var selected: bool = false
var hovering: bool = false

var target_alpha: float = 0.0
var curr_alpha: float = 0.0

var locked: bool = false



func _process(delta: float) -> void :
    curr_alpha = lerp(curr_alpha, target_alpha, delta * 25.0)
    hovering = UI.is_hovered(self)

    target_alpha = 0.3
    if hovering and not locked:
        target_alpha = 0.5


    if selected:
        target_alpha = 1.0
        if hovering and not locked:
            target_alpha = 0.8


    if not locked and hovering and Input.is_action_just_pressed("press"):
        pressed.emit()

    (icon_texture_rect.material as ShaderMaterial).set_shader_parameter("alpha", curr_alpha)




func set_trial(trial: Trial) -> void :
    icon_texture_rect.texture = trial.icon
