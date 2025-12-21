@tool
class_name GenericLabel extends Label


@export var ignore_plus: bool = false
@export var is_percent: bool = false
@export var use_suffix: bool = false
@export var use_prefix: bool = false
@export var is_value: bool = false
@export var is_whole: bool = true
@export var update_speed: float = 2.5

@export var ignore_font_override: bool = false
@export var translate: bool = true

var original_text: String = text
var target_value: float = 0.0
var curr_value: float = 0.0



func _ready() -> void :
    if is_value:
        text = Format.number(curr_value, get_rules())
        update_value(0, true)
        return

    if Engine.is_editor_hint():
        return

    original_text = text
    reload_label()


func reload_label() -> void :
    if translate and not is_value:
        text = T.get_translated_string(original_text, "Label")


    var font = preload("res://assets/fonts/monogram-extended.ttf")
    var font_size: int = 16

    if not ignore_font_override:
        match TranslationServer.get_locale():
            "japanese":
                font = preload("res://assets/fonts/Galmuri11.ttf")
                font_size = 12

            "koreana":
                font = preload("res://assets/fonts/Galmuri11.ttf")
                font_size = 12

            "schinese":
                font = preload("res://assets/fonts/VonwaonBitmap-12px.ttf")
                font_size = 12

            "tchinese":
                font = preload("res://assets/fonts/Cubic_11_1.100_R.ttf")
                font_size = 12


    add_theme_font_size_override("font_size", font_size)
    add_theme_font_override("font", font)






func set_curr_value(new_curr_value: float) -> void :
    text = Format.number(new_curr_value, get_rules())
    curr_value = new_curr_value



func _process(delta: float) -> void :
    if not is_visible_in_tree():
        return

    if Engine.is_editor_hint():
        return

    if not is_value:
        return

    update_value(delta)



func update_value(delta: float, force: bool = false) -> void :
    if not force and target_value == curr_value:
        return

    var speed: float = delta * abs(target_value - curr_value) * update_speed

    if force or update_speed == -1:
        speed = 1

    curr_value = move_toward(curr_value, target_value, speed)

    if curr_value >= target_value - 0.1:
        curr_value = target_value

    text = Format.number(curr_value, get_rules())




func get_rules() -> Array[Format.Rules]:
    var rules: Array[Format.Rules] = []

    if ignore_plus:
        rules.push_back(Format.Rules.IGNORE_PLUS)

    if use_prefix:
        rules.push_back(Format.Rules.USE_PREFIX)

    if use_suffix:
        rules.push_back(Format.Rules.USE_SUFFIX)

    if is_percent:
        rules.push_back(Format.Rules.PERCENTAGE)

    if is_whole:
        rules.push_back(Format.Rules.IS_WHOLE)

    return rules




func set_text_color(type: int, color: Color = Color.WHITE) -> void :
    material.set_shader_parameter("modulate", color)
    material.set_shader_parameter("type", type)


func set_outline_color(color: Color) -> void :
    material.set_shader_parameter("outline_color", color)

func set_alpha(alpha: float):
    material.set_shader_parameter("alpha", alpha)


func set_flip_colors(flip_colors: bool):
    material.set_shader_parameter("flip_colors", flip_colors)
