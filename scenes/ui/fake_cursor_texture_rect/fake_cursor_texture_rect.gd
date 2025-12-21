class_name FakeCursorTextureRect extends TextureRect


var pointing_hand_texture: Texture2D
var arrow_texture: Texture2D




func update() -> void :
    var pixel_scale: int = CursorManager.get_pixel_scale()

    match Input.get_current_cursor_shape():
        Input.CURSOR_POINTING_HAND: texture = pointing_hand_texture
        Input.CURSOR_ARROW: texture = arrow_texture

    if not is_instance_valid(texture):
        return

    size = texture.get_size()
    pivot_offset = size * 0.5
    scale = Vector2(1.0 / pixel_scale, 1.0 / pixel_scale)
    position -= Vector2(16, 16)
