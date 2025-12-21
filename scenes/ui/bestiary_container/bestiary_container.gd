class_name BestiaryContainer extends MarginContainer




@export var enemy_texture_container: GridContainer




func _ready() -> void :
    for child in enemy_texture_container.get_children():
        child.queue_free()



func add_enemy(enemy_resource: EnemyResource) -> void :
    var texture_rect = TextureRect.new()
    var texture = preload("res://assets/textures/enemies/unknown.png")

    texture_rect.add_to_group("visible_by_joypad")

    if is_instance_valid(enemy_resource):
        texture = enemy_resource.texture

    texture_rect.texture = texture

    texture_rect.material = ShaderMaterial.new()
    texture_rect.material.shader = preload("res://resources/shaders/enemy_cleaner.gdshader")

    enemy_texture_container.add_child(texture_rect)
