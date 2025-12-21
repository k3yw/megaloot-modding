class_name EnemyContainer extends VBoxContainer


@export var animation_player: AnimationPlayer

@export var selection_texture_rect: TextureRect
@export var immunity_texture_rect: TextureRect

@export var effect_container_holder: EffectContainerHolder

@export var stats_container: MarginContainer

@export var enemy_mana_bar: SmallResourceBar
@export var enemy_health_bar: ResourceBar
@export var enemy_armor_bar: ResourceBar

@export var ability_preview_particles: Array[CPUParticles2D]
@export var ability_particles: Array[CPUParticles2D]
@export var cinder_particles: Array[CPUParticles2D]
@export var heart_particles: CPUParticles2D

@export var enemy_texture_rect: TextureRect
@export var selection_rect: ColorRect
@export var shadow: ColorRect

@export var nodes_to_hide_on_death: Array[Control]
@export var enemy_visuals: Control

@export var next_enemy_fade_animation_player: AnimationPlayer
@export var next_enemy_animation_player: AnimationPlayer
@export var next_enemy_texture_rect: TextureRect
@export var next_enemy_layer: CanvasGroup

@export var shield_sprite: Sprite2D


var target_ice_alpha: float = 0.0
var curr_ice_alpha: float = 0.0


var texture_size: Vector2 = Vector2.ZERO
var image_bounds: ImageUtils.Bounds
var hiding: bool = false
var center_y: int = 0
var center_x: int = 0


func _ready() -> void :
    stop_ability_preview_particles()
    shield_sprite.visible = false


func set_texture(texture: Texture2D) -> void :
    image_bounds = ImageUtils.get_png_bounds(texture)
    var image_rect = ImageUtils.get_rect2i_from_bounds(image_bounds)

    center_x = image_rect.position.x
    center_y = image_rect.position.y
    texture_size = texture.get_size()

    enemy_texture_rect.pivot_offset.y = center_y
    (enemy_texture_rect.texture as AtlasTexture).atlas = texture


    shadow.size.x = texture_size.x

    shield_sprite.scale = Vector2.ONE * (pow(image_rect.size.y, 0.25) + 0.15)

    var shadow_width: float = minf(1, (float(image_rect.size.x + 8) / texture_size.x))
    var shadow_height: float = roundf((shadow_width * 0.42) * 100.0) / 100.0

    (shadow.material as ShaderMaterial).set_shader_parameter("height", shadow_height)
    (shadow.material as ShaderMaterial).set_shader_parameter("width", shadow_width)

    var ice_offset_y: float = float(64 - image_bounds.bottom_pos) / 64
    ice_offset_y -= 0.15

    (enemy_texture_rect.material as ShaderMaterial).set_shader_parameter("ice_offset", Vector2(0, ice_offset_y))
    (enemy_texture_rect.material as ShaderMaterial).set_shader_parameter("ice_height", float(image_rect.size.y) / 64)






func _process(delta: float) -> void :
    var texture_offset = (enemy_texture_rect.material as ShaderMaterial).get_shader_parameter("texture_offset")

    (shield_sprite.material as ShaderMaterial).set_shader_parameter("texture_offset", texture_offset / shield_sprite.scale)
    (enemy_texture_rect.material as ShaderMaterial).set_shader_parameter("ice_alpha", curr_ice_alpha)
    curr_ice_alpha = lerp(curr_ice_alpha, target_ice_alpha, delta * 10.0)


    shield_sprite.global_position.y = center_y + enemy_texture_rect.global_position.y

    shadow.position.x = - texture_size.x * 0.5
    (enemy_texture_rect.texture as AtlasTexture).region.position.x = -64 - (32 - (texture_size.x * 0.5))



func set_shield_sprite_color(color: Color) -> void :
    (shield_sprite.material as ShaderMaterial).set_shader_parameter("color", color)





func set_alpha(alpha: float) -> void :
    (enemy_texture_rect.material as ShaderMaterial).set_shader_parameter("alpha", alpha)





func get_death_particles_position() -> Vector2:
    var death_particles_position = enemy_texture_rect.global_position

    death_particles_position += enemy_texture_rect.pivot_offset
    death_particles_position.y -= 8

    return death_particles_position





func play_fade_out(speed: float, force: bool = false) -> void :
    if force:
        (next_enemy_texture_rect.material as ShaderMaterial).set_shader_parameter("alpha", 0.0)
        return

    next_enemy_fade_animation_player.play("fade_out", -1, speed)

    if next_enemy_fade_animation_player.is_playing():
        await next_enemy_fade_animation_player.animation_finished



func play_fade_in(speed: float) -> void :
    animation_player.play("fade_in", -1, speed)

    if animation_player.is_playing():
        await animation_player.animation_finished




func emit_ability_particles(color: Color) -> void :
    for partricles in ability_particles:
        partricles.emitting = true
        partricles.color = color



func start_ability_preview_particles(color: Color) -> void :
    for partricles in ability_preview_particles:
        partricles.emitting = true
        partricles.color = color




func emit_cinder_particles() -> void :
    for partricles in cinder_particles:
        partricles.emitting = true


func stop_ability_preview_particles() -> void :
    for partricles in ability_preview_particles:
        partricles.emitting = false


func _on_animated_texture_timer_timeout() -> void :
    (enemy_texture_rect.texture as AtlasTexture).region.position.y += 64
    (enemy_texture_rect.texture as AtlasTexture).region.position.y = wrapi((enemy_texture_rect.texture as AtlasTexture).region.position.y, 0, texture_size.y)
