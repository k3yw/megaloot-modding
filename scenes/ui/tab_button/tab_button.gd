@tool
class_name TabButton extends MarginContainer


@onready var name_label: GenericLabel = $NameLabel
@onready var pressed_panel: NinePatchRect = $PressedPanel
@onready var icon_texture_rect: TextureRect = $IconTextureRect
@onready var hover_panel: NinePatchRect = $HoverPanel

@export var text: String = "name": set = set_text
@export var is_pressed: bool = false: set = set_is_pressed
@export var hovering: bool = false: set = set_hovering
@export var icon: Texture2D = null: set = set_icon

var original_text: String = text






func set_text(value: String) -> void :
    text = value
    update_name_label()


func set_icon(value: Texture2D) -> void :
    icon = value
    update_icon_texture_rect()


func set_is_pressed(value: bool) -> void :
    is_pressed = value

    update_pressed()
    update_name_label()
    update_icon_texture_rect()



func set_hovering(value: bool) -> void :
    hovering = value

    update_hovering()
    update_name_label()
    update_icon_texture_rect()




func _ready() -> void :
    update_icon_texture_rect()
    update_name_label()
    update_pressed()

    if Engine.is_editor_hint():
        return

    original_text = text

    reload_label()




func reload_label() -> void :
    text = " " + T.get_translated_string(original_text, "Button") + " "
    update_name_label()



func _process(_delta: float) -> void :
    if Engine.is_editor_hint():
        return

    hovering = UI.is_hovered(pressed_panel)



func update_name_label() -> void :
    if not is_instance_valid(name_label):
        return

    name_label.text = text

    if not Engine.is_editor_hint():
        name_label.set_flip_colors(false)


        if is_pressed:
            name_label.set_flip_colors(true)


            if hovering:
                name_label.set_flip_colors(false)




func update_icon_texture_rect() -> void :
    if not is_instance_valid(icon_texture_rect):
        return

    var icon_material: ShaderMaterial = icon_texture_rect.material as ShaderMaterial

    icon_texture_rect.texture = icon

    if not Engine.is_editor_hint():
        icon_material.set_shader_parameter("type", 2)


        if is_pressed:
            icon_material.set_shader_parameter("type", 1)


            if hovering:
                icon_material.set_shader_parameter("type", 2)





func update_pressed() -> void :
    if not is_instance_valid(pressed_panel):
        return

    pressed_panel.visible = is_pressed






func update_hovering() -> void :
    if not is_instance_valid(hover_panel):
        return

    if not is_pressed:
        hover_panel.visible = false
        return

    hover_panel.visible = hovering
