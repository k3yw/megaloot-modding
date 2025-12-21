@tool
class_name ChatButton extends GenericButton



@export var label_container: MarginContainer
@export var amount_label: GenericLabel
var loot_stash_open: bool = false


func _ready() -> void :
    Net.message_received.connect( func(_sender_id: int, _message: String): amount_label.target_value += 1)


func _process(delta: float) -> void :
    super._process(delta)

    if Engine.is_editor_hint():
        return

    label_container.visible = amount_label.target_value
