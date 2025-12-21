class_name MenuItemEmitter extends Node2D



var item_content: Array[ItemResource] = []





func _ready() -> void :
    var viewport_size = get_viewport_rect().size
    var step: int = 25

    for x in roundi(viewport_size.x / step):
        for y in roundi(viewport_size.y / step):
            create_floating_texture(Vector2(x + randf_range(-10, 10), y + randf_range(-10, 10)) * step)


func _on_emit_timer_timeout() -> void :
    create_floating_texture(Vector2(randf_range(0, get_viewport_rect().size.x), -45))



func create_floating_texture(pos: Vector2) -> void :
    item_content.shuffle()

    var floating_texture: FloatingTexture = preload("res://scenes/objects/floating_texture/floating_texture.tscn").instantiate()
    floating_texture.position = pos
    floating_texture.texture = item_content.front().texture


    add_child(floating_texture)
