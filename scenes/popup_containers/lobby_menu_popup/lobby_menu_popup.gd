@tool
class_name LobbyMenuPopup extends PopupContainer



@export var confirm_buttom: GenericButton
@export var name_line_edit: GenericLineEdit
@export var password_line_edit: GenericLineEdit
@export var connection_type_drop_down: GenericDropDown
@export var connection_type_container: VBoxContainer
@export var game_mode_drop_down: GenericDropDown
@export var public_toggle_button: GenericToggleButton
@export var public_toggle_option: ToggleOption



func _ready() -> void :
    super._ready()
    confirm_buttom.pressed.connect( func(): hide())
    Lobby.data_reset.connect(update)

    visibility_changed.connect( func():
        if visible:
            update()
        )

    connection_type_container.visible = ISteam.is_active()


func _process(_delta: float) -> void :
    if Engine.is_editor_hint():
        return
    password_line_edit.disabled = [Lobby.Type.STEAM, Lobby.Type.MANUAL].has(connection_type_drop_down.selected_idx)
    public_toggle_option.visible = not connection_type_drop_down.selected_idx == Lobby.Type.MANUAL
    container.size.y = 0


func update() -> void :
    connection_type_drop_down.selected_idx = Lobby.data.type
    public_toggle_button.button_pressed = Lobby.is_public
    name_line_edit.line_edit.text = Lobby.custom_name
    game_mode_drop_down.selected_idx = 0
