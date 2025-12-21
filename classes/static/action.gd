class_name Action




static func get_press_texture() -> Texture2D:
    var joypad_active: bool = Input.mouse_mode == Input.MOUSE_MODE_HIDDEN

    if joypad_active:
        return preload("res://assets/textures/icons/steam_deck_a.png")

    return preload("res://assets/textures/icons/left_click_icon.png")


static func get_alt_press_texture() -> Texture2D:
    var joypad_active: bool = Input.mouse_mode == Input.MOUSE_MODE_HIDDEN

    if joypad_active:
        return preload("res://assets/textures/icons/steam_deck_x.png")

    return preload("res://assets/textures/icons/right_click_icon.png")
