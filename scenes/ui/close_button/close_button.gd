class_name CloseButton extends TextureRect



var target_brightness: float = 0.0
var curr_brightness: float = 0.0

var is_pressed: bool = false
var hovering: bool = false



func _process(delta: float) -> void :
    curr_brightness = lerp(curr_brightness, target_brightness, delta * 10.0)
    hovering = UI.is_hovered(self)
    target_brightness = 0.0

    (material as ShaderMaterial).set_shader_parameter("brightness", curr_brightness)

    is_pressed = false

    if hovering:
        target_brightness = 0.75

        if Input.is_action_just_pressed("press"):
            curr_brightness = -0.75
            is_pressed = true
