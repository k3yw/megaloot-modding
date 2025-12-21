class_name ScreenFlashEffect extends ColorRect


@onready var animation_player: AnimationPlayer = $AnimationPlayer




func flash() -> void :
    animation_player.play("play")


func play_damage() -> void :
    if not animation_player.is_playing():
        show_as_damage()
        flash()


func show_as_gold() -> void :
    color = Color("#ffc03c4b")


func show_as_damage() -> void :
    color = Color("#ff0000")


func show_as_stun() -> void :
    color = Color("#989898")
