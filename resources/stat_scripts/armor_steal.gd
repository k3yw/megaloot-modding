extends StatScript







func get_amount_to_upgrade(_item: Item, _is_modifier: bool, floor_number: int) -> float:
    return minf(ceilf((floor_number + 1) * 0.25), 10)
