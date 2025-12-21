class_name GenericToggleButton extends MarginContainer

signal pressed

@export var texture_rect: TextureRect


var button_pressed: bool = false
var is_pressed: bool = false

var disabled: bool = false




func _ready() -> void :
    update_texture()



func _process(_delta: float) -> void :
    is_pressed = false


    if Input.is_action_just_pressed("press") and not disabled:
        if not UI.is_hovered(self):
            return

        button_pressed = not button_pressed
        is_pressed = true
        pressed.emit()


    update_texture()




func update_texture() -> void :
    if button_pressed:
        (texture_rect.material as ShaderMaterial).set_shader_parameter("alpha", 1.0)
        texture_rect.flip_h = true
        return

    (texture_rect.material as ShaderMaterial).set_shader_parameter("alpha", 0.5)
    texture_rect.flip_h = false
