extends RoomProcessor








func _process(delta: float) -> void :
    action_container = action_container as FinalRoomActionContainer
    super._process(delta)

    action_container.end_button.pressing = Input.is_action_pressed("primary_action")

    if action_container.enter_endless_button.is_pressed:
        MultiplayerManager.send_room_action(Lobby.get_client_id(), RoomAction.Type.ACTIVATE_ENDLESS, memory.get_floor_state())

    if action_container.end_button.is_pressed:
        MultiplayerManager.send_room_action(Lobby.get_client_id(), RoomAction.Type.END_GAME, memory.get_floor_state())


    action_container.visible = true
    if gameplay_state.memory.is_game_ended or gameplay_state.memory.is_endless:
        action_container.visible = false
