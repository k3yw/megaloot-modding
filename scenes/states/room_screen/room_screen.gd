class_name RoomScreen extends MarginContainer

@export_group("Viewport")
@export var battle_viewport: SubViewportContainer
@export var world_camera: Camera3D
@export var camera: BattleCamera
@export var environment_animation_player: AnimationPlayer
@export var enemy_container_holder: EnemyContainerHolder
@export var screen_flash_effect: ScreenFlashEffect
@export var camera_3d_animation_player: AnimationPlayer
@export var shard_emitter: ShardEmitter
@export var room: Node3D

@export_group("")
@export var partner_container_holder: PartnerContainerHolder

@export var room_action_container_holder: MarginContainer

@export var battle_speed_container: BattleSpeedContainer

@export var interaction_container: HBoxContainer
@export var interact_button: GenericButton



@export_group("")
@export var turn_label: GenericLabel
@export var turn_timer: TurnTimer

@export var ping_texture_rect: PingTextureRect
@export var options_button: GenericButton



var confused: bool = false




func _process(delta: float) -> void :
    var enemy_container_holder_scale = 1 + (abs(world_camera.position.z - 2.75) * 0.5)
    enemy_container_holder.scale = Vector2(enemy_container_holder_scale, enemy_container_holder_scale)
    enemy_container_holder.visible = enemy_container_holder.scale < Vector2(3, 3)


    process_confusion_effect(delta)



func shatter() -> void :
    await shard_emitter.shatter()
    update_room(Rooms.FOREST_ROOM)

    var tone_event: ToneEventResource = ToneEventResource.new()
    var tone = Tone.new(preload("res://assets/sfx/reality_destruction.wav"), 7.5)
    tone_event.tones.push_back(tone)
    AudioManager.play_event(tone_event, name)

    screen_flash_effect.flash()




func update_room(room_type: RoomResource) -> void :
    var new_room: PackedScene = room_type.scene
    var last_room: Node3D = room.get_child(0)
    room.remove_child(last_room)
    if is_instance_valid(last_room):
        last_room.queue_free()

    enemy_container_holder.h_seperation = room_type.enemy_h_seperation
    room.add_child(new_room.instantiate())



func process_confusion_effect(delta: float) -> void :
    var curr_value: float = (battle_viewport.material as ShaderMaterial).get_shader_parameter("intensity")

    if confused and curr_value <= 1.0:
        (battle_viewport.material as ShaderMaterial).set_shader_parameter("intensity", lerp(curr_value, 1.0, 2.5 * delta))
        return

    if not confused and curr_value >= 0.0:
        (battle_viewport.material as ShaderMaterial).set_shader_parameter("intensity", lerp(curr_value, 0.0, 2.5 * delta))
        return



func set_confusion(arg_confused: bool) -> void :
    confused = arg_confused

    if confused:
        (battle_viewport.material as ShaderMaterial).set_shader_parameter("intensity", 1.0)
        return

    if not confused:
        (battle_viewport.material as ShaderMaterial).set_shader_parameter("intensity", 0.0)





func get_enemy_container(idx: int) -> EnemyContainer:
    if idx > enemy_container_holder.get_child_count() - 1:
        return null

    return enemy_container_holder.get_child(idx)




func play_enemy_attack(idx: int, speed: float):
    var enemy_container: EnemyContainer = get_enemy_container(idx)
    enemy_container.animation_player.play("enemy_attack", -1, speed)

    if enemy_container.animation_player.is_playing():
        await enemy_container.animation_player.animation_finished






func play_player_attack(idx: int, speed: float):
    var enemy_container: EnemyContainer = get_enemy_container(idx)
    if not is_instance_valid(enemy_container):
        return

    enemy_container.animation_player.play("player_attack", -1, speed)

    if enemy_container.animation_player.is_playing():
        await enemy_container.animation_player.animation_finished




func get_bottom_containers() -> Array[Control]:
    return [
        interaction_container, 
    ]


func hide_all_bottom_containers() -> void :
    for bottom_container in get_bottom_containers():
        bottom_container.hide()
