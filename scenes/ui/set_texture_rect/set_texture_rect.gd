class_name SetTextureRect extends TextureRect

@onready var animation_player = $AnimationPlayer




func set_color(color: Color) -> void :
    (material as ShaderMaterial).set_shader_parameter("main_col", color)


func pop() -> void :
    animation_player.play("pop")

func pop_error() -> void :
    animation_player.play("pop_error")
