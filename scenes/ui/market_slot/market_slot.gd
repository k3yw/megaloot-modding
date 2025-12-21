class_name MarketSlot extends VBoxContainer

@export var animation_player: AnimationPlayer
@export var convert_texture_rect: TextureRect
@export var item_slot: ItemSlot


var show_convert_texture_this_frame: bool



func set_color(type: int, color: Color = Color.WHITE) -> void :
    (item_slot.material as ShaderMaterial).set_shader_parameter("modulate", color)
    (item_slot.material as ShaderMaterial).set_shader_parameter("type", type)


func _process(_delta: float):
    process_lock_texture()



func process_lock_texture() -> void :
    if show_convert_texture_this_frame:
        show_convert_texture_this_frame = false
        convert_texture_rect.show()
        return

    convert_texture_rect.hide()
