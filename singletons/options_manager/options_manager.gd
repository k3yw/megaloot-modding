extends Node

signal options_loaded

const OPTIONS_FILE_PATH: String = "user://options.txt"

var music_bus_idx: int = AudioServer.get_bus_index("Music")
var sfx_bus_idx: int = AudioServer.get_bus_index("SFX")
var world_environment: WorldEnvironment

var options = Options.new()
var is_loaded: bool = false

var default_bindings: Array[Array] = []
var listening_to_key: String = ""




func _ready() -> void :
    for action_name in Options.BINDINGS:
        default_bindings.push_back(InputMap.action_get_events(action_name))

    process_mode = ProcessMode.PROCESS_MODE_ALWAYS




func set_speedrun_api_key(api_key: String):
    options.speedrun_api_key = api_key
    save_options()



func set_window_mode(window_mode: int):
    options.window_mode = window_mode
    update_window_mode()

    save_options()





func set_music_volume(volume_db: float) -> void :
    options.music_volume_db = volume_db
    update_music()

    save_options()




func set_sfx_volume(volume_db: float) -> void :
    options.sfx_volume_db = volume_db
    update_sfx()

    save_options()


func set_tooltip_lock_time(amount: float) -> void :
    options.tooltip_lock_time = amount
    save_options()


func set_battle_speed(amount: float) -> void :
    options.battle_speed = amount
    save_options()



func set_v_sync(active: bool) -> void :
    options.v_sync = active
    update_v_sync()
    save_options()




func set_current_screen(current_screen: int) -> void :
    options.current_screen = current_screen
    save_options()







func update_window_mode() -> void :
    var curr_resolution: Vector2i = get_window().size

    match options.window_mode:
        WindowMode.Type.WINDOWED:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
            DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
            await set_resolution(curr_resolution)

        WindowMode.Type.BORDERLESS:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
            DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
            await set_resolution(curr_resolution)

        WindowMode.Type.FULLSCREEN:
            recenter_window()
            await get_tree().process_frame
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)




func set_resolution(new_resolution: Vector2i) -> void :
    var window: Window = get_window()

    new_resolution.x = maxi(new_resolution.x, Options.BASE_RESOLUTION.x)
    new_resolution.y = maxi(new_resolution.y, Options.BASE_RESOLUTION.y)

    window.size = new_resolution

    await get_tree().process_frame
    recenter_window()



func set_brightness_amount(amount: float) -> void :
    options.brightness = amount
    update_world_environment()
    save_options()


func set_contrast_amount(amount: float) -> void :
    options.contrast = amount
    update_world_environment()
    save_options()




func recenter_window() -> void :
    var window: Window = get_window()
    var screen_rect = DisplayServer.screen_get_usable_rect(window.current_screen)
    var window_size = window.get_size_with_decorations()
    var center = screen_rect.position + (screen_rect.size / 2 - window_size / 2)
    window.position = center

    window.current_screen = mini(DisplayServer.get_screen_count(), options.current_screen)





func set_key_bind(action_name: String, key: InputEvent):
    var type = InputMode.get_type(key)

    for action_event in InputMap.action_get_events(action_name):
        if type == InputMode.get_type(action_event):
            InputMap.action_erase_event(action_name, action_event)

    for input_action_name in InputMap.get_actions():
        for action_event in InputMap.action_get_events(input_action_name):
            if action_event.is_match(key):
                InputMap.action_erase_event(input_action_name, action_event)

    InputMap.action_add_event(action_name, key)

    match type:
        InputMode.Type.KEYBOARD: options.keyboard_input_map[action_name] = key
        InputMode.Type.JOYPAD: options.joypoad_input_map[action_name] = key




func reset_bindings() -> void :
    for action_name in Options.BINDINGS:
        for action_event in InputMap.action_get_events(action_name):
            InputMap.action_erase_event(action_name, action_event)

    for idx in default_bindings.size():
        var bindings = default_bindings[idx]


        for binding in bindings:
            set_key_bind(options.BINDINGS[idx], binding)

    save_options()





func update_world_environment() -> void :
    world_environment.environment.adjustment_brightness = options.brightness
    world_environment.environment.adjustment_contrast = options.contrast



func update_v_sync() -> void :
    if options.v_sync:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)



func update_music() -> void :
    AudioServer.set_bus_volume_db(music_bus_idx, options.music_volume_db)


func update_sfx() -> void :
    AudioServer.set_bus_volume_db(sfx_bus_idx, options.sfx_volume_db)



func save_options() -> void :
    options.save()



func load_options() -> void :
    SaveSystem.load_json(options, Options.get_save_path())


    for dict in [options.keyboard_input_map, options.joypoad_input_map]:
        for key in dict:
            if not typeof(dict[key]):
                continue

            var input_str: PackedStringArray = dict[key].split(": ")
            if not ["InputEventKey", "InputEventJoypadButton", "InputEventJoypadMotion"].has(input_str[0]):
                continue

            var input_event = Classes.instance_from_string(dict[key])

            set_key_bind(key, input_event)




    options.update_input_map()
    update_world_environment()
    update_v_sync()
    update_music()
    update_sfx()

    await update_window_mode()
    is_loaded = true

    options_loaded.emit()
