extends StatScript







func get_amount_to_upgrade(_item: Item, _is_modifier: bool, floor_number: int) -> float:
    return Math.calculate_diminished_stat(floor_number + 1, 75, 45)
