class_name EquipWarning extends GenericLabel


var life_time: float = 1.75




func _ready() -> void :
    create_tween().tween_property(self, "position:y", position.y - 15, life_time).set_ease(Tween.EASE_OUT)
    set_alpha(0.0)

    create_tween().tween_method(set_alpha, 0.0, 1.0, life_time / 4).set_ease(Tween.EASE_OUT)
    await get_tree().create_timer(life_time / 2).timeout
    create_tween().tween_method(set_alpha, 1.0, 0.0, life_time / 4).set_ease(Tween.EASE_OUT)

    await get_tree().create_timer(life_time / 2).timeout
    queue_free()
