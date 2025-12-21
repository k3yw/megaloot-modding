class_name AdventurerPortrait extends MarginContainer

@onready var shader: ShaderMaterial = portrait_canvas_group.material as ShaderMaterial

@export var set_texture_hover_info_module: HoverInfoModule

@export var border_texture_rect: TextureRect
@export var portrait_canvas_group: CanvasGroup
@export var portrait_texture_rect: TextureRect
@export var set_texture_rect: TextureRect
@export var blink_texture: TextureRect


var dryness: float
var blinking: bool
var eyes_closed: bool

var adventurer: Adventurer
var alpha: float = 1.0

func _ready() -> void :
    set_texture_rect.hide()





func _process(delta: float) -> void :
    if not is_instance_valid(adventurer):
        return

    process_blinking(delta)




func process_blinking(delta: float) -> void :
    if blinking:
        return

    dryness += delta

    if dryness > 3:
        blink()
        return

    if randf_range(0, 1) < 0.0025:
        blink()



func blink() -> void :
    if eyes_closed:
        return

    blink_texture.show()
    blinking = true

    await get_tree().create_timer(0.16).timeout

    blink_texture.hide()
    blinking = false
    dryness = 0



func close_eyes() -> void :
    eyes_closed = true
    blink_texture.show()




func set_adventurer(arg_adventurer: Adventurer) -> void :
    if not is_instance_valid(arg_adventurer) or arg_adventurer == Empty.adventurer:
        portrait_texture_rect.texture = preload("res://assets/textures/portraits/unknown.png")
        shader.set_shader_parameter("alpha", 0.1)
        blink_texture.texture = null
        alpha = 0.1
        return

    portrait_texture_rect.texture = arg_adventurer.portrait
    blink_texture.texture = arg_adventurer.blink
    shader.set_shader_parameter("alpha", 1.0)
    adventurer = arg_adventurer
    alpha = 1.0



func set_border(floor_number: int) -> void :
    var border_type: AdventurerBorder.Type = AdventurerBorder.get_type(adventurer, floor_number)
    border_texture_rect.texture = AdventurerBorder.get_texture(border_type)



func set_extra_set(item_set: ItemSetResource, specialization: Specialization = null) -> void :
    set_texture_hover_info_module.data = [item_set]
    if not is_instance_valid(item_set):
        set_texture_rect.hide()
        return

    var set_texture_shader: ShaderMaterial = set_texture_rect.material as ShaderMaterial
    set_texture_shader.set_shader_parameter("modulate", item_set.color)
    set_texture_rect.texture = item_set.icon

    if is_instance_valid(specialization):
        set_texture_shader.set_shader_parameter("modulate", specialization.get_color())
        set_texture_rect.texture = specialization.original_item_set.icon

    set_texture_rect.show()



func set_as_normal() -> void :
    shader.set_shader_parameter("modulate", Color.WHITE)
    shader.set_shader_parameter("wobble", 0.0)
    shader.set_shader_parameter("alpha", 1.0)



func set_as_phantom() -> void :
    shader.set_shader_parameter("modulate", Color.CYAN)
    shader.set_shader_parameter("wobble", 0.1)
    shader.set_shader_parameter("alpha", 0.75)
