extends RoomProcessor


var has_actions: bool = true




func _process(delta: float) -> void :
    action_container = action_container as EndlessMonolithActionContainer
    super._process(delta)

    action_container.activate_button.disabled = memory.local_player.left_room
    action_container.leave_button.disabled = memory.local_player.left_room

    if memory.local_player.left_room:
        return

    if not has_actions:
        return

    if action_container.activate_button.is_pressed:
        MultiplayerManager.send_room_action(Lobby.get_client_id(), RoomAction.Type.ACTIVATE_ENDLESS, memory.get_floor_state())
        action_container.activate_button.disabled = true
        has_actions = false


    if action_container.leave_button.is_pressed:
        MultiplayerManager.leave_room()
        has_actions = false
