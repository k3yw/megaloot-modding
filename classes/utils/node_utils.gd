class_name NodeUtils








static func get_all_children(node, children: Array[Node] = []) -> Array[Node]:
    if not is_instance_valid(node):
        return children

    node = node as Node
    children.push_back(node)

    for child in node.get_children():
        children = get_all_children(child, children)

    return children



static func get_control_children(node: Node, children: Array[Control] = []) -> Array[Control]:
    if not is_instance_valid(node):
        return children

    if node is Control:
        children.push_back(node)

    for child in node.get_children():
        children = get_control_children(child, children)

    return children
