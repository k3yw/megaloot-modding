class_name Main extends Node

const CONTENT_CSV_FILE_NAME: String = "content.csv"

@export var debug_canvas_layer: DebugCanvasLayer
@export var main_canvas_layer: MainCanvasLayer
@export var viewport_container: SubViewportContainer
@export var sub_viewport: SubViewport
@export var scan_lines_texture_rect: TextureRect
@export var world_environment: WorldEnvironment
@export var fps_label: GenericLabel

@onready var script_method_list: Array[Dictionary] = get_method_list()
@onready var window: Window = get_window()



var commands: Array[Callable] = [
    encounter_all, 
    toggle_fps, 
    print_here, 

    set_partner_steam_id, 
    test, 
    generate_temp_id, 
    get_partner_ids, 
    fix_coop_memories, 

    gms_set_extra_item_set, 
    gms_complete_floor, 
    gms_change_floor, 
    gms_apply_timeout, 
    gms_add_set_items, 
    gms_create_insightus, 
    gms_add_status_effect, 
    gms_recieve_damage, 
    gms_add_diamonds, 
    gms_add_stat, 
    gms_add_item, 
    gms_drop_items, 
    gms_drop_item, 
    gms_polymorph, 
    gms_add_gold, 
    gms_shatter, 
    gms_die, 
    ]


var last_inout_mode: InputMode.Type = InputMode.Type.KEYBOARD
var last_window_size: Vector2i
var last_window_pos: Vector2i



func _init() -> void :
    var path: String = File.get_user_file_dir()
    var dir_access = DirAccess.open(path)

    if not is_instance_valid(dir_access):
        DirAccess.make_dir_recursive_absolute(path)



func _ready():
    Input.joy_connection_changed.connect(_on_joy_connection_changed)
    HoverInfoManager.call_deferred("reparent", sub_viewport)
    PopupManager.call_deferred("reparent", sub_viewport)
    StateManager.call_deferred("reparent", sub_viewport)
    OptionsManager.world_environment = world_environment
    StateManager.state_changed.connect(_on_state_changed)
    JoypadManager.main_canvas_layer = main_canvas_layer

    create_content_csv()
    load_options()
    CursorManager.update_cursor()

    fix_rendering()





func _on_joy_connection_changed(_device: int, _connected: bool) -> void :
    CursorManager.update_cursor()



func _on_state_changed() -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        curr_state.game_ended.connect(_on_game_ended.bind(curr_state))




func _on_game_ended(winner: Team.Type, gameplay_state: GameplayState) -> void :
    var death_screen: DeathScreen = gameplay_state.death_screen
    var memory: Memory = gameplay_state.memory
    var battle: Battle = memory.battle
    var enemy_idx: int = -1

    UserData.active_memory_slot_idx = -1

    var popup_battle_log: BattleLogTabContainer = PopupManager.battle_log_popup_container.battle_log_container
    popup_battle_log.copy_log(gameplay_state.canvas_layer.battle_log_tab_container)
    popup_battle_log.current_turn_page = popup_battle_log.battle_log_pages.size()

    death_screen.set_highest_floor(UserData.profile.get_floor_record(gameplay_state.memory.local_player.adventurer))
    death_screen.set_death_floor(gameplay_state.memory.floor_number)

    if not winner == Team.Type.NULL:
        death_screen.show_win_result(gameplay_state.memory.local_player.team == winner)

    if memory.is_endless == false and memory.floor_number >= memory.game_mode.last_floor:
        death_screen.show_final_floor()

    death_screen.animate_show()





func _process(_delta):
    var input_mode: InputMode.Type = InputMode.get_active_type()
    var window_pos: Vector2i = window.position
    var window_size: Vector2i = window.size


    if not window_size == last_window_size:
        on_window_size_changed()

    if not last_inout_mode == input_mode:
        update_option_keybind_buttons()



    CursorManager.fake_cursor_texture_rect.visible = false
    if is_instance_valid(UI.hovered_node):
        CursorManager.fake_cursor_texture_rect.global_position = UI.get_rect(UI.hovered_node).get_center().round()
        CursorManager.fake_cursor_texture_rect.visible = Input.mouse_mode == Input.MOUSE_MODE_HIDDEN


    process_loading_content_visuals()

    update_fps_label()
    process_console()

    process_esc_menu_screen()
    process_options_screen()
    process_current_state()


    CursorManager.fake_cursor_texture_rect.update()
    last_window_size = window_size
    last_inout_mode = input_mode

    var viewport = get_viewport()
    if viewport.get_visible_rect().has_point(viewport.get_mouse_position()):

        if not window_pos == last_window_pos:
            on_window_position_changed()

        last_window_pos = window_pos





func _input(event: InputEvent) -> void :
    var curr_state: Node = StateManager.get_current_state()


    if curr_state is IntroState:
        if StateManager.is_busy():

            return
        if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
            StateManager.change_to_main_menu_state(false)


    if not OptionsManager.listening_to_key.length():
        return


    if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
        if event is InputEventJoypadButton:
            if not event.pressed:
                return

        if event is InputEventKey:
            if not event.pressed:
                return

        if event is InputEventJoypadMotion:
            if is_equal_approx(roundf(event.axis_value * 10) / 10.0, 0.0):
                return

        OptionsManager.set_key_bind(OptionsManager.listening_to_key, event)
        OptionsManager.listening_to_key = ""
        OptionsManager.save_options()

        update_option_keybind_buttons()






func on_window_size_changed() -> void :
    if not OptionsManager.is_loaded:
        return

    var options_screen = main_canvas_layer.options_screen
    var resolution_option: DropDownOption = options_screen.resolution_option

    OptionsManager.options.resolution = [get_window().size.x, get_window().size.y]
    resolution_option.drop_down.selected_idx = resolution_option.drop_down.selections.find(str(get_window().size))

    OptionsManager.save_options()
    CursorManager.update_cursor()




func on_window_position_changed() -> void :
    if not OptionsManager.is_loaded:
        return

    var new_current_screen = DisplayServer.window_get_current_screen()

    if OptionsManager.options.current_screen == new_current_screen:
        return

    OptionsManager.set_current_screen(new_current_screen)
    main_canvas_layer.options_screen.update_resolutions()




func load_options() -> void :
    var language: String = Platform.get_language()
    OptionsManager.load_options()

    if not OptionsManager.options.window_mode == WindowMode.Type.FULLSCREEN:
        OptionsManager.set_resolution(Vector2i(OptionsManager.options.resolution[0], OptionsManager.options.resolution[1]))

    set_chromatic_aberration(OptionsManager.options.chromatic_aberration)
    set_tooltip_lock_time(OptionsManager.options.tooltip_lock_time)
    set_scan_lines(OptionsManager.options.scan_lines)


    if language.is_empty() or language == "english":
        language = T.languages[OptionsManager.options.current_language]

    T.set_locale(language)



    update_option_keybind_buttons()











func process_esc_menu_screen() -> void :
    var esc_menu_screen: EscMenuScreen = main_canvas_layer.esc_menu_screen
    var curr_state: Node = StateManager.get_current_state()
    var are_buttons_disabled: bool = buttons_disabled()

    esc_menu_screen.restart_button.text = T.get_translated_string("restart", "Button").to_upper()

    esc_menu_screen.save_and_exit_button.disabled = are_buttons_disabled
    esc_menu_screen.resume_button.disabled = are_buttons_disabled
    esc_menu_screen.restart_button.disabled = are_buttons_disabled
    esc_menu_screen.library_button.disabled = are_buttons_disabled
    esc_menu_screen.options_button.disabled = are_buttons_disabled

    if curr_state is GameplayState:
        if curr_state.memory.partners.size() > 0:
            esc_menu_screen.restart_button.disabled = true

    if are_buttons_disabled:
        return

    if esc_menu_screen.options_button.is_pressed:
        toggle_options()

    if Input.is_action_just_pressed("esc"):
        toggle_esc_menu()

    if esc_menu_screen.resume_button.is_pressed:
        toggle_esc_menu()

    if esc_menu_screen.library_button.is_pressed:
        StateManager.screen_transition.animation_player.play("transition_start")
        await StateManager.screen_transition.animation_player.animation_finished
        StateManager.add_child(StateManager.create_library_state())
        StateManager.screen_transition.animation_player.play("transition_end")
        esc_menu_screen.hide()
        return

    if curr_state is GameplayState:
        var room_screen: RoomScreen = curr_state.canvas_layer.room_screen
        if room_screen.options_button.is_pressed:
            toggle_esc_menu()




func toggle_esc_menu() -> void :
    await get_tree().process_frame

    var esc_menu_screen: EscMenuScreen = main_canvas_layer.esc_menu_screen
    var options_screen = main_canvas_layer.options_screen
    var curr_state: Node = StateManager.get_current_state()

    if options_screen.visible:
        return

    if is_instance_valid(NodeManager.library_state):
        return

    if curr_state is GameplayState:
        esc_menu_screen.visible = not esc_menu_screen.visible
        curr_state.canvas_layer.visible = not esc_menu_screen.visible

        if esc_menu_screen.visible:
            var pressed_esc_event = ToneEventResource.new()
            pressed_esc_event.tones.push_back(Tone.new(preload("res://assets/sfx/ui_activation.wav"), -4.5))
            pressed_esc_event.stackable = true
            AudioManager.play_event(pressed_esc_event, curr_state.name)

            if InputMode.get_active_type() == InputMode.Type.JOYPAD:
                UI.hovered_node = esc_menu_screen.resume_button





func toggle_options():
    var esc_menu_screen: EscMenuScreen = main_canvas_layer.esc_menu_screen
    var options_screen = main_canvas_layer.options_screen
    var curr_state: Node = StateManager.get_current_state()
    options_screen.visible = not options_screen.visible


    if curr_state is GameplayState:
        if curr_state.memory.local_player.died:
            esc_menu_screen.visible = false
            return

        esc_menu_screen.visible = not options_screen.visible

    if curr_state is MainMenuState:
        curr_state.hide_main_canvas_layer = options_screen.visible








func update_option_keybind_buttons() -> void :
    var options_screen = main_canvas_layer.options_screen

    for child in options_screen.key_binding_button_container.get_children():
        if not child is KeyBindingButton:
            continue

        child = child as KeyBindingButton
        var action_events: Array[InputEvent] = InputMap.action_get_events(child.action_name)

        if not action_events.size():
            child.key_label.text = "\"" + "?" + "\""
            continue

        for action_event in action_events:
            if not InputMode.get_type(action_event) == InputMode.get_active_type():
                continue

            var key: String = (action_event as InputEvent).as_text()
            child.key_label.text = "\"" + key + "\""
            break

        child.listening_for_input_label.hide()
        child.key_info_container.show()
        if OptionsManager.listening_to_key == child.action_name:
            child.listening_for_input_label.show()
            child.key_info_container.hide()










func process_current_state():
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is IntroState:
        process_intro_state(curr_state)
        return

    if curr_state is MainMenuState:
        process_main_menu_state(curr_state)
        return

    if is_instance_valid(NodeManager.library_state):
        process_library_state(NodeManager.library_state)

    if curr_state is GameplayState:
        process_gameplay_state(curr_state)
        return




func fix_rendering() -> void :
    if not OS.get_cmdline_args().has("-opengl"):
        return

    world_environment.environment.background_mode = Environment.BG_CLEAR_COLOR






func process_options_screen() -> void :
    var options_screen = main_canvas_layer.options_screen
    var window_mode_option: DropDownOption = options_screen.window_mode_option
    var resolution_option: DropDownOption = options_screen.resolution_option
    var brightness_option: SliderOption = options_screen.brightness_option
    var contrast_option: SliderOption = options_screen.contrast_option
    var music_option: SliderOption = options_screen.music_option
    var sfx_option: SliderOption = options_screen.sfx_option
    var tooltip_lock_time_option: SliderOption = options_screen.tooltip_lock_time_option
    var language_option: DropDownOption = options_screen.language_option
    var chromatic_aberration_option: ToggleOption = options_screen.chromatic_aberration_option
    var display_run_time_option: ToggleOption = options_screen.display_run_time_option
    var screen_shake_option: ToggleOption = options_screen.screen_shake_option
    var scan_lines_option: ToggleOption = options_screen.scan_lines_option


    if chromatic_aberration_option.toggle_button.is_pressed:
        set_chromatic_aberration(chromatic_aberration_option.toggle_button.button_pressed)
        return

    if display_run_time_option.toggle_button.is_pressed:
        set_display_run_time_option(display_run_time_option.toggle_button.button_pressed)
        return

    if scan_lines_option.toggle_button.is_pressed:
        set_scan_lines(scan_lines_option.toggle_button.button_pressed)
        return

    if screen_shake_option.toggle_button.is_pressed:
        set_screen_shake(screen_shake_option.toggle_button.button_pressed)
        return

    if window_mode_option.drop_down.changed_selection:
        OptionsManager.set_window_mode(window_mode_option.drop_down.selected_idx)


    if resolution_option.drop_down.changed_selection:
        var supported_resolutions = Options.get_supported_resolutions()
        OptionsManager.set_resolution(supported_resolutions[resolution_option.drop_down.selected_idx])

        if OptionsManager.options.window_mode == WindowMode.Type.FULLSCREEN:
            OptionsManager.set_window_mode(WindowMode.Type.WINDOWED)


    if brightness_option.value_changed():
        OptionsManager.set_brightness_amount(brightness_option.h_slider.value * 0.01)

    if contrast_option.value_changed():
        OptionsManager.set_contrast_amount(contrast_option.h_slider.value * 0.01)

    if music_option.value_changed():
        OptionsManager.set_music_volume(linear_to_db(music_option.h_slider.value * 0.01))

    if sfx_option.value_changed():
        OptionsManager.set_sfx_volume(linear_to_db(sfx_option.h_slider.value * 0.01))

    if tooltip_lock_time_option.value_changed():
        set_tooltip_lock_time(tooltip_lock_time_option.h_slider.value)


    if language_option.drop_down.changed_selection:
        T.set_locale(T.languages[language_option.drop_down.selected_idx])


    if options_screen.back_button.is_pressed:
        toggle_options()



    for child in options_screen.key_binding_button_container.get_children():
        if not child is KeyBindingButton:
            continue

        child = child as KeyBindingButton

        if not child.is_pressed:
            continue

        OptionsManager.listening_to_key = child.action_name
        update_option_keybind_buttons()
        return


    if options_screen.reset_to_defaults_button.is_pressed:
        OptionsManager.reset_bindings()
        update_option_keybind_buttons()
        return





func set_chromatic_aberration(enabled: bool) -> void :
    var y: int = 0

    OptionsManager.options.chromatic_aberration = enabled
    if enabled:
        y = -1

    (viewport_container.material as ShaderMaterial).set_shader_parameter("b_displacement", Vector2(0, y))
    OptionsManager.save_options()



func set_display_run_time_option(enabled: bool) -> void :
    OptionsManager.options.display_run_time = enabled
    OptionsManager.save_options()


func set_scan_lines(enabled: bool) -> void :
    OptionsManager.options.scan_lines = enabled
    scan_lines_texture_rect.visible = enabled
    OptionsManager.save_options()



func set_screen_shake(enabled: bool) -> void :
    OptionsManager.options.screen_shake = enabled
    OptionsManager.save_options()


func set_tooltip_lock_time(amount: float) -> void :
    HoverInfoManager.hover_info_lock_time = amount
    OptionsManager.set_tooltip_lock_time(amount)















func update_fps_label() -> void :
    fps_label.text = str(Engine.get_frames_per_second())





func process_console() -> void :
    var input_commands: PackedStringArray = debug_canvas_layer.console_command_to_process.split(" ")
    var console_line_edit: LineEdit = debug_canvas_layer.console_input.line_edit
    var curr_state = StateManager.get_current_state()

    curr_state.set_process_input( not debug_canvas_layer.visible)

    if debug_canvas_layer.visible and Input.is_action_just_pressed("debug_auto_complete"):
        for command in commands:
            var command_name: String = String(command.get_method()).replace("_", "-")
            if not console_line_edit.text in command_name:
                continue

            if command_name == console_line_edit.text:
                continue

            for script_method in script_method_list:
                if script_method["name"] == String(command.get_method()):
                    for arg in script_method["args"]:
                        if arg["name"] == "item_name":
                            pass

            console_line_edit.text = command_name
            console_line_edit.caret_column = console_line_edit.text.length()
            return


    if not commands.size():
        return

    var callable_name: String = input_commands[0]
    input_commands.remove_at(0)


    var args: Array = []
    for input_command in input_commands:
        var fixed_input_command = input_command




        args.push_back(fixed_input_command)


    for command in commands:
        if not command.get_method() == StringName(callable_name.replace("-", "_")):
            continue

        command.callv(args)
        debug_canvas_layer.console_command_to_process = ""
        debug_canvas_layer.command_history.push_back(console_line_edit.text)
        console_line_edit.clear()
        break













































func print_here(what: String):
    var curr_state = StateManager.get_current_state()

    match what:
        "enemies-to-battle":
            if is_instance_valid(curr_state.memory.battle):
                debug_canvas_layer.push_result(var_to_str(curr_state.memory.battle.enemies_to_battle))






func encounter_all() -> void :
    UserData.profile.encountered_items = Items.LIST
    UserData.profile.encountered_enemies = Enemies.LIST

    debug_canvas_layer.push_result("encountered all")
    UserData.profile.save()



func toggle_fps() -> void :
    fps_label.visible = not fps_label.visible





func test() -> void :
    UserData.profile.test[Adventurers.FREN] = 1
    UserData.profile.save()


func set_partner_steam_id(partner_idx: String, steam_id: String) -> void :
    UserData.profile.memory.partners[int(partner_idx)].player_id = int(steam_id)
    debug_canvas_layer.push_result("partner steam id set: " + steam_id)




func generate_temp_id() -> void :
    UserData.profile.temp_id = UUID.v4()
    debug_canvas_layer.push_result("temp id generated")


func get_partner_ids() -> void :
    for partner in UserData.profile.memory.partners:
        debug_canvas_layer.push_result(str(partner.player_id))



func fix_coop_memories() -> void :
    for memory_slot in UserData.memory_slots:
        if not is_instance_valid(memory_slot):
            continue

        for partner in memory_slot.memory.partners:
            partner.profile_id = UserData.profile.id

        memory_slot.memory.local_player.profile_id = UserData.profile.get_id()


func gms_apply_timeout() -> void :
    var curr_state = StateManager.get_current_state()

    if curr_state is GameplayState:
        curr_state.memory.local_player.set_status_effect_amount(StatusEffects.TIMEOUT, 1)
        curr_state.update_all_ui()


func gms_set_extra_item_set(item_set_name: String) -> void :
    var curr_state = StateManager.get_current_state()

    if curr_state is GameplayState:
        for item_set in ItemSets.LIST:
            if item_set.name.to_lower().replace(" ", "-") == item_set_name.to_lower():
                debug_canvas_layer.push_result("extra item set changed")
                curr_state.memory.local_player.battle_profile.active_item_sets = [item_set] as Array[ItemSetResource]
                curr_state.memory.local_player.battle_profile.active_item_sets = [item_set] as Array[ItemSetResource]
                break


func gms_complete_floor() -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        var total_rooms: int = curr_state.memory.get_room_count()
        curr_state.advance(total_rooms - curr_state.memory.room_idx)
        debug_canvas_layer.push_result("completed floor")


func gms_change_floor(amount: String = "1") -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        curr_state.change_floor_number(int(amount), true)
        debug_canvas_layer.push_result("changed floor")



func gms_drop_items(amount: String = "1") -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        curr_state.drop_items(int(amount))


func gms_drop_item(amount: String = "1") -> void :
    var curr_state = StateManager.get_current_state()
    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState
    for i_ in int(amount):
        curr_state.drop_rand_item(Items.LIST, curr_state.ItemType.CHEST_DROP)




func gms_add_gold(amount: String = "10.0") -> void :
    var curr_state = StateManager.get_current_state()
    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    curr_state.character_manager.add_gold(float(amount))


func gms_add_diamonds(amount: String = "10.0") -> void :
    var curr_state = StateManager.get_current_state()
    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    curr_state.memory.local_player.change_diamonds(float(amount))



func gms_polymorph() -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        curr_state.polymorph(curr_state.memory.battle, curr_state.memory.battle.selected_enemy_idx)


func gms_add_set_items(item_set_name: String, rarity: String = "0") -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        for item in Items.LIST:
            for item_set in item.set_resources:
                if item_set.name.to_lower().replace(" ", "-") == item_set_name.to_lower():
                    debug_canvas_layer.push_result("item added")
                    curr_state.character_manager.add_item(item, int(rarity))
                    break




func gms_add_stat(stat_name: String, amount: String) -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        var local_player: Player = curr_state.memory.local_player
        for stat in Stats.LIST:
            if stat.name.to_lower().replace(" ", "-") == stat_name.to_lower():
                debug_canvas_layer.push_result("stat added")
                local_player.add_stat(local_player.stats, Stat.new([stat, float(amount)]))
                break



func gms_create_insightus() -> void :
    var curr_state = StateManager.get_current_state()
    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var insightus: Item = ItemManager.create_insightus(curr_state.memory.floor_number)
    curr_state.character_manager.add_loot(insightus)



func gms_add_item(item_name: String, rarity: String = "0") -> void :
    var curr_state = StateManager.get_current_state()
    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    for item in Items.LIST:
        if item.name.to_lower().replace(" ", "-") == item_name.to_lower():
            debug_canvas_layer.push_result("item added")
            curr_state.character_manager.add_item(item, int(rarity))
            break





func gms_add_status_effect(status_effect_name: String, amount: String = "0") -> void :
    var curr_state = StateManager.get_current_state()
    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var local_player: Player = curr_state.memory.local_player
    for status_effect in StatusEffects.LIST:
        if status_effect.name.to_lower().replace(" ", "-") == status_effect_name.to_lower():
            if local_player.try_to_add_status_effect(local_player, status_effect, float(amount)):
                debug_canvas_layer.push_result("status effect added")
                break

            print("failed adding: ", float(amount), " ", status_effect.name)
            break




func gms_shatter() -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        curr_state.canvas_layer.room_screen.shatter()


func gms_recieve_damage(amount: String) -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        var battle_processor = BattleProcesor.new(curr_state)
        var damage_data: DamageData = DamageData.new(DamageData.Source.ATTACK, Stats.PHYSICAL_ATTACK, float(amount))
        await battle_processor.try_to_damage_character(curr_state.memory.local_player, null, damage_data)
        battle_processor.cleanup()
        battle_processor.free()



func gms_die() -> void :
    var curr_state = StateManager.get_current_state()
    if curr_state is GameplayState:
        curr_state.memory.local_player.set_health(0)
        curr_state.memory.local_player.died = true







func process_loading_content_visuals():
    main_canvas_layer.loading_info.hide()
















func process_intro_state(intro_state: IntroState):
    if StateManager.is_busy():
        return

    if not intro_state.animation_player.is_playing() and not StateManager.is_busy():
        StateManager.change_to_main_menu_state(false)
        return





func process_main_menu_state(main_menu_state: MainMenuState):
    var options_screen = main_canvas_layer.options_screen

    if main_menu_state.options_button.is_pressed or Input.is_action_just_pressed("esc"):
        StateManager.finish_transition_end_animation()
        toggle_options()
        return

    if options_screen.visible:
        return

    if main_menu_state.credits_button.is_pressed:
        PopupManager.pop(PopupManager.credits_popup)
        return


    if main_menu_state.quit_button.is_pressed:
        main_canvas_layer.hide()
        await get_tree().process_frame
        get_tree().quit()







func process_gameplay_state(gameplay_state: GameplayState) -> void :
    var esc_menu: EscMenuScreen = main_canvas_layer.esc_menu_screen

    if StateManager.is_changing_state:
        return

    if esc_menu.save_and_exit_button.is_pressed:
        esc_menu.save_and_exit_button.disabled = true
        StateManager.change_to_main_menu_state(false)
        return


    if gameplay_state.death_screen.confirm_button.is_pressed:
        if is_instance_valid(gameplay_state.death_screen.killer):
            gameplay_state.death_screen.killer.free()
        return










func process_library_state(library_state: LibraryState) -> void :
    if StateManager.is_changing_state:
        return

    if library_state.back_button.is_pressed:
        if StateManager.get_current_state() is GameplayState:
            StateManager.screen_transition.animation_player.play("transition_start")
            await StateManager.screen_transition.animation_player.animation_finished
            library_state.queue_free()
            StateManager.screen_transition.animation_player.play("transition_end")
            toggle_esc_menu()
            return

        StateManager.finish_transition_end_animation()
        StateManager.change_to_main_menu_state(true)
        return







func buttons_disabled() -> bool:
    return StateManager.is_changing_state





func create_content_csv() -> void :
    var file = FileAccess.open(File.get_file_dir() + "/" + CONTENT_CSV_FILE_NAME, FileAccess.WRITE)
    var csv_data: String = ""


    csv_data += "Stats"
    csv_data += "\n" + "Name,Value,Growth"

    for stat_resource in Stats.LIST:
        csv_data += "\n" + stat_resource.name + ","

    csv_data += "\n\nItems"
    csv_data += "\n" + "Name,Set,Price,Market Level,Stats"

    for item in Items.LIST:
        csv_data += "\n" + item.name + ","

        for set_resource in item.set_resources:
            csv_data += set_resource.name
            csv_data += " + "

        csv_data = csv_data.rstrip(" + ")
        csv_data += ","

        csv_data += str(item.get_price())
        csv_data += ","

        csv_data += str(item.spawn_floor)
        csv_data += ","

        for stat in item.bonus_stats:
            csv_data += stat.resource.name + ": "
            csv_data += str(stat.amount)
            csv_data += "   "

    csv_data.rstrip(",")



    csv_data += "\n\nEnemies"
    csv_data += "\n" + "Name, Spawn Floor, Stats"

    for enemy in Enemies.LIST:
        csv_data += "\n" + enemy.name + ","
        csv_data += str(enemy.floor_number + 1) + ","

        for stat in enemy.base_stats:
            csv_data += stat.resource.name + ": "
            csv_data += str(stat.amount)
            csv_data += "   "


    csv_data.rstrip(",")



    csv_data += "\n\nAbilities"
    csv_data += "\n" + "Name"

    for ability in Abilities.LIST:
        csv_data += "\n" + ability.name + ","

    csv_data.rstrip(",")


    csv_data += "\n\nStatus Effects"
    csv_data += "\n" + "Name"

    for status_effect in StatusEffects.LIST:
        csv_data += "\n" + status_effect.name + ","

    csv_data.rstrip(",")



    csv_data += "\n\nAdventurers"
    csv_data += "\n" + "Name, Gold Gain, Stats"

    for adventurer in Adventurers.LIST:
        if is_instance_valid(adventurer):
            csv_data += "\n" + adventurer.name + ","

            for stat in adventurer.bonus_stats:
                csv_data += stat.resource.name + ": "
                csv_data += str(stat.amount)
                csv_data += "   "


    csv_data += "\n\nSpecializations"
    csv_data += "\n" + "Name"

    for item_set in Specializations.LIST:
        var specialization_arr: Array[Specialization] = Specializations.LIST[item_set].arr
        for specialization in specialization_arr:
            if is_instance_valid(specialization):
                csv_data += "\n" + specialization.name + ","


    csv_data += "\n\nStats"
    csv_data += "\n" + "Name, Gold Gain, Amount"


    file.store_string(csv_data)
    file.close()







func _on_debug_canvas_layer_visibility_changed() -> void :
    if debug_canvas_layer.visible:
        var filter: Array[Control] = []

        for child in NodeUtils.get_all_children(debug_canvas_layer, []):
            if child is Control:
                filter.push_back(child)

        UI.add_meta(self, filter, UI.CONSOLE_COVERED)

        return

    UI.remove_meta_from_all(self, UI.CONSOLE_COVERED)
