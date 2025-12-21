extends Node

var main_canvas_layer: MainCanvasLayer
var hovered_node: Node
var curr_state: Node

var last_mouse_pos: Vector2





func _ready() -> void :
    StateManager.state_changed.connect(_on_state_changed)
    process_mode = ProcessMode.PROCESS_MODE_ALWAYS


func _on_state_changed() -> void :
    curr_state = StateManager.get_current_state()
    reset_selection()




func _input(event: InputEvent) -> void :
    if event is InputEventJoypadButton:
        Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

        if not event.pressed:
            return

        match event.button_index:
            JOY_BUTTON_DPAD_UP: select_next_node(Vector2i(0, 1))
            JOY_BUTTON_DPAD_DOWN: select_next_node(Vector2i(0, -1))
            JOY_BUTTON_DPAD_LEFT: select_next_node(Vector2i(1, 0))
            JOY_BUTTON_DPAD_RIGHT: select_next_node(Vector2i(-1, 0))

        if not can_select(UI.hovered_node):
            reset_selection()


func _process(_delta: float) -> void :
    var mouse_pos: Vector2 = get_viewport().get_mouse_position()

    if not mouse_pos == last_mouse_pos:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    last_mouse_pos = mouse_pos




func reset_selection() -> void :
    var main_node: Control


    if curr_state is GameplayState:
        for button in get_tree().get_nodes_in_group("main_joypad_selection"):
            main_node = button
            if can_select(main_node):
                break


    if curr_state is MainMenuState:
        main_node = curr_state.enter_the_tower_button

    if curr_state is MemorySelectionState:
        main_node = curr_state.interact_button

    if curr_state is LobbyState:
        main_node = curr_state.begin_button

    if curr_state is ProfileState:
        main_node = curr_state.back_button


    if not can_select(main_node):
        main_node = main_canvas_layer.options_screen.back_button
        if not can_select(main_node):
            return



    UI.hovered_node = main_node





func select_next_node(dir: Vector2i) -> void :
    if not is_instance_valid(UI.hovered_node):
        return

    var all_hover_info = HoverInfoManager.get_all_hover_info()
    var initial_node = UI.hovered_node
    var hover_info_children: Array[Control] = []
    var skip_bb: bool = false

    var priority_nodes: Array[Node] = []
    for visible_popup in UI.visible_popups:
        priority_nodes += NodeUtils.get_all_children(visible_popup)

    var active_nodes: Array = NodeManager.generic_buttons
    active_nodes += NodeManager.generic_drop_down_selections
    active_nodes += NodeManager.memory_slot_containers
    active_nodes += NodeManager.generic_toggle_buttons
    active_nodes += NodeManager.adventurer_tree_nodes
    active_nodes += NodeManager.stat_label_containers
    active_nodes += NodeManager.generic_line_edits
    active_nodes += NodeManager.close_buttons


    for node in get_tree().get_nodes_in_group("visible_by_joypad"):
        active_nodes.push_back(node)

    if curr_state is GameplayState:
        active_nodes.push_back(curr_state.canvas_layer.room_screen.battle_speed_container.margin_container)
        active_nodes.push_back(curr_state.canvas_layer.hub_action_panel.split_container)
        active_nodes.push_back(curr_state.canvas_layer.hub_action_panel.sell_container)


    if all_hover_info.size() == 1 and not initial_node is BBContainer:
        if dir.x:
            skip_bb = true


    if not skip_bb:
        for idx in range(all_hover_info.size() - 1, -1, -1):
            var hover_info: HoverInfo = all_hover_info[idx]
            if hover_info.lock_time_left <= 0:
                for bb_container in hover_info.get_bb_containers():
                    if not is_instance_valid(bb_container):
                        continue

                    if not is_instance_valid(bb_container.get_hover_info(HoverInfoData.new())):
                        continue

                    hover_info_children.push_back(bb_container)
                    active_nodes.push_back(bb_container)

                if hover_info.data.item_set_resources.size():
                    for set_icon in hover_info.set_icon_container.get_children():
                        hover_info_children.push_back(set_icon)
                        active_nodes.push_back(set_icon)

                break



    for generic_v_scroll_bar in NodeManager.generic_v_scroll_bars:
        active_nodes.push_back(generic_v_scroll_bar.scroll_rect)

    for tab_button in NodeManager.tab_buttons:
        active_nodes.push_back(tab_button.pressed_panel)

    for generic_drop_down in NodeManager.generic_drop_downs:
        active_nodes.push_back(generic_drop_down.main_container)

    for enemy_container in NodeManager.enemy_containers:
        active_nodes.push_back(enemy_container.selection_rect)

    for generic_h_slider in NodeManager.generic_h_sliders:
        active_nodes.push_back(generic_h_slider.grabber_texture_rect)

    if priority_nodes.size():
        for idx in range(active_nodes.size() - 1, -1, -1):
            var active_node = active_nodes[idx]
            if priority_nodes.has(active_node):
                continue
            active_nodes.erase(active_node)


    var initial_node_rect = UI.get_rect(UI.hovered_node)
    var closest_node: Control = UI.hovered_node
    var closest_distance: float = -1.0
    var hard_stop: int = 0
    var retry = true




    while retry and hard_stop < 640:
        for active_node in active_nodes:
            var active_node_rect = UI.get_rect(active_node)

            if initial_node == active_node:
                continue

            if not can_select(active_node):
                continue

            if not closest_node == initial_node:
                if hover_info_children.has(closest_node) and not hover_info_children.has(active_node):
                    continue

            var distance_vec: Vector2 = Math.get_rect_distance(active_node_rect, initial_node_rect)

            if dir.x and abs(distance_vec.y) > hard_stop:
                continue

            if dir.y and abs(distance_vec.x) > hard_stop:
                continue


            match dir.x:
                1: if initial_node_rect.position.x <= active_node_rect.position.x:
                    continue

                -1: if initial_node_rect.position.x >= active_node_rect.position.x:
                    continue

            match dir.y:
                1: if initial_node_rect.position.y <= active_node_rect.position.y:
                    continue

                -1: if initial_node_rect.position.y >= active_node_rect.position.y:
                    continue


            if active_node.has_meta(UI.CHILD_OF_SCROLL_CONTAINER):
                var scroll_container: ScrollContainer = UI.get_scroll_container(active_node)
                if not scroll_container.get_global_rect().intersects(active_node_rect):
                    continue



            var new_closest_distance: float = distance_vec.length()
            var override_closest_distance: bool = false


            if new_closest_distance <= closest_distance:
                override_closest_distance = true
                if not new_closest_distance:
                    var test_rect = Rect2(active_node_rect)
                    test_rect.position += Vector2(dir)
                    if not test_rect.intersects(initial_node_rect):
                        continue

            if closest_distance == -1.0:
                override_closest_distance = true

            if not hover_info_children.has(closest_node) and hover_info_children.has(active_node):
                override_closest_distance = true

            if not override_closest_distance:
                continue

            closest_distance = new_closest_distance
            closest_node = active_node
            retry = false

            if hover_info_children.size() and not hover_info_children.has(closest_node):
                retry = true



        hard_stop += 5


    if not is_instance_valid(closest_node):
        return


    if not hover_info_children.has(closest_node):
        if hover_info_children.has(initial_node) and all_hover_info.size():
            var hover_info: HoverInfo = all_hover_info[0]
            UI.hovered_node = hover_info.data.owner
            return


    CursorManager.update_cursor()
    UI.hovered_node = closest_node







func can_select(node) -> bool:
    var initial_node = UI.hovered_node
    var result: bool = false

    if not is_instance_valid(node):
        return false

    UI.hovered_node = node
    result = UI.is_hovered(node)

    if not is_instance_valid(initial_node):
        UI.hovered_node = null
        return result

    UI.hovered_node = initial_node

    return result
