class_name GameModeScript extends GameplayComponent


var game_mode: GameMode


func _init() -> void :
    var curr_state: Node = StateManager.get_current_state()
    if curr_state is GameplayState:
        game_mode = curr_state.memory.game_mode
        set_gameplay_state(curr_state)



func get_room_type(floor_number: int, room_idx: int) -> RoomResource:
    if not is_instance_valid(game_mode):
        return Rooms.BATTLE

    if room_idx == -1:
        return Rooms.ENTRANCE

    if not memory.is_endless:
        if floor_number >= game_mode.last_floor:
            return Rooms.FINAL

    if is_last_room(floor_number, room_idx):
        return get_last_room(floor_number, room_idx)

    if has_chest_room() and is_chest_floor(floor_number):
        if is_chest_room_idx(floor_number, room_idx):
            return Rooms.CHEST

    var room_type_override: RoomResource = get_room_type_override(floor_number, room_idx)
    if is_instance_valid(room_type_override):
        return room_type_override


    return Rooms.BATTLE



func get_room_type_override(floor_number: int, room_idx: int) -> RoomResource:
    return null



func get_last_room(floor_number: int, _room_idx: int) -> RoomResource:
    if str(floor_number + 1).contains("7"):
        return Rooms.MYSTIC_TRADER

    if is_chest_floor(floor_number + 2):
        return Rooms.MERCHANT

    if is_chest_floor(floor_number + 1):
        return Rooms.MERCHANT

    return Rooms.BATTLE




func has_chest_room() -> bool:
    return true

func is_chest_floor(floor_number: int) -> bool:
    return floor_number % 3 == 2

func is_chest_room_idx(floor_number: int, room_idx: int) -> bool:
    return room_idx == get_room_count(floor_number) - 2



func is_last_room(floor_number: int, room_idx: int) -> bool:
    return room_idx >= get_room_count(floor_number) - 1


func get_rooms_up_to_floor(stop_floor_number: int, stop_room_idx: int) -> Array[RoomResource]:
    var rooms: Array[RoomResource] = []

    for i in stop_floor_number:
        var room_count: int = get_room_count(stop_floor_number)

        if i == stop_floor_number:
            room_count = min(stop_room_idx, room_count)

        for j in room_count:
            rooms.push_back(get_room_type(i, j))

    return rooms


func get_rooms_in_floor(floor_number: int, stop_room_idx: int) -> Array[RoomResource]:
    var rooms: Array[RoomResource] = []

    for i in min(stop_room_idx, get_room_count(floor_number)):
        rooms.push_back(get_room_type(floor_number, i))

    return rooms





func get_room_count(floor_number: int) -> int:
    var base_room_count: int = game_mode.base_room_count

    if is_chest_floor(floor_number):
        base_room_count += 1

    return base_room_count



func get_battles_this_floor(floor_number: int) -> int:
    var room_count: int = get_room_count(floor_number)
    return get_rooms_in_floor(floor_number, room_count).count(Rooms.BATTLE)


func get_battle_count(floor_number: int, room_idx: int) -> int:
    return get_rooms_in_floor(floor_number, room_idx).count(Rooms.BATTLE)


func get_max_enemies(floor_number: int, room_idx: int) -> int:
    return get_battle_count(floor_number, room_idx) + 1



func get_gold_reward(floor_number: int) -> float:
    return (floor_number + 1) * 5


func get_gold_on_kill(player: Character, floor_number: int) -> float:
    var gold_reward: float = get_gold_reward(floor_number)

    if is_instance_valid(player):
        gold_reward += player.get_stat_amount(Stats.GOLD_ON_KILL)[0]
        gold_reward = StatUtils.modify(gold_reward, player.get_stat_amount(Stats.GREED)[0])


    return ceilf(gold_reward)
