@tool
class_name GenericScrollContainer extends HBoxContainer

@export var scroll_container: ScrollContainer
@export var scroll_bar: GenericVScrollBar
@export var scroll_speed: int = 10

@export var fillped: bool = false

var selected: bool = false
var view_order: int = 0



func _ready() -> void :
    for child in NodeUtils.get_all_children(scroll_container):
        if child is Control:
            child.resized.connect( func(): update.call_deferred())
        apply_meta(child)

    if fillped:
        move_child(get_child(1), 0)


func update() -> void :
    if is_instance_valid(scroll_container.get_child(0)):
        scroll_bar.max_size = maxf(scroll_container.size.y, (scroll_container.get_child(0) as Control).size.y)

    scroll_bar.min_size = scroll_container.size.y
    scroll_bar.update_size()



func _notification(what: int) -> void :
    match what:
        NOTIFICATION_SORT_CHILDREN:
            update.call_deferred()



func _input(event: InputEvent) -> void :
    if Engine.is_editor_hint():
        return

    if not selected:
        return

    if event is InputEventJoypadMotion:
        var axis_value: float = roundf(event.axis_value * 10) / 10.0

        if event.axis == JOY_AXIS_RIGHT_Y:
            scroll_bar.axis_value = axis_value

            if abs(axis_value) > 0.0:
                UI.hovered_node = self




func _process(_delta: float) -> void :
    if Engine.is_editor_hint():
        return

    UI.hovered_scroll_containers.erase(self)
    if not is_visible_in_tree():
        return

    if get_global_rect().has_point(get_global_mouse_position()):
        UI.hovered_scroll_containers.push_back(self)

    selected = is_selected()


    if selected:
        if Input.is_action_just_released("scroll_up"):
            scroll_bar.target_pos -= scroll_speed

        if Input.is_action_just_released("scroll_down"):
            scroll_bar.target_pos += scroll_speed


    scroll_container.scroll_vertical = int(scroll_bar.get_scroll())






func is_selected() -> bool:
    if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
        if not is_instance_valid(UI.hovered_node):
            return false

        if UI.hovered_node == self:
            return true

        if not UI.hovered_node.has_meta(UI.CHILD_OF_SCROLL_CONTAINER):
            return false

        if get_global_rect().intersects(UI.hovered_node.get_global_rect()):
            return true

        return false


    if UI.get_front_scroll_container() == self:
        return true

    return false





func _on_child_entered_tree(node: Node) -> void :
    apply_meta(node)



func apply_meta(node: Node) -> void :
    if not node.tree_exiting.is_connected(_on_tree_exiting):
        node.tree_exiting.connect(_on_tree_exiting.bind(node))

    if not node.child_entered_tree.is_connected(_on_child_entered_tree):
        node.child_entered_tree.connect(_on_child_entered_tree)

    node.set_meta(UI.CHILD_OF_SCROLL_CONTAINER, true)


func _on_tree_exiting(node: Node) -> void :
    node.remove_meta(UI.CHILD_OF_SCROLL_CONTAINER)
