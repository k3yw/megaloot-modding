class_name Slot extends RefCounted


enum ActionType{
    ITEM_REMOVED, 
    ITEM_SWAPPED, 
    ITEM_ADDED, 
}


const INVENTORY_SLOTS_PER_PAGE: int = 20



var item_container: ItemContainer = Empty.item_container
var index: int = -1


func _init(arg_item_container: ItemContainer = Empty.item_container, arg_index: int = -1) -> void :
    item_container = arg_item_container
    index = arg_index



func is_same_slot(arg_slot: Slot) -> bool:
    if not is_instance_valid(arg_slot):
        return false

    if not item_container == arg_slot.item_container:
        return false

    if not index == arg_slot.index:
        return false

    return true



func get_item() -> Item:
    if not is_instance_valid(item_container):
        return null
    return item_container.get_item(index)


func remove_item(cause: ItemContainer.ItemRemoveCause = ItemContainer.ItemRemoveCause.NULL) -> void :
    item_container.remove_item_at(index, cause)



func try_to_add_item(slots: Array[SocketType], item: Item) -> bool:
    return item_container.try_to_add_item_at(slots, index, item)
