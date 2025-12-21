@tool
class_name MarketRefreshButton extends GenericButton


var refresh_price: int

var icon_rotation_tween




func _process(delta: float) -> void :
    if Engine.is_editor_hint():
        return

    super._process(delta)

    hover_info_module.cost = refresh_price

    if is_pressed:
        icon_texture_rect.rotation_degrees = 0

        if is_instance_valid(icon_rotation_tween):
            icon_rotation_tween.kill()

        icon_rotation_tween = create_tween()
        icon_rotation_tween.tween_property(icon_texture_rect, "rotation_degrees", 360, 0.36).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
        await icon_rotation_tween.finished

        icon_texture_rect.rotation_degrees = 0
