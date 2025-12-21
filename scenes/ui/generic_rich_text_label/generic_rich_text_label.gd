class_name GenericRichTextLabel extends VBoxContainer


var bb_container_scene: PackedScene = preload("res://scenes/ui/bb_container/bb_container.tscn")
var curr_paragraph: Paragraph = create_paragraph()
var bb_containers: Array[BBContainer] = []





func add_bb_container(bb_container_data: BBContainerData) -> void :
    if not is_instance_valid(bb_container_data):
        return

    if bb_container_data.text.c_unescape() == "\n":
        if not bb_containers.is_empty():
            curr_paragraph = create_paragraph()
        bb_containers.push_back(null)
        return

    var bb_container: BBContainer = bb_container_scene.instantiate()
    curr_paragraph.add_child(bb_container)
    bb_container.apply_data(bb_container_data)
    bb_containers.push_back(bb_container)



func set_bb_containers(bb_container_data_arr: Array[BBContainerData]) -> void :
    clear()

    for idx in bb_container_data_arr.size():
        var bb_container_data = bb_container_data_arr[idx]
        add_bb_container(bb_container_data)




func create_paragraph() -> Paragraph:
    var paragraph: Paragraph = preload("res://scenes/ui/paragraph/paragraph.tscn").instantiate()
    add_child(paragraph)
    return paragraph



func remove_last_paragraph() -> void :
    var last_paragraph = get_child(get_child_count() - 1)
    remove_child(last_paragraph)
    last_paragraph.queue_free()

    if get_child_count() > 0:
        curr_paragraph = get_child(get_child_count() - 1)
        return

    curr_paragraph = create_paragraph()



func clear() -> void :
    for child in get_children():
        remove_child(child)
        child.queue_free()

    curr_paragraph = create_paragraph()
    bb_containers.clear()
