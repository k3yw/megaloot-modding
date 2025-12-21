class_name TurnTimer extends TextureProgressBar


@export var animation_player: AnimationPlayer
@export var label: GenericLabel






func _process(delta: float) -> void :
    label.set_text_color(GlobalColors.Type.BORDER_COLOR)
    label.set_outline_color(Color("0b0f17"))

    (texture_progress as AtlasTexture).region.position.y = 0
    (texture_under as AtlasTexture).region.position.y = 0

    if value <= 5:
        (texture_progress as AtlasTexture).region.position.y = 26
        (texture_under as AtlasTexture).region.position.y = 26

        label.set_text_color(GlobalColors.Type.CUSTOM, Color("b42045"))
        label.set_outline_color(Color("2d132c"))

        if value > 0:
            animation_player.play("pop")
        else:
            animation_player.stop()
        return


    animation_player.stop()


func _on_value_changed(value: float) -> void :
    if value <= 5:
        AudioManager.play_sfx_at(
            preload("res://assets/sfx/ui/low_timer_impact.wav"), 
            UI.get_rect(self).position, 
            7.25 + (0.75 * (5 - value)), 
            1.0 + (0.025 * (5 - value))
            )
