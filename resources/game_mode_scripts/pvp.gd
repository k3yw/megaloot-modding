extends GameModeScript





func get_room_type_override(floor_number: int, room_idx: int) -> RoomResource:
    if room_idx % 2 == 0:
        return Rooms.BATTLE
    return Rooms.ENEMY_UPGRADE


func has_chest_room() -> bool:
    return false


func get_gold_reward(floor_number: int) -> float:
    return (floor_number + 1) * 32
