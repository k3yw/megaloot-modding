class_name ConsumptionVFX extends Path2D




@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D



func start(end_pos: Vector2) -> void :
    var new_end_pos: Vector2 = end_pos - position
    curve.clear_points()
    curve.add_point(Vector2.ZERO)
    curve.add_point(new_end_pos, Vector2(50, 0))

    animation_player.play("start")


func _on_animation_player_animation_finished(anim_name: StringName) -> void :
    queue_free()
