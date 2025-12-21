class_name FloatingTexture extends Sprite2D

const AREA_RADIUS: int = 37

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var new_position: Vector2 = global_position


var rotation_direction = randi_range(0, 1)
var fall_dir = randf_range(-2, 2)
var hovered_last_frame: bool = false
var hovering: bool = false
var mouse_pos: Vector2


func _ready() -> void :
    scale = Vector2.ONE * randf_range(1.25, 1.75)

    (material as ShaderMaterial).set_shader_parameter("strength", get_scale_value())

    z_index = roundi(scale.x * 10)




func _process(delta: float) -> void :
    mouse_pos = get_global_mouse_position()
    var scale_value: float = get_scale_value()
    var rot = 0.5

    process_hover()

    if rotation_direction:
        rot = -0.5

    new_position.y += 5 * scale.x * delta

    new_position.x += fall_dir * scale.x * delta
    rotation += rot * delta


    position = (mouse_pos * (1.0 - scale_value) * 0.1) + new_position


    if position.y - 125 > get_viewport_rect().size.y:
        queue_free()


    var brightness: float = clamp(((100 / position.distance_to(mouse_pos)) * 0.5) - scale_value, 0, 1)
    if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
        brightness = 0.0

    (material as ShaderMaterial).set_shader_parameter("saturation", 1.0 + (brightness * 0.25))
    (material as ShaderMaterial).set_shader_parameter("brightness", brightness)





func process_hover() -> void :
    hovering = false

    if position.distance_to(mouse_pos) <= AREA_RADIUS:
        hovering = true

    if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
        hovering = false

    if not hovered_last_frame and hovering:
        animation_player.speed_scale = 1.0
        animation_player.play("pop_on")


    if hovered_last_frame and not hovering:
        animation_player.speed_scale = 1.0
        animation_player.play("pop_off")


    hovered_last_frame = hovering





func get_scale_value() -> float:
    return 1.0 - ((scale.x - 1.25) * 1.33333)
