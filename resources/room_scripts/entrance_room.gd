extends RoomProcessor



func _ready() -> void :
    gameplay_state.pressed_primary_action.connect(_on_pressed_primary_action)
    action_container = room_screen.interaction_container


func _on_pressed_primary_action(_forced: bool) -> void :
    if canvas_layer.screen_transition.animation_player.is_playing():
        return

    MultiplayerManager.enter_tower()



func _process(delta: float) -> void :
    super._process(delta)

    action_container.show()

    room_screen.interact_button.text = T.get_translated_string("enter").to_upper()
    room_screen.interact_button.disabled = canvas_layer.screen_transition.animation_player.is_playing()
