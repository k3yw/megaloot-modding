extends Node




func _ready() -> void :
    process_mode = ProcessMode.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void :
    if not OS.is_debug_build():
        return

    if event is InputEventKey:
        if Input.is_action_just_pressed("pause"):
            get_tree().paused = not get_tree().paused






func _process(_delta: float) -> void :
    var curr_state: Node = StateManager.get_current_state()
    get_tree().paused = false

    if curr_state is GameplayState:
        if Lobby.data.players.size() < 2:
            get_tree().paused = not curr_state.canvas_layer.visible
