class_name GenericHSlider extends MarginContainer


@export var grabber_texture_rect: TextureRect
@export var max_value: float = 100.0
@export var value_step: float = 1.0
@export var min_value: float = 0.0

var grabbing: bool = false
var min_pos: float = 0.0
var max_pos: float = 0.0

var grab_delta: float = 0.0

var last_frame_value: float = max_value
var value_changed: bool = false
var value: float = 0







func _process(_delta: float) -> void :
    if not is_visible_in_tree():
        return

    min_pos = global_position.x - (grabber_texture_rect.size.x / 2)
    max_pos = (global_position.x + size.x) - (grabber_texture_rect.size.x / 2)
    (grabber_texture_rect.material as ShaderMaterial).set_shader_parameter("brightness", 0.0)

    if UI.is_hovered(self) or grabbing:
        (grabber_texture_rect.material as ShaderMaterial).set_shader_parameter("brightness", 0.75)

        if Input.is_action_pressed("press"):
            grab()


    if Input.is_action_just_released("press"):
        if grabbing:
            grabbing = false

    if is_grabbing():
        if not Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
            grabber_texture_rect.global_position.x = get_global_mouse_position().x - (grabber_texture_rect.size.x / 2)

        if grab_delta:
            grabber_texture_rect.global_position.x += get_step() * grab_delta

        grabber_texture_rect.global_position.x = clamp(grabber_texture_rect.global_position.x, min_pos, max_pos)
        process_value_change()

    if not grab_delta:
        grabber_texture_rect.global_position.x = get_snapped_position()


    get_step()





func _input(event: InputEvent) -> void :
    if not is_grabbing():
        return

    if event is InputEventJoypadMotion:
        if event.axis == JOY_AXIS_RIGHT_X:
            grab_delta = roundf(event.axis_value * 10) / 10.0





func process_value_change() -> void :
    value_changed = false
    value = get_value()

    if not value == last_frame_value:
        value_changed = true

    last_frame_value = value






func grab() -> void :
    (grabber_texture_rect.material as ShaderMaterial).set_shader_parameter("brightness", -0.25)
    grabbing = true



func is_grabbing() -> bool:
    if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
        if not is_instance_valid(UI.hovered_node):
            return false

        if UI.hovered_node == grabber_texture_rect:
            return true

        return false

    return grabbing






func get_value() -> float:
    var grabber_pos: float = grabber_texture_rect.position.x + (grabber_texture_rect.size.x / 2)
    var new_max_pos = max_pos - min_pos
    var new_value: float = (1 / new_max_pos) * grabber_pos

    return snapped((new_value * (max_value - min_value)) + min_value, value_step)



func get_snapped_position() -> float:
    var grabber_pos: float = global_position.x - (grabber_texture_rect.size.x / 2)
    var inv_value: float = (snapped(value, value_step) - min_value) / (max_value - min_value)
    var new_max_pos = max_pos - min_pos

    return (inv_value * new_max_pos) + grabber_pos


func get_step() -> float:
    return float(max_pos - min_pos) * 0.01
