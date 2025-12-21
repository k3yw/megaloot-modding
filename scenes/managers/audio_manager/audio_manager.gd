extends Node2D

@export var music_player_priority: Array[AudioStreamPlayer] = []

var audio_stream_player_stack: Array[GenericAudioStreamPlayer] = []
var event_stack: Array[ToneEventResource] = []
var cooldowns: Array[ToneEvent] = []
var last_idx: int = 0

var curr_state_name: String = ""
var music_tween: Tween





func _ready() -> void :
    StateManager.state_changed.connect(_on_state_changed)
    for music_player in music_player_priority:
        music_player.volume_db = linear_to_db(0.0)


func _on_state_changed() -> void :
    curr_state_name = StateManager.get_current_state().name



func _process(delta: float) -> void :
    process_state_change()
    process_tone_events()

    for idx in range(cooldowns.size() - 1, -1, -1):
        var cd_event: ToneEvent = cooldowns[idx]

        if not is_instance_valid(cd_event):
            continue

        cd_event.cooldown -= delta

        if cd_event.cooldown <= 0:
            cooldowns.remove_at(idx)







func process_tone_events() -> void :
    for adventurer_tree_node in NodeManager.adventurer_tree_nodes:
        if adventurer_tree_node.is_pressed:
            var tone_event: ToneEventResource = ToneEventResource.new()
            var tone: Tone = Tone.new(preload("res://assets/sfx/ui/rune_select.wav"), 5)
            tone_event.space_type = ToneEventResource.SpaceType._2D
            tone_event.position = adventurer_tree_node.get_screen_position()
            tone_event.tones.push_back(tone)
            tone_event.stackable = true
            tone.pitch_min = 1.05
            tone.pitch_max = 1.05

            AudioManager.play_event(tone_event, StateManager.get_current_state().name)



    for generic_button in NodeManager.generic_buttons:
        if generic_button.just_hovered:
            var tone_event: ToneEventResource = ToneEventResource.new()
            var tone: Tone = Tone.new(preload("res://assets/sfx/button_hover.wav"), -6)
            tone_event.space_type = ToneEventResource.SpaceType._2D
            tone_event.position = generic_button.get_screen_position()
            tone_event.tones.push_back(tone)
            tone_event.stackable = true
            tone.pitch_min = 1.05
            tone.pitch_max = 1.05

            AudioManager.play_event(tone_event, StateManager.get_current_state().name)

        if generic_button.is_pressed:
            var tone_event: ToneEventResource = ToneEventResource.new()
            var tone: Tone = Tone.new(preload("res://assets/sfx/button_press.wav"), 2.45)
            tone_event.space_type = ToneEventResource.SpaceType._2D
            tone_event.position = generic_button.get_screen_position()
            tone_event.tones.push_back(tone)
            tone_event.stackable = true
            tone.pitch_min = 0.93
            tone.pitch_max = 1.08
            AudioManager.play_event(tone_event, StateManager.get_current_state().name)






func play_sfx_at(audio_stream: AudioStream, at: Vector2, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void :
    var tone_event: ToneEventResource = ToneEventResource.new()
    var tone = Tone.new(audio_stream, volume_db)
    tone_event.space_type = ToneEventResource.SpaceType._2D
    tone_event.stackable = true
    tone_event.position = at
    tone_event.tones.push_back(tone)
    tone.pitch_min = pitch_scale
    tone.pitch_max = pitch_scale
    play_event(tone_event, name)








func play_event(event_resource: ToneEventResource, state_name: String) -> void :
    if not event_resource.tones.size():
        return


    if event_stack.has(event_resource) and not event_resource.stackable:
        return

    for cd_event in cooldowns:
        if not is_instance_valid(cd_event):
            continue

        if cd_event.resource == event_resource:
            return


    event_stack.push_back(event_resource)


    var delay: float = randf_range(event_resource.delay_min, maxf(event_resource.delay_max, event_resource.delay_min))
    if delay > 0.0:
        await get_tree().create_timer(delay).timeout

    var event = ToneEvent.new(event_resource)
    cooldowns.push_back(event)

    var sfx_player: GenericAudioStreamPlayer = preload("res://scenes/objects/generic_audio_stream_player/generic_audio_stream_player.tscn").instantiate()

    var rand_idx: int = randi() % event_resource.tones.size() - 1

    if rand_idx == last_idx:
        rand_idx = mini(rand_idx + 1, event_resource.tones.size() - 1)

    var tone: Tone = event_resource.tones[rand_idx]
    last_idx = rand_idx
    sfx_player.stream = tone.audio
    sfx_player.origin_state_name = state_name
    sfx_player.original_volume_db = tone.volume_db

    sfx_player.pitch_scale = randf_range(tone.pitch_min, maxf(tone.pitch_min, tone.pitch_max))


    sfx_player.bus = "SFX"


    sfx_player.position = get_viewport_rect().size * 0.5
    if event_resource.space_type == ToneEventResource.SpaceType._2D:
        sfx_player.position = event_resource.position



    audio_stream_player_stack.push_back(sfx_player)
    add_child(sfx_player)


    sfx_player.finished.connect(_on_sfx_player_finished.bind(event, sfx_player))





func play_music(music: Music) -> void :
    if music.stream == music_player_priority[0].stream:
        return

    if music.delay:
        await get_tree().create_timer(music.delay).timeout

    if is_instance_valid(music_tween):
        music_tween.kill()


    var play_pos: float = 0.0
    if music.sync:
        play_pos = music_player_priority[0].get_playback_position()

    music_player_priority.reverse()

    music_tween = create_tween().set_parallel(music.crossfade)
    music_tween.tween_method(interpolate_volume, Vector2(1, 1.0), Vector2(1, 0.0), music.fade_speed)
    music_tween.tween_method(interpolate_volume, Vector2(0, 0.0), Vector2(0, 1.0), music.fade_speed)


    music_player_priority[0].stream = music.stream
    music_player_priority[0].play(play_pos)





func interpolate_volume(data: Vector2) -> void :
    music_player_priority[data.x].volume_db = linear_to_db(data.y)




func process_state_change() -> void :
    for child in get_children():
        if child is GenericAudioStreamPlayer:
            if child.origin_state_name == curr_state_name:
                child.fade_out = false
                continue

            child.fade_out = true




func _on_sfx_player_finished(tone_event: ToneEvent, sfx_player: GenericAudioStreamPlayer) -> void :
    audio_stream_player_stack.erase(sfx_player)
    event_stack.erase(tone_event.resource)
    sfx_player.queue_free()
    tone_event.free()
