class_name AnimatedEffect extends Node2D

@export var animation_player: AnimationPlayer
var enemy_container: EnemyContainer = null
var enemy_texture_size: float
var offset: Vector2




func _ready() -> void :
    offset = enemy_container.enemy_texture_rect.get_screen_position() - enemy_container.get_screen_position()
    enemy_texture_size = enemy_container.enemy_texture_rect.size.x * 0.5
    animation_player.play("play")


func _process(_delta: float) -> void :
    if not is_instance_valid(enemy_container):
        return

    if not is_instance_valid(enemy_container.get_parent()):
        return

    if not enemy_container.get_parent().scale == Vector2(1, 1):
        return

    position = enemy_container.get_screen_position() + offset
    position.y += enemy_container.center_y
    position.x += enemy_texture_size




func _on_animation_player_animation_finished(_anim_name: StringName) -> void :
    queue_free()
