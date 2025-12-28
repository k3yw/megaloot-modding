extends GameModeScript




func vanilla_1181427809_get_last_room(floor_number: int) -> RoomResource:
	if floor_number + 1 == 100:
		return Rooms.BATTLE

	if floor_number >= 9 and (floor_number - 9) % 25 == 0:
		return Rooms.DISMANTLE

	if [7, 17, 27, 37].has(floor_number + 1) or floor_number >= 39 and (floor_number - 37) % 20 == 0:
		return Rooms.MYSTIC_TRADER

	if [1, 3, 7, 15].has(floor_number + 1) or floor_number >= 17 and (floor_number - 15) % 8 == 0:
		return Rooms.MERCHANT

	if floor_number > 17 and (floor_number + 1) % 7 == 0:
		return Rooms.BATTLE

	return Rooms.BATTLE




func vanilla_1181427809_get_max_enemies(floor_number: int, room_idx: int) -> int:
	var max_enemies: int = get_battle_count(floor_number, room_idx) + 1
	max_enemies += mini(3, floori(float(floor_number + 1) / 10))

	return max_enemies


func vanilla_1181427809_get_gold_reward(floor_number: int) -> float:
	return (floor_number + 1) * 25



func vanilla_1181427809_get_room_count(floor_number: int) -> int:
	var base_room_count: int = 4

	if floor_number >= 14:
		base_room_count = 3

	if floor_number >= 29:
		base_room_count = 2

	if floor_number >= 59:
		base_room_count = 1

	if not get_last_room(floor_number) == Rooms.BATTLE:
		base_room_count += 1

	return base_room_count


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func get_last_room(floor_number: int) -> RoomResource:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1181427809_get_last_room, [floor_number], 423178288)
	else:
		return vanilla_1181427809_get_last_room(floor_number)


func get_max_enemies(floor_number: int, room_idx: int) -> int:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1181427809_get_max_enemies, [floor_number, room_idx], 2055022763)
	else:
		return vanilla_1181427809_get_max_enemies(floor_number, room_idx)


func get_gold_reward(floor_number: int) -> float:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1181427809_get_gold_reward, [floor_number], 4124395178)
	else:
		return vanilla_1181427809_get_gold_reward(floor_number)


func get_room_count(floor_number: int) -> int:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1181427809_get_room_count, [floor_number], 3934156997)
	else:
		return vanilla_1181427809_get_room_count(floor_number)
