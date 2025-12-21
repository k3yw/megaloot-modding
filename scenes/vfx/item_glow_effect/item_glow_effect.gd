class_name ItemGlowEffect extends PointLight2D


@export var animation_player: AnimationPlayer




func glow() -> void :
    animation_player.stop()
    animation_player.play("glow")
