class_name EnemyPopupLabel extends CanvasGroup



@export var amount_label: GenericLabel
@export var icon_texture: TextureRect
@export var luck_texture: TextureRect
@export var container: HBoxContainer



func _ready() -> void :
    create_tween().tween_property(self, "position", position + Vector2(0, -10), 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    await get_tree().create_timer(0.3).timeout
    await create_tween().tween_method(set_alpha, 1.0, 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).finished
    queue_free()




func set_alpha(alpha: float) -> void :
    (material as ShaderMaterial).set_shader_parameter("alpha", alpha)




func apply_damage_result(damage_result: DamageResult) -> void :
    var amount: float = damage_result.uncapped_total_damage - damage_result.armor_removed
    var damage_icon: Texture2D = damage_result.damage_type.icon
    var damage_color: Color = damage_result.damage_type.color

    if damage_result.armor_removed > 0.0:
        damage_icon = Stats.PENETRATION.icon
        damage_color = Color("#6d758d")
        amount = damage_result.armor_removed


    (amount_label.material as ShaderMaterial).set_shader_parameter("modulate", damage_color)
    (icon_texture.material as ShaderMaterial).set_shader_parameter("modulate", damage_color)
    icon_texture.texture = damage_icon
    amount_label.text = Format.number(amount)


    if damage_result.is_crit:
        amount_label.add_theme_font_size_override("font_size", 32)

    luck_texture.visible = damage_result.is_lucky

    if not damage_result.result_type == BattleActions.HIT:
        hide()


    if damage_result.result_type == BattleActions.BLOCK:
        (amount_label.material as ShaderMaterial).set_shader_parameter("modulate", BattleActions.BLOCK.popup_color)
        amount_label.text = T.get_translated_string("Blocked").to_upper()
        icon_texture.hide()
        show()


    if damage_result.result_type == BattleActions.DODGE:
        amount_label.text = T.get_translated_string(BattleActions.DODGE.popup_text, "Popup").to_upper()
        (amount_label.material as ShaderMaterial).set_shader_parameter("modulate", BattleActions.DODGE.popup_color)
        show()
