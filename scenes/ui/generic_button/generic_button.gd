@tool
class_name GenericButton extends MarginContainer

signal pressed

const DEFAULT_TIME_TO_PRESS: float = 0.15

@onready var outline_nine_patch_rect: NinePatchRect = $OutlineMarginContainer / OutlineNinePatchRect
@onready var name_label: GenericLabel = $MarginContainer / HBoxContainer / NameLabel
@onready var icon_texture_rect: TextureRect = $NinePatchRect / IconTextureRect
@onready var hover_info_module: HoverInfoModule = $HoverInfoModule
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect

@onready var button_material: ShaderMaterial = nine_patch_rect.material as ShaderMaterial
@onready var icon_material: ShaderMaterial = icon_texture_rect.material as ShaderMaterial


@export var hold_progress_bar: TextureProgressBar

@export var text: String = "BUTTON": set = set_text

@export var disable_effects: bool = false
@export var disabled_texture: Texture2D
@export var pressed_texture: Texture2D
@export var default_texture: Texture2D
@export var hover_texture: Texture2D
@export var icon_texture: Texture2D
@export var button_color: GlobalColors.Type: set = set_button_color
@export var icon_color: GlobalColors.Type: set = set_icon_color
@export var show_outline: bool = false: set = set_show_outline
@export var icon_offset_on_press: Vector2
@export var disabled: bool = false: set = set_disabled
@export var hold_time: float = 0.0: set = set_hold_time
@export var debounce_time: float = 0.0: set = set_debounce_time

var original_text: String = text
var curr_hold_time: float = hold_time
var hovered_last_frame: bool = false
var is_pressed: bool = false
var animating: bool = false
var hovering: bool = false
var pressing: bool = false

var time_to_press: float = DEFAULT_TIME_TO_PRESS
var debounce_time_left: float = debounce_time
var just_hovered: bool = false


func set_text(value: String) -> void :
    text = value
    update_name_label()



func set_button_color(value: GlobalColors.Type) -> void :
    button_color = value
    update_visuals()


func set_icon_color(value: GlobalColors.Type) -> void :
    icon_color = value
    update_visuals()



func set_show_outline(value: bool) -> void :
    show_outline = value
    update_visuals()


func set_disabled(value: bool) -> void :
    disabled = value
    update_visuals()


func set_hold_time(value: float) -> void :
    if is_instance_valid(hold_progress_bar):
        hold_progress_bar.max_value = value
    hold_time = value


func set_debounce_time(value: float) -> void :
    debounce_time_left = value
    debounce_time = value



func _ready() -> void :
    hold_progress_bar.hide()
    update_name_label()
    update_visuals()

    if Engine.is_editor_hint():
        return

    original_text = text

    reload_label()



func reload_label() -> void :
    text = " " + T.get_translated_string(original_text, "Button") + " "
    update_name_label()









func _process(delta: float) -> void :
    if Engine.is_editor_hint():
        return

    debounce_time_left = maxf(0.0, debounce_time_left - delta)
    just_hovered = false
    hovering = false

    if is_pressed:
        icon_texture_rect.position -= icon_offset_on_press
        is_pressed = false

    if not is_visible_in_tree():
        return

    if animating:
        return

    hovering = UI.is_hovered(self)

    update_visuals()

    if disabled:
        return

    if not hovered_last_frame and hovering:
        just_hovered = true

    process_press(delta)

    hovered_last_frame = hovering
    hold_progress_bar.visible = curr_hold_time
    hold_progress_bar.value = curr_hold_time

    if curr_hold_time == hold_time:
        hold_progress_bar.hide()






func process_press(delta: float) -> void :
    if debounce_time_left > 0.0:
        return

    if time_to_press == DEFAULT_TIME_TO_PRESS or not hold_time:
        time_to_press = 0.0

    if hovering or pressing:
        if time_to_press:
            time_to_press = minf(time_to_press + delta, DEFAULT_TIME_TO_PRESS)

        if curr_hold_time == 0 and (Input.is_action_just_pressed("press") or pressing):
            curr_hold_time = minf(curr_hold_time + delta, hold_time)
            time_to_press += delta


        if Input.is_action_pressed("press") or pressing or time_to_press:
            icon_material.set_shader_parameter("type", 1)
            nine_patch_rect.texture = pressed_texture

            if curr_hold_time:
                curr_hold_time = minf(curr_hold_time + delta, hold_time)

            if not disable_effects:
                button_material.set_shader_parameter("saturation", 1.0)
                button_material.set_shader_parameter("brightness", 0)

            if finished_pressing():
                icon_texture_rect.position += icon_offset_on_press
                debounce_time_left = debounce_time
                curr_hold_time = 0.0
                time_to_press = 0.0
                is_pressed = true
                pressed.emit()

            return


    curr_hold_time = 0.0





func finished_pressing() -> bool:
    if hold_time:
        if curr_hold_time >= hold_time and not is_pressed:
            return true

        return false

    if not is_pressed and (Input.is_action_just_pressed("press") or pressing):
        return true

    return false








func play_press() -> void :
    animating = true
    nine_patch_rect.texture = pressed_texture
    await get_tree().create_timer(0.16).timeout
    animating = false





func update_visuals() -> void :
    if is_instance_valid(outline_nine_patch_rect):
        outline_nine_patch_rect.visible = show_outline

    if not is_instance_valid(button_material):
        return

    nine_patch_rect.texture = default_texture
    icon_texture_rect.texture = icon_texture

    button_material.set_shader_parameter("type", button_color)
    icon_material.set_shader_parameter("modulate", icon_texture_rect.modulate)
    icon_material.set_shader_parameter("type", icon_color)
    button_material.set_shader_parameter("saturation", 1.0)
    button_material.set_shader_parameter("brightness", 0)


    if hovering:
        if not disable_effects:
            button_material.set_shader_parameter("saturation", 1.0)
            button_material.set_shader_parameter("brightness", 0.25)

        icon_material.set_shader_parameter("type", button_color)
        nine_patch_rect.texture = hover_texture


    if disabled:
        icon_material.set_shader_parameter("type", button_color)
        nine_patch_rect.texture = disabled_texture
        if not disable_effects:
            button_material.set_shader_parameter("saturation", 0.0)
            button_material.set_shader_parameter("brightness", -0.25)




func set_alpha(amount: float) -> void :
    button_material.set_shader_parameter("alpha", amount)



func update_name_label() -> void :
    if not is_instance_valid(name_label):
        return

    name_label.text = text
