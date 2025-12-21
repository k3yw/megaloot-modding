extends StatScript







func get_amount_to_upgrade(_item: Item, is_modifier: bool, _floor_number: int) -> float:
    if is_modifier:
        return 0.0
    return 5.0
