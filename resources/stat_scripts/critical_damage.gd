extends StatScript







func get_amount_to_upgrade(_item: Item, _is_modifier: bool, floor_number: int) -> float:
    return float(floor_number * 5)
