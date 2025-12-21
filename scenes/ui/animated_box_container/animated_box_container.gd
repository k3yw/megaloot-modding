@tool
class_name AnimatedBoxContainer extends Container


enum Type{HORIZONTAL, VERTICAL}


@export var seperation: int = 20

@export_range(0.0, 1.0) var offset_progress: float = 0.0
@export var offset: int = 0
@export var type: Type



func _process(delta: float) -> void :
    update_positions(delta)




func update_positions(delta: float) -> void :
    var control_nodes: Array[Control] = get_visible_children()
    var positions: Array[float] = []

    process_size()

    if not control_nodes.size():
        return


    for idx in control_nodes.size():
        var target_pos: float = get_target_position(positions)
        positions.push_back(target_pos)


    var max_size: float = seperation * (control_nodes.size() - 1)
    for idx in control_nodes.size():
        var control_node: Control = control_nodes[idx]
        max_size += get_control_size(control_node)


    for idx in control_nodes.size():
        var control_node: Control = control_nodes[idx]
        match type:
            Type.HORIZONTAL:
                var target_pos: float = positions[idx] - (max_size / 2) + (size.x * 0.5)
                control_node.position.x = lerp(control_node.position.x, target_pos, minf(1.0, 10 * delta))
                control_node.position.y = offset * clampf(offset_progress * control_nodes.size() * (idx + 1), 0.0, 1.0)

            Type.VERTICAL:
                var target_pos: float = positions[idx] - (max_size / 2) + (size.y * 0.5)
                control_node.position.y = lerp(control_node.position.y, target_pos, minf(1.0, 10 * delta))
                control_node.position.x = offset * clampf(offset_progress * control_nodes.size() * (idx + 1), 0.0, 1.0)
                control_node.size.x = size.x




func get_target_position(positions: Array[float]) -> float:
    var control_nodes: Array[Control] = get_visible_children()

    if not positions.size():
        return 0.0

    return positions.back() + get_control_size(control_nodes[positions.size() - 1]) + seperation



func get_control_size(control: Control) -> int:
    if not control.visible:
        return 0

    if type == Type.VERTICAL:
        return int(control.size.y)

    return int(control.size.x)






func process_size() -> void :
    match type:
        Type.HORIZONTAL:
            var min_size_y: int = 0

            for child in get_children():
                if child is Control:
                    child.size.x = 0
                    if min_size_y < child.size.y:
                        min_size_y = child.size.y

            custom_minimum_size.y = min_size_y

        Type.VERTICAL:
            var children: Array[Control] = get_visible_children()
            var min_size_y: int = seperation * (children.size() - 1)

            for child in children:
                if child.custom_minimum_size.y == 0:
                    min_size_y += int(child.size.y)
                    continue

                min_size_y += int(child.custom_minimum_size.y)

            custom_minimum_size.y = min_size_y
            size.y = min_size_y


    update_minimum_size()


func get_visible_children() -> Array[Control]:
    var visible_children: Array[Control] = []
    for child in get_children():
        if child is Control:
            if not child.visible:
                continue
            visible_children.push_back(child)
    return visible_children
