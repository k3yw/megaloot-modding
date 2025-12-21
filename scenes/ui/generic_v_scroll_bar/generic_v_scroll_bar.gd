class_name GenericVScrollBar extends MarginContainer


const MIN_SIZE: int = 12
const OFFSET: int = 2

@export var scroll_rect: NinePatchRect

@onready var target_pos: float = OFFSET

var last_local_press_pos: Vector2
var hovering: bool = false
var dragging: bool


var axis_value: float

var max_size: float
var min_size: float

var last_pos: float


func update_size() -> void :
    var new_size: float = float(min_size - (OFFSET * 2)) * get_ratio()

    if not is_nan(new_size):
        scroll_rect.size.y = maxi(12, int(new_size))

    visible = not max_size == min_size



func _process(delta: float) -> void :
    if not is_visible_in_tree():
        return
    var scroll_rect_texture: AtlasTexture = scroll_rect.texture
    scroll_rect_texture.region.position.x = 0
    hovering = UI.is_hovered(scroll_rect)

    if hovering or dragging:
        scroll_rect_texture.region.position.x = 6

        if Input.is_action_just_pressed("press"):
            last_local_press_pos = scroll_rect.get_local_mouse_position()
            dragging = true

    if Input.is_action_just_released("press"):
        dragging = false

    if axis_value:
        target_pos = scroll_rect.position.y + (axis_value * 10)

    if dragging:
        target_pos = get_local_mouse_position().y - last_local_press_pos.y


    target_pos = clamp(target_pos, OFFSET, size.y - scroll_rect.size.y - OFFSET)
    var new_delta: float = delta * 17.5

    if abs(scroll_rect.position.y - target_pos) < 1:
        new_delta = 1

    scroll_rect.position.y = lerp(scroll_rect.position.y, target_pos, new_delta)


    if not roundi(last_pos / 10) == roundi(scroll_rect.position.y / 10):
        var tone_event: ToneEventResource = ToneEventResource.new()
        var tone = Tone.new(preload("res://assets/sfx/hi_hit.wav"))
        tone_event.position = UI.get_rect(scroll_rect).get_center()
        tone_event.space_type = ToneEventResource.SpaceType._2D
        tone_event.tones.push_back(tone)
        AudioManager.play_event(tone_event, name)


    last_pos = scroll_rect.position.y





func _input(event: InputEvent) -> void :
    if not hovering:
        return

    if event is InputEventJoypadMotion:
        if event.axis == JOY_AXIS_RIGHT_Y:
            axis_value = roundf(event.axis_value * 10) / 10.0



func get_ratio() -> float:
    return float(min_size) / float(max_size)



func get_max_pos() -> int:
    return int(size.y - scroll_rect.size.y - (OFFSET * 2))


func get_scroll() -> float:
    var curr_pos: float = float(scroll_rect.position.y - OFFSET)
    var max_pos: float = float(get_max_pos())
    return (curr_pos / max_pos) * (max_size - min_size)
