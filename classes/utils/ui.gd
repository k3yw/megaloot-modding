class_name UI

const CHILD_OF_SCROLL_CONTAINER: String = "child_of_scroll_container"
const GAMEPLAY_COVERED: String = "gameplay_covered"
const CONSOLE_COVERED: String = "console_covered"


const MOUSE_FILTER_META_ARR: Array[String] = [
    GAMEPLAY_COVERED, 
    CONSOLE_COVERED, 
]


static  var active_hover_info: Array[HoverInfo] = []
static  var priority_hover_nodes: Array[Node] = []
static  var visible_popups: Array[Node] = []


static  var hovered_scroll_containers: Array[GenericScrollContainer] = []

static  var active_line_edit: LineEdit = null
static  var hovered_node: Control = null
static  var minimized: bool = false




static func get_front_scroll_container() -> GenericScrollContainer:
    var front_scroll_container: GenericScrollContainer = null

    for scroll_container in hovered_scroll_containers:
        if not is_instance_valid(front_scroll_container):
            front_scroll_container = scroll_container
            continue

        if scroll_container.view_order > front_scroll_container.view_order:
            front_scroll_container = scroll_container

    return front_scroll_container




static func is_active(control) -> bool:
    if not is_instance_valid(control):
        return false

    if control.is_queued_for_deletion():
        return false

    @warning_ignore("standalone_expression")
    control = control as Control

    if not control.is_visible_in_tree():
        return false

    if minimized:
        return false

    for mouse_filter_meta in MOUSE_FILTER_META_ARR:
        if control.has_meta(mouse_filter_meta):
            return false


    if priority_hover_nodes.size() and not priority_hover_nodes.has(control):
        return false


    var parent = control.get_parent()
    if not control.get_tree().root.get_viewport() == control.get_viewport():
        parent = control.get_parent()
        while is_instance_valid(parent):
            if parent is SubViewportContainer:
                if not parent.is_visible_in_tree():
                    return false

            parent = parent.get_parent()


    return true





static func is_hovered(control) -> bool:
    if not is_active(control):
        return false

    @warning_ignore("standalone_expression")
    control = control as Control


    var joypad_active: bool = Input.mouse_mode == Input.MOUSE_MODE_HIDDEN
    if joypad_active:
        for hover_info in active_hover_info:
            if not is_instance_valid(hover_info.data):
                continue

            if not hover_info.main_container == control:
                continue

            if NodeUtils.get_all_children(hover_info).has(hovered_node):
                return true

        return hovered_node == control


    if not has_point(control):
        return false


    if control is BBContainer:
        for header_line_container in control.header_line_containers:
            if has_point(header_line_container):
                return false


    var inside_hover_info: bool = false

    for hover_info in active_hover_info:
        if not is_instance_valid(hover_info.data):
            continue

        if active_hover_info.size() == 1 and hover_info.data.owner == control:
            return true

        if NodeUtils.get_all_children(hover_info).has(control):
            return true

        if has_point(hover_info.main_container):
            inside_hover_info = true

    if inside_hover_info:
        return false


    var failed: bool = visible_popups.size()
    for visible_popup in visible_popups:
        if NodeUtils.get_all_children(visible_popup).has(control):
            failed = false
            break

    if failed:
        return false


    if control.has_meta(CHILD_OF_SCROLL_CONTAINER):
        var scroll_container: ScrollContainer = get_scroll_container(control)
        if is_instance_valid(scroll_container):
            if not has_point(scroll_container):
                return false

    if control is GenericDropDownSelection:
        if not has_point(control):
            return false

    return true




static func has_point(control: Control) -> bool:
    if control.get_global_rect().has_point(control.get_global_mouse_position()):
        return true

    if control.get_global_rect().has_point(control.get_global_mouse_position() + Vector2(0.5, 0.5)):
        return true

    if control.get_global_rect().has_point(control.get_global_mouse_position() - Vector2(0.5, 0.5)):
        return true

    return false




static func get_scroll_container(node: Node) -> ScrollContainer:
    var parent = node.get_parent()

    while is_instance_valid(parent):
        if not parent is Control:
            parent = null
            return

        if parent is ScrollContainer:
            return parent

        parent = parent.get_parent()

    return null





static func get_rect(control: CanvasItem) -> Rect2:
    if not is_instance_valid(control):
        return Rect2()

    if not is_instance_valid(control.get_viewport()):
        return Rect2()

    var viewport_parent = control.get_viewport().get_parent()
    var rect: Rect2 = control.get_global_rect()

    if viewport_parent is SubViewportContainer:
        rect.position += viewport_parent.global_position

    return rect



static func set_priority_hover_node(tree: SceneTree, node: Node, to_add: bool) -> void :
    if to_add:
        if not priority_hover_nodes.has(node):
            priority_hover_nodes.push_back(node)
        return

    await tree.process_frame
    priority_hover_nodes.erase(node)






static func add_meta(node: Node, filter: Array[Control], meta: String) -> void :
    for child in NodeUtils.get_control_children(node, []):
        if filter.has(child):
            continue
        child.set_meta(meta, 1)


static func remove_meta_from_all(node: Node, meta: String) -> void :
    for child in NodeUtils.get_control_children(node, []):
        child.remove_meta(meta)
