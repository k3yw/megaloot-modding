class_name EffectContainer extends HBoxContainer



@export var icon_texture_rect: TextureRect
@export var amount_label: GenericLabel


var status_effect_resource: StatusEffectResource
var item_set_resource: ItemSetResource
var specialization: Specialization
var stat_resource: StatResource

var character: Character = null
var is_pressed: bool = false






func _process(_delta: float) -> void :
    is_pressed = false

    if not visible:
        amount_label.target_value = 0

    if UI.is_hovered(self) and Input.is_action_just_pressed("press"):
        is_pressed = true




func set_effect(arg_effect, amount: float = 1) -> void :
    if not is_instance_valid(arg_effect):
        remove_from_group("visible_by_joypad")
        icon_texture_rect.texture = null
        amount_label.hide()
        return

    add_to_group("visible_by_joypad")

    if arg_effect is StatusEffectResource:
        status_effect_resource = arg_effect

        (icon_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", status_effect_resource.color)
        icon_texture_rect.texture = status_effect_resource.icon

        amount_label.is_percent = status_effect_resource.is_percent
        add_theme_constant_override("separation", 3)
        amount_label.show()

        if amount < 2:
            amount_label.hide()
            add_theme_constant_override("separation", 0)

        if amount > 1:
            amount_label.set_text_color(0, status_effect_resource.color)
            amount_label.target_value = amount



    if arg_effect is StatResource:
        var color: Color = arg_effect.color
        stat_resource = arg_effect

        if amount < 0:
            color = Color("#ff0049")

        (icon_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", color)
        icon_texture_rect.texture = stat_resource.icon

        add_theme_constant_override("separation", 3)
        amount_label.show()

        amount_label.set_text_color(0, color)
        amount_label.is_percent = stat_resource.is_percentage
        amount_label.target_value = amount


    if arg_effect is Specialization:
        specialization = arg_effect

        amount_label.hide()
        add_theme_constant_override("separation", 0)

        (icon_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", specialization.get_color())
        icon_texture_rect.texture = specialization.original_item_set.icon

    if arg_effect is ItemSetResource:
        item_set_resource = arg_effect

        amount_label.hide()
        add_theme_constant_override("separation", 0)

        (icon_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", item_set_resource.color)
        icon_texture_rect.texture = item_set_resource.icon
