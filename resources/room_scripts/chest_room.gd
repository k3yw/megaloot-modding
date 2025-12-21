extends RoomProcessor

var has_actions: bool = true



func _ready() -> void :
    super._ready()
    action_container = action_container as ChestRoomActionContainer
    gameplay_state.pressed_primary_action.connect( func(forced: bool): open_chest())



func _process(delta: float) -> void :
    super._process(delta)

    action_container = action_container as ChestRoomActionContainer
    action_container.open_chest_button.disabled = memory.local_player.left_room

    if not has_actions:
        action_container.open_chest_button.disabled = true

    if is_instance_valid(memory.battle) and memory.battle.completed:
        return

    if not has_actions:
        return

    if action_container.open_chest_button.is_pressed:
        open_chest()


func open_chest() -> void :
    MultiplayerManager.send_room_action(Lobby.get_client_id(), RoomAction.Type.OPEN_CHEST, memory.get_floor_state())
    action_container.open_chest_button.disabled = true
    has_actions = false
