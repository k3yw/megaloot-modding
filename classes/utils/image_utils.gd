class_name ImageUtils




class Bounds:
    var top_pos: int
    var bottom_pos: int
    var right_pos: int
    var left_pos: int


static func get_png_bounds(texture: Texture2D) -> Bounds:
    var bounds = Bounds.new()
    var image = texture.get_image()
    bounds.top_pos = image.get_height()
    bounds.bottom_pos = 0

    bounds.right_pos = image.get_width()
    bounds.left_pos = 0


    for x in image.get_width():
        for y in image.get_height():
            var pixel_color: Color = image.get_pixel(x, y)
            if pixel_color.a:
                if bounds.top_pos > y:
                    bounds.top_pos = y

                if bounds.bottom_pos < y:
                    bounds.bottom_pos = y

                if bounds.right_pos > x:
                    bounds.right_pos = x

                if bounds.left_pos < x:
                    bounds.left_pos = x

    return bounds



static func get_rect2i_from_bounds(bounds: Bounds) -> Rect2i:
    if not is_instance_valid(bounds):
        return Rect2i()

    var height: int = bounds.bottom_pos - bounds.top_pos
    var width: int = bounds.left_pos - bounds.right_pos

    var center_y: int = bounds.top_pos + roundi(float(height) / 2)
    var center_x: int = bounds.right_pos + roundi(float(width) / 2)

    return Rect2i(Vector2i(center_x, center_y), Vector2i(width, height))
