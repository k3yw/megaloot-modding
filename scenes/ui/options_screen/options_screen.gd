class_name OptionsScreen extends MarginContainer

@export var key_binding_button_container: VBoxContainer
@export var user_folder_button: TabButton

@export var window_mode_option: DropDownOption
@export var resolution_option: DropDownOption
@export var brightness_option: SliderOption
@export var contrast_option: SliderOption
@export var language_option: DropDownOption

@export var v_sync_option: ToggleOption

@export var music_option: SliderOption
@export var sfx_option: SliderOption

@export var tooltip_lock_time_option: SliderOption

@export var chromatic_aberration_option: ToggleOption
@export var display_run_time_option: ToggleOption
@export var screen_shake_option: ToggleOption
@export var scan_lines_option: ToggleOption

@export var tab_container: GenericTabContainer
@export var controls_tab_button: TabButton

@export var reset_to_defaults_button: GenericButton
@export var back_button: GenericButton





func _ready() -> void :
    OptionsManager.options_loaded.connect(_on_options_loaded)
    hide()

    update_key_bind_buttons()
    update_resolutions()

    for lang in T.languages:
        language_option.drop_down.add_selection(T.translations["language-name-text"][lang])

    v_sync_option.toggle_button.pressed.connect( func():
        OptionsManager.set_v_sync(v_sync_option.toggle_button.button_pressed)
        )


func _on_options_loaded() -> void :
    chromatic_aberration_option.toggle_button.button_pressed = OptionsManager.options.chromatic_aberration
    display_run_time_option.toggle_button.button_pressed = OptionsManager.options.display_run_time
    screen_shake_option.toggle_button.button_pressed = OptionsManager.options.screen_shake
    scan_lines_option.toggle_button.button_pressed = OptionsManager.options.scan_lines
    music_option.h_slider.value = db_to_linear(OptionsManager.options.music_volume_db) * 100
    sfx_option.h_slider.value = db_to_linear(OptionsManager.options.sfx_volume_db) * 100
    tooltip_lock_time_option.h_slider.value = OptionsManager.options.tooltip_lock_time
    v_sync_option.toggle_button.button_pressed = OptionsManager.options.v_sync
    brightness_option.h_slider.value = OptionsManager.options.brightness * 100
    contrast_option.h_slider.value = OptionsManager.options.contrast * 100

    language_option.drop_down.selected_idx = OptionsManager.options.current_language
    window_mode_option.drop_down.selected_idx = OptionsManager.options.window_mode



func update_key_bind_buttons() -> void :
    for child in key_binding_button_container.get_children():
        key_binding_button_container.remove_child(child)
        child.queue_free()

    for binding in Options.BINDINGS:
        var key_binding_button: KeyBindingButton = preload("res://scenes/ui/key_binding_button/key_binding_button.tscn").instantiate()
        key_binding_button.action_name = binding
        key_binding_button_container.add_child(key_binding_button)



func update_resolutions() -> void :
    var supported_resolutions = Options.get_supported_resolutions()
    resolution_option.drop_down.clear_selections()

    for index in supported_resolutions.size():
        var resolution = supported_resolutions[index]
        resolution_option.drop_down.add_selection(str(resolution))




func _process(_delta: float) -> void :
    if Input.is_action_just_pressed("press"):
        if UI.is_hovered(user_folder_button):
            OS.shell_open(File.get_user_file_dir())

    reset_to_defaults_button.visible = tab_container.current_tab == tab_container.tab_buttons.find(controls_tab_button)
