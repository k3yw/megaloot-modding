class_name StatContainer extends HBoxContainer

@export var animation_player: AnimationPlayer
@export var texture_rect: TextureRect
@export var label: GenericLabel


var hovering: bool = false


func _ready() -> void :
    pivot_offset = size * 0.5

func _notification(what: int) -> void :
    if what == NOTIFICATION_RESIZED:
        pivot_offset = size * 0.5




func _process(_delta: float) -> void :
    var alpha: float = 1.0
    hovering = UI.is_hovered(self)

    if hovering:
        alpha = 0.5

    (texture_rect.material as ShaderMaterial).set_shader_parameter("alpha", alpha)
    label.set_alpha(alpha)



func set_color(type: int, color: Color = Color.WHITE) -> void :
    label.set_text_color(type, color)
    set_texture_color(type, color)


func set_outline_color(color: Color = Color.WHITE) -> void :
    label.set_outline_color(color)



func set_texture_color(type: int, color: Color = Color.WHITE) -> void :
    (texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", color)
    (texture_rect.material as ShaderMaterial).set_shader_parameter("type", type)
