@tool
class_name LabelButton extends GenericLabel



var hovering: bool = false
var is_pressed: bool
var selected: bool





func _process(_delta: float) -> void :
    set_flip_colors(false)
    is_pressed = false

    hovering = UI.is_hovered(self)

    if hovering:
        Input.set_default_cursor_shape.call_deferred(Input.CURSOR_POINTING_HAND)

    if hovering or selected:
        set_flip_colors(true)

        if Engine.is_editor_hint():
            return

        if Input.is_action_just_pressed("press"):
            is_pressed = true
