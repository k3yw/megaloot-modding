class_name GenericDropDown extends MarginContainer

signal selected(selected_idx: int)

@export var selection_scroll_container: GenericScrollContainer
@export var selection_container: VBoxContainer
@export var main_container: MarginContainer
@export var selections: Array[String] = []
@export var selection_label: GenericLabel
@export var translate: bool = false
@export var capitalize: bool

var changed_selection: bool = false
var selecting: bool = true
var selected_idx: int = 0

var disabled: bool = false




func _ready() -> void :
    for selection in selections:
        add_selection(selection, false)





func clear_selections(full: bool = true) -> void :
    for child in selection_container.get_children():
        selection_container.remove_child(child)
        child.queue_free()

    selection_scroll_container.scroll_container.custom_minimum_size.y = 0
    if full:
        selections.clear()



func add_selection(selection_name: String, save: bool = true) -> void :
    var drop_down_selection: GenericDropDownSelection = preload("res://scenes/ui/generic_drop_down_selection/generic_drop_down_selection.tscn").instantiate()
    drop_down_selection.name_label.text = selection_name

    if T.is_initialized() and translate:
        drop_down_selection.name_label.text = T.get_translated_string(selection_name, "Drop Down Selection")

    selection_container.add_child(drop_down_selection)

    if save:
        selections.push_back(selection_name)

    if selections.size() <= 5:
        selection_scroll_container.scroll_container.custom_minimum_size.y += drop_down_selection.size.y





func reload_selections() -> void :
    clear_selections(false)
    for selection in selections:
        add_selection(selection, false)



func select(selection: String) -> void :
    selected_idx = 0

    for index in selections.size():
        if not index:
            continue

        if selections[index] == selection:
            selected_idx = index




func _process(_delta: float) -> void :
    var has_priority: bool = false
    changed_selection = false

    if disabled:
        return

    for child in selection_container.get_children():
        if not UI.is_hovered(child):
            continue
        has_priority = true
        break


    for child in selection_container.get_children():
        UI.set_priority_hover_node(get_tree(), child, has_priority)

    UI.set_priority_hover_node(get_tree(), selection_scroll_container, has_priority)
    UI.set_priority_hover_node(get_tree(), main_container, has_priority)



    var selected_drop_down: GenericDropDownSelection = null
    for child in selection_container.get_children():
        (child.background_color_rect.material as ShaderMaterial).set_shader_parameter("brightness", -0.5)
        if child is GenericDropDownSelection:
            if not UI.is_hovered(child):
                continue
            selected_drop_down = child

    if is_instance_valid(selected_drop_down):
        (selected_drop_down.background_color_rect.material as ShaderMaterial).set_shader_parameter("brightness", 0.5)



    if Input.is_action_just_pressed("press"):
        if UI.is_hovered(main_container):
            selecting = not selecting
            return


        for idx in selection_container.get_child_count():
            var child = selection_container.get_child(idx)

            if child is GenericDropDownSelection:
                if not UI.is_hovered(child):
                    continue

                clear_priority_hover_nodes()
                changed_selection = true
                selected_idx = idx
                selected.emit(idx)



        if not UI.is_hovered(selection_scroll_container.scroll_bar):
            selecting = false


    if selections.size():
        selection_label.text = (selection_container.get_child(selected_idx) as GenericDropDownSelection).name_label.text

    selection_scroll_container.visible = selecting



func clear_priority_hover_nodes() -> void :
    await get_tree().process_frame
    UI.priority_hover_nodes.clear()
