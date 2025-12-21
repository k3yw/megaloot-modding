class_name DynamicSlotContainer extends GridContainer


@export var min_rows: int = 4


func update_slots(last_item_idx: int) -> bool:
    var curr_slot_count: int = get_child_count()
    var next_row: int = ceili(float(last_item_idx + 1) / 5.0)
    var target_slots: int = maxi(min_rows * columns, columns * next_row)

    var slots_to_add: int = maxi(0, target_slots - curr_slot_count)
    var slots_to_remove: int = maxi(0, curr_slot_count - target_slots)


    for _i in slots_to_add:
        var item_slot: ItemSlot = preload("res://scenes/ui/item_slot/item_slot.tscn").instantiate()
        add_child(item_slot)

    for _i in range(slots_to_remove):
        var last_child_idx: int = get_child_count() - 1
        var last_child = get_child(last_child_idx)
        remove_child(last_child)
        last_child.queue_free()


    if slots_to_add:
        return true

    if slots_to_remove:
        return true


    return false
