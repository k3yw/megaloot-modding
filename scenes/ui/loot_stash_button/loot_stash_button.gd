@tool
class_name LootStashButton extends GenericButton



@export var label_container: MarginContainer
@export var amount_label: GenericLabel
var loot_stash_open: bool = false



func _process(delta: float) -> void :
    super._process(delta)

    if Engine.is_editor_hint():
        return

    label_container.visible = amount_label.target_value
