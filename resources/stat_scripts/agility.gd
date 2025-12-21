extends StatScript







func get_amount_to_upgrade(item: Item, _is_modifier: bool, floor_number: int) -> float:
    if is_instance_valid(item) and item.resource.socket_type == SocketTypes.WEAPON:
        return 0.0

    return minf(floor_number + 1, 25)
