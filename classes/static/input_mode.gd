class_name InputMode


enum Type{KEYBOARD, JOYPAD}




static func get_type(input_event: InputEvent) -> Type:
    if input_event is InputEventJoypadButton:
        return Type.JOYPAD

    if input_event is InputEventJoypadMotion:
        return Type.JOYPAD


    return Type.KEYBOARD




static func get_active_type() -> Type:
    if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
        return Type.JOYPAD

    return Type.KEYBOARD
