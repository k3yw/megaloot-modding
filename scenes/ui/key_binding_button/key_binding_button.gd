@tool
class_name KeyBindingButton extends GenericButton



@export var listening_for_input_label: GenericLabel
@export var key_info_container: HBoxContainer
@export var key_label: GenericLabel

@export var action_name: String: set = set_action_name



func set_action_name(value: String) -> void :
    action_name = value
    set_text(action_name.replace("_", " "))
    update_name_label()



func _process(delta: float) -> void :
    super._process(delta)

    if Engine.is_editor_hint():
        return

    if not is_instance_valid(name_label):
        return

    (listening_for_input_label.material as ShaderMaterial).set_shader_parameter("type", 4)
    (name_label.material as ShaderMaterial).set_shader_parameter("type", 4)
    (key_label.material as ShaderMaterial).set_shader_parameter("type", 4)

    if not UI.is_hovered(self) or Input.is_action_pressed("press"):
        (listening_for_input_label.material as ShaderMaterial).set_shader_parameter("type", 1)
        (name_label.material as ShaderMaterial).set_shader_parameter("type", 1)
        (key_label.material as ShaderMaterial).set_shader_parameter("type", 1)
