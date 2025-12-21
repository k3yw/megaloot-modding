class_name PopupLabel extends CanvasGroup


@export var animation_player: AnimationPlayer
@export var right_texture_rect: TextureRect
@export var left_texture_rect: TextureRect
@export var container: HBoxContainer
@export var label: GenericLabel

var life_time: float = 1.0


func _ready():
    create_tween().tween_property(self, "position:y", position.y - 75, life_time).set_ease(Tween.EASE_OUT)
    create_tween().tween_property(self, "modulate:a", 0, life_time).set_ease(Tween.EASE_OUT)

    await get_tree().create_timer(life_time).timeout
    queue_free()



func apply_data(data: PopupLabelData) -> void :
    label.text = " " + T.get_translated_string(data.text, "Popup").to_upper() + " "

    set_color(data.color)

    right_texture_rect.hide()
    left_texture_rect.hide()

    if is_instance_valid(data.left_texture):
        left_texture_rect.texture = data.left_texture
        left_texture_rect.show()

    if is_instance_valid(data.right_texture):
        right_texture_rect.texture = data.right_texture
        right_texture_rect.show()

    position = data.position
    container.scale = Vector2.ONE * data.size
    position.x += randi_range(-35, 35)


func set_shader_alpha(alpha: float):
    container.material.set_shader_parameter("alpha", alpha)


func set_color(color: Color) -> void :
    container.material.set_shader_parameter("modulate", color)
