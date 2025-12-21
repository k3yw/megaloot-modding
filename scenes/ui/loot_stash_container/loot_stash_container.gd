class_name LootStashPopupContainer extends PopupContainer

@export var sell_close_button: GenericButton
@export var slot_container: GridContainer





func _ready() -> void :
    hide()




func _process(_delta: float) -> void :
    container.position.y = roundi(container.position.y)






func get_item_slots() -> Array[ItemSlot]:
    var item_slots: Array[ItemSlot] = []

    for child in slot_container.get_children():
        if child is ItemSlot:
            item_slots.push_back(child)

    return item_slots
