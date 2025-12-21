@tool
class_name AdventurerSelectionPopup extends PopupContainer


@export var card_holder: GridContainer

var adventurers: Array[Adventurer]


func _ready() -> void :
    adventurers = Adventurers.get_list()
    update_cards()


func _process(delta: float) -> void :
    super._process(delta)

    if Engine.is_editor_hint():
        return



func update_cards() -> void :
    for child in card_holder.get_children():
        card_holder.remove_child(child)
        child.queue_free()


    for adventurer in adventurers:
        var card_container: AdventurerTreeNode = preload("res://scenes/ui/adventurer_tree_node/adventurer_tree_node.tscn").instantiate()
        card_container.custom_minimum_size = Vector2(54, 54)
        card_container.hover_info_module.data = [adventurer]
        card_holder.add_child(card_container)
        card_container.update_icon_texture(adventurer)
