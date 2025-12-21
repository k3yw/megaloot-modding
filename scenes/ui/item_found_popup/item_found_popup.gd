class_name ItemFoundPopup extends MarginContainer


@export var texture_rect: TextureRect
@export var label: GenericLabel


var life_time: float = 2.25


func _ready():
    create_tween().tween_property(self, "position:y", position.y + 25, life_time).set_ease(Tween.EASE_OUT)
    create_tween().tween_property(self, "modulate:a", 0, life_time).set_ease(Tween.EASE_OUT)


    await get_tree().create_timer(life_time).timeout
    queue_free()
