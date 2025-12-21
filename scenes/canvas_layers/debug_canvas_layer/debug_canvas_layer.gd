class_name DebugCanvasLayer extends CanvasLayer

@export var console_input: GenericLineEdit
@export var result_label: GenericLabel

var console_command_to_process: String = ""
var command_history: Array[String] = []


func _ready() -> void :
    hide()



func _input(event: InputEvent) -> void :
    if not event is InputEventKey:
        return

    if not OS.is_debug_build():
        return


    if Input.is_action_just_pressed("debug_console"):
        visible = not visible
        clear_next_frame()

        if visible:
            console_input.line_edit.grab_focus()
        return


    if Input.is_action_just_pressed("console_confirm"):
        console_command_to_process = console_input.line_edit.text


func clear_next_frame() -> void :
    await get_tree().process_frame
    console_input.line_edit.clear()






func push_result(result: String) -> void :
    result_label.text += result
    result_label.text += "\n"
