class_name SynergyContainer extends MarginContainer


@export var main_set_texture_rect: TextureRect
@export var synergy_set_texture_rect: TextureRect
@export var result_set_texture_rect: TextureRect

@export var main_set_hover_info_module: HoverInfoModule
@export var synergy_set_hover_info_module: HoverInfoModule
@export var result_set_hover_info_module: HoverInfoModule



func apply_item_sets(specialization: Specialization) -> void :
    main_set_texture_rect.texture = specialization.synergy_item_set.icon
    (main_set_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", specialization.synergy_item_set.color)
    main_set_hover_info_module.data = [specialization.synergy_item_set]

    synergy_set_texture_rect.texture = specialization.original_item_set.icon
    (synergy_set_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", specialization.original_item_set.color)
    synergy_set_hover_info_module.data = [specialization.original_item_set]

    result_set_texture_rect.texture = specialization.original_item_set.icon
    (result_set_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", specialization.get_color())
    result_set_hover_info_module.data = [specialization]
