class_name ClipContainer extends ScrollContainer





func _process(_delta: float) -> void :
    if not get_global_rect().has_point(get_global_mouse_position()):
        return

    var parent = get_parent()
    if parent is ScrollContainer:
        if not parent.get_global_rect().has_point(get_global_mouse_position()):
            return

    var pos = get_local_mouse_position().clamp(Vector2.ZERO, size)
    var scroll_pos = (pos / size).x


    var strength: float = abs(scroll_pos - 0.5) * 0.05

    if scroll_pos < 0.5:
        scroll_horizontal -= size.x * strength

    if scroll_pos > 0.5:
        scroll_horizontal += size.x * strength
