class_name RewardContainer extends MarginContainer

@export var borders: Array[Control] = []
@export var lock_texture_rect: TextureRect

@export var adventurer_texture_rect: TextureRect
@export var border_texture_rect: TextureRect
@export var goal_label: GenericLabel




func show_as_locked() -> void :
    for border in borders:
        (border.material as ShaderMaterial).set_shader_parameter("type", GlobalColors.Type.BORDER_COLOR)

    lock_texture_rect.show()
