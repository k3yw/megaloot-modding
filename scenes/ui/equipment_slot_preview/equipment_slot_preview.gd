@tool
class_name EquipmentSlotPreview extends MarginContainer





@onready var main_slot_texture_rect: TextureRect = $MainSlotTextureRect
@onready var background_color_rect: ColorRect = $BackgroundColorRect
@onready var slot_texture_rect: TextureRect = $SlotTextureRect
@export var type: SocketType: set = set_type


func _ready():
    update_texture(false)


func set_type(value: SocketType) -> void :
    type = value
    update_texture(false)


func update_texture(locked: bool):
    if not is_instance_valid(slot_texture_rect):
        return

    if not is_instance_valid(type):
        return

    slot_texture_rect.texture = type.texture

    if locked:
        slot_texture_rect.texture = preload("res://assets/textures/ui/equipment_lock.png")
