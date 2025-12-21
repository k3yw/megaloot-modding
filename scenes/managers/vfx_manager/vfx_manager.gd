class_name VFXManager extends Node2D






func create_impact_effect(type: StatResource, enemy_container: EnemyContainer) -> void :
    var impact_effect_scene: PackedScene
    match type:
        Stats.PHYSICAL_DAMAGE: impact_effect_scene = preload("res://scenes/vfx/physical_impact_effect/physical_impact_effect.tscn")
        Stats.MAGIC_DAMAGE: impact_effect_scene = preload("res://scenes/vfx/magic_impact_effect/magic_impact_effect.tscn")
        _: return

    var impact_effect: AnimatedEffect = impact_effect_scene.instantiate()
    impact_effect.enemy_container = enemy_container
    add_child(impact_effect)



func create_death_particles(pos: Vector2) -> void :
    var death_particles = preload("res://scenes/vfx/death_particles/death_particles.tscn").instantiate()
    death_particles.finished.connect( func(): death_particles.queue_free())
    death_particles.emitting = true
    death_particles.position = pos
    add_child(death_particles)




func create_upgrade_effect(pos: Vector2) -> void :
    var upgrade_effect = preload("res://scenes/vfx/upgrade_effect/upgrade_effect.tscn").instantiate()
    upgrade_effect.position = pos
    add_child(upgrade_effect)


func create_banish_effect(item_texture: Texture2D, item_slot: ItemSlot) -> void :
    var banish_effect = preload("res://scenes/vfx/banished_item_effect/banished_item_effect.tscn").instantiate()
    var pos: Vector2 = UI.get_rect(item_slot).get_center()
    banish_effect.texture = item_texture
    item_slot.add_child(banish_effect)
    banish_effect.global_position = pos


func create_enemy_popup_label_from_damage_result(pos: Vector2, damage_result: DamageResult) -> void :
    var enemy_popup_label: EnemyPopupLabel = preload("res://scenes/ui/enemy_popup_label/enemy_popup_label.tscn").instantiate()
    enemy_popup_label.position = pos
    add_child(enemy_popup_label)
    enemy_popup_label.apply_damage_result(damage_result)


func create_small_popup_label(pos: Vector2, text: String, color: Color, icon: Texture2D) -> void :
    var enemy_popup_label: EnemyPopupLabel = preload("res://scenes/ui/enemy_popup_label/enemy_popup_label.tscn").instantiate()
    enemy_popup_label.position = pos
    add_child(enemy_popup_label)
    (enemy_popup_label.amount_label.material as ShaderMaterial).set_shader_parameter("modulate", color)
    (enemy_popup_label.icon_texture.material as ShaderMaterial).set_shader_parameter("modulate", color)
    enemy_popup_label.icon_texture.texture = icon
    enemy_popup_label.amount_label.text = text



func create_consumption_effect(item_texture_rect: ItemTextureRect, portrait: AdventurerPortrait) -> void :
    var consumption_effect: ConsumptionVFX = preload("res://scenes/vfx/consumption_vfx/consumption_vfx.tscn").instantiate()
    if not is_instance_valid(item_texture_rect):
        return
    consumption_effect.sprite.texture = item_texture_rect.icon_texture_rect.texture
    consumption_effect.position = item_texture_rect.get_global_rect().get_center()
    add_child(consumption_effect)
    consumption_effect.start(portrait.get_global_rect().get_center())
