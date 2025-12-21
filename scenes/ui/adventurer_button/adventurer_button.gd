@tool
class_name AdventurerButton extends GenericButton

@export var border_texture_rect: TextureRect






func set_adventurer(adventurer: Adventurer) -> void :
    disabled_texture = adventurer.portrait
    pressed_texture = adventurer.portrait
    default_texture = adventurer.portrait
    hover_texture = adventurer.portrait
