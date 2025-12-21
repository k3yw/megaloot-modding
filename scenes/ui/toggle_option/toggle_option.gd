class_name ToggleOption extends HBoxContainer




@export var toggle_button: GenericToggleButton
@export var name_label: GenericLabel

@export var flip_h: bool = false: set = set_flip_h




func _process(_delta: float) -> void :
    var target_alpha: float = 1.0

    if is_instance_valid(toggle_button):
        if toggle_button.disabled:
            target_alpha = 0.5

    (name_label.material as ShaderMaterial).set_shader_parameter("alpha", target_alpha)




func set_flip_h(value: bool) -> void :
    flip_h = value
    do_flip_h()



func _ready() -> void :
    if flip_h:
        do_flip_h()



func do_flip_h() -> void :
    move_child(toggle_button, 0)
