extends StatScript







func get_amount_to_upgrade(_item: Item, is_modifier: bool, floor_number: int) -> float:
    if not is_modifier:
        return 0.0

    return float(floor_number + 1)
