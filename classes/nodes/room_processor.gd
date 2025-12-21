class_name RoomProcessor extends GameplayComponent


var action_container: Control


func initialize() -> void :
    return


func _ready() -> void :
    if is_instance_valid(memory.room_type.action_container_scene):
        action_container = memory.room_type.action_container_scene.instantiate()
        room_screen.room_action_container_holder.add_child(action_container)
        tree_exiting.connect( func(): action_container.queue_free())



func _process(_delta: float) -> void :
    room_screen.hide_all_bottom_containers()
