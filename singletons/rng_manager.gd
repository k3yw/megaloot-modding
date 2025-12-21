extends Node


var gameplay_rand: RandomNumberGenerator = RandomNumberGenerator.new()
var market_rand: RandomNumberGenerator = RandomNumberGenerator.new()
var enemy_rand: RandomNumberGenerator = RandomNumberGenerator.new()
var luck_rand: RandomNumberGenerator = RandomNumberGenerator.new()

var LIST: Array[RandomNumberGenerator] = [
    gameplay_rand, 
    market_rand, 
    enemy_rand, 
    luck_rand, 
]


func generate_random_string(length: = 16) -> String:
    var chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    var char_list: Array = Array(chars.split(""))
    char_list.shuffle()
    return "".join(char_list.slice(0, length))


func random_skewed_number(max_value: int) -> int:
    var random_val = randf()
    return int(pow(random_val, 3) * max_value)






func sync_rng_states(states: PackedInt64Array = []) -> void :
    for idx in LIST.size():
        var rand: RandomNumberGenerator = LIST[idx]
        var state: int = states[idx]
        rand.state = state



func get_states() -> PackedInt64Array:
    var states: PackedInt64Array = []
    for rand in LIST:
        states.push_back(rand.state)
    return states



func set_base_seed(arg_seed: int) -> void :
    for rand in LIST:
        rand.seed = arg_seed


func shuffle_array(rng: RandomNumberGenerator, arr: Array) -> void :
    for i in range(arr.size() - 1, -1, -1):
        var j = rng.randi_range(0, i)
        var temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp


func pick_random(rng: RandomNumberGenerator, size: int) -> int:
    var weight_pool: PackedFloat32Array

    for _i in size:
        weight_pool.push_back(1.0)

    return rng.rand_weighted(weight_pool)
