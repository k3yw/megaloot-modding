class_name GameplayScreenTransition extends SubViewportContainer


@export var animation_player: AnimationPlayer




func start(speed: float = 1.0) -> void :
    animation_player.play("transition_start", -1, speed)
    await animation_player.animation_finished


func end(speed: float = 1.0) -> void :
    animation_player.play("transition_end", -1, speed)
    await animation_player.animation_finished
