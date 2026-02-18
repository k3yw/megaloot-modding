class_name GenericLineEdit extends MarginContainer

signal changed


@export var panel: NinePatchRect
@export var line_edit: LineEdit
@export var char_limit: int = -1
@export var caps_locked: bool = false


var last_frame_line_edit: String = ""
var hovering: bool = false
var is_changed: bool = false

var disabled: bool = false


func _ready() -> void :
    line_edit.placeholder_text = T.get_translated_string(line_edit.placeholder_text, "Line Edit") + " "


func _process(_delta: float) -> void :
    if disabled:
        (panel.material as ShaderMaterial).set_shader_parameter("alpha", 0.5)
        return

    (panel.material as ShaderMaterial).set_shader_parameter("alpha", 1.0)

    hovering = UI.is_hovered(self)
    process_press()

    is_changed = false

    if not last_frame_line_edit == line_edit.text:
        is_changed = true
        changed.emit()

    last_frame_line_edit = line_edit.text



func process_press() -> void :
    if not Input.is_action_just_pressed("press"):
        return

    if hovering:
        var rect = UI.get_rect(self)
        line_edit.grab_focus()
        line_edit.caret_column = line_edit.text.length()

        if Platform.is_active():
            var result = Platform.steam.showFloatingGamepadTextInput(
                Platform.steam.FLOATING_GAMEPAD_TEXT_INPUT_MODE_SINGLE_LINE, 
                rect.position.x, 
                rect.position.y, 
                rect.size.x, 
                rect.size.y, 
                )

            return

    line_edit.release_focus()





func _on_line_edit_text_changed(new_text: String) -> void :
    if not char_limit == -1:
        line_edit.text = new_text.substr(0, char_limit)
        line_edit.caret_column = line_edit.text.length()

    if caps_locked:
        line_edit.text = line_edit.text.to_upper()
        line_edit.caret_column = line_edit.text.length()



func _on_line_edit_editing_toggled(toggled_on: bool) -> void :
    if toggled_on:
        UI.active_line_edit = line_edit
        return

    if UI.active_line_edit == line_edit:
        UI.active_line_edit = null
