class_name PopupLabelData extends RefCounted



var text: String
var color: Color
var left_texture: Texture2D
var right_texture: Texture2D
var delay: float = 0.0
var position: Vector2
var size: float = 1.0


func _init(arg_text: String = "", arg_color: Color = Color.WHITE) -> void :
    text = arg_text
    color = arg_color
