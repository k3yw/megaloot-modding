extends StatScript




func get_amount_to_upgrade(_item: Item, is_modifier: bool, floor_number: int) -> float:
    if is_modifier:
        return Math.calculate_diminished_stat(floor_number + 1, 25, 7.5)

    return ceilf(pow(floor_number + 1, 1.12))
