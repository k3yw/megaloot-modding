class_name ItemUtils





static func is_valid(item: Item) -> bool:
    if not is_instance_valid(item):
        return false

    if not is_instance_valid(item.resource):
        return false

    if item.resource == Empty.item_resource:
        return false

    return true



static func get_valid_items(items: Array[Item]) -> Array[Item]:
    var valid_items: Array[Item] = []

    for item in items:
        if not is_valid(item):
            continue

        valid_items.push_back(item)

    return valid_items



static func get_item_sets(items: Array[Item]) -> Array[ItemSetResource]:
    var item_sets: Array[ItemSetResource] = []

    for item in items:
        for item_set in item.resource.set_resources:
            if not item_sets.has(item_set):
                item_sets.push_back(item_set)

    return item_sets



static func get_item_set_count(items: Array[Item], item_set_ref: ItemSetResource) -> int:
    var amount: int = 0

    for item in items:
        for item_set in item.resource.set_resources:
            if not item_set == item_set_ref:
                continue
            amount += 1

    return amount



static func are_same_set_resources(item_resource_a: ItemResource, item_resource_b: ItemResource) -> bool:
    for set_resource in item_resource_a.set_resources:
        if not item_resource_b.set_resources.has(set_resource):
            return false

    return true
