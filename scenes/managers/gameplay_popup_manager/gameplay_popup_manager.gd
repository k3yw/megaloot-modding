class_name GameplayPopupManager extends Node2D


const ITEM_FOUND_LIFE_TIME: float = 1.25
const POPUP_LABEL_LIFE_TIME: float = 0.25


var item_found_popup_queue: Array[Node] = []
var popup_label_queue: Array[Node] = []


var life_time: Array[float] = [0.0, 0.0]



func _process(delta: float):
    process_popup_queue(item_found_popup_queue, ITEM_FOUND_LIFE_TIME, 0, delta)
    process_popup_queue(popup_label_queue, POPUP_LABEL_LIFE_TIME, 1, delta)




func process_popup_queue(popup_data_queue: Array[Node], popup_life_time: float, life_time_index: int, delta: float):
    if life_time[life_time_index] > 0:
        life_time[life_time_index] -= delta * maxf(1.0, float(popup_data_queue.size()) * 0.25)


    if not popup_data_queue.size():
        return


    if life_time[life_time_index] <= 0:
        var popup = popup_data_queue.pop_front()

        if not is_instance_valid(popup):
            return

        add_child(popup)

        life_time[life_time_index] = popup_life_time
        return




func create_popup_label(popup_label_data: PopupLabelData, wait_time: float = 0.0):
    var popup_label = preload("res://scenes/ui/popup_label/popup_label.tscn").instantiate()
    popup_label.apply_data(popup_label_data)

    if wait_time > 0.0:
        await get_tree().create_timer(wait_time).timeout

    popup_label_queue.push_back(popup_label)




func create_item_received_popup(item: Item, pos: Vector2, sender_name: String = ""):
    if not is_instance_valid(item):
        return

    var item_found_popup: ItemFoundPopup = preload("res://scenes/ui/item_found_popup/item_found_popup.tscn").instantiate()
    var item_name: String = T.get_translated_string(item.resource.name, "Item Name")
    item_found_popup.texture_rect.texture = item.get_texture()

    item_found_popup.label.text = T.get_translated_string("Item Found")
    if sender_name.length():
        item_found_popup.label.text = T.get_translated_string("Player Sent An Item")

    item_found_popup.label.text = item_found_popup.label.text.replace("{item-name}", item_name) + "!"
    item_found_popup.label.text = item_found_popup.label.text.replace("{player-name}", sender_name)


    item_found_popup.position = pos - Vector2(item_found_popup.size.x * 0.5, 0)

    item_found_popup_queue.push_back(item_found_popup)
