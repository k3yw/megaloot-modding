@tool
class_name AdventurerTreeNode extends MarginContainer

signal pressed

enum Type{ADVENTURER, SPECIALIZATION, STAT}

@onready var icon_texture_rect: TextureRect = $CenterContainer / IconTextureRect
@onready var cover_texture_rect: TextureRect = $CoverTextureRect
@export var lock_texture_rect: TextureRect

@onready var card_material: ShaderMaterial = cover_texture_rect.material as ShaderMaterial

@export var unknown_texture_rect: TextureRect
@export var type: Type = Type.ADVENTURER: set = set_type

@export var hover_info_module: HoverInfoModule

var disabled: bool = false

var is_pressed: bool = false
var hovering: bool = false


func set_type(value: Type) -> void :
    type = value
    update_cover_texture()



func _ready() -> void :
    update_cover_texture()




func _process(_delta: float) -> void :
    if Engine.is_editor_hint():
        return

    hovering = false
    is_pressed = false


    card_material.set_shader_parameter("brightness", 0.0)

    if UI.is_hovered(self):
        card_material.set_shader_parameter("brightness", 0.5)
        hovering = true

        if Input.is_action_just_pressed("press"):
            is_pressed = true
            pressed.emit()






func update_cover_texture() -> void :
    if not is_instance_valid(cover_texture_rect):
        return

    var texture: AtlasTexture = (cover_texture_rect.texture as AtlasTexture)

    texture.atlas = preload("res://assets/textures/ui/normal_tree_node.png")
    texture.region.size.x = 50
    texture.region.size.y = 50
    size = Vector2(50, 50)

    if type == Type.STAT:
        texture.atlas = preload("res://assets/textures/ui/small_tree_node.png")
        texture.region.size.x = 26
        texture.region.size.y = 26
        size = Vector2(26, 26)



func update_icon_texture(card) -> void :
    card_material.set_shader_parameter("type", 2)

    if card is Adventurer:
        var border_type: AdventurerBorder.Type = AdventurerBorder.get_type(card, UserData.profile.get_floor_record(card))
        cover_texture_rect.texture = AdventurerBorder.get_texture(border_type)
        icon_texture_rect.texture = card.portrait
        card_material.set_shader_parameter("type", 0)
        modulate = Color.WHITE

        show_as_normal()

        if not card.name.length():
            icon_texture_rect.texture = preload("res://assets/textures/portraits/unknown.png")
            modulate = Color.WHITE
            modulate.a = 0.1
        return

    if card is Specialization:
        icon_texture_rect.texture = card.original_item_set.icon
        modulate = card.color
        return

    if card is StatResource:
        icon_texture_rect.texture = card.icon
        modulate = card.color






func show_as_normal() -> void :
    if cover_texture_rect.texture is AtlasTexture:
        (cover_texture_rect.texture as AtlasTexture).region.position.x = 0
    card_material.set_shader_parameter("brightness", 0.0)
    card_material.set_shader_parameter("alpha", 1.0)
    icon_texture_rect.modulate.a = 1.0
    lock_texture_rect.hide()
    disabled = false







func show_as_disabled() -> void :
    if cover_texture_rect.texture is AtlasTexture:
        (cover_texture_rect.texture as AtlasTexture).region.position.x = 50

    if type == Type.STAT:
        (cover_texture_rect.texture as AtlasTexture).region.position.x = 26

    card_material.set_shader_parameter("alpha", 0.75)
    icon_texture_rect.modulate.a = 0.5
    disabled = true






func show_as_locked() -> void :
    lock_texture_rect.show()

    card_material.set_shader_parameter("alpha", 0.75)
    icon_texture_rect.modulate = Color.WHITE
    icon_texture_rect.modulate.a = 0.25
