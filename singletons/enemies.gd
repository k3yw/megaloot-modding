extends Node


const SPECIAL_ENEMIES_DIR: String = "res://resources/special_enemies/"
const ENEMIES_DIR: String = "res://resources/enemies/"

var HEART_OF_THE_TOWER: EnemyResource = load("res://resources/special_enemies/heart_of_the_tower.tres")
var TRAINING_DUMMY: EnemyResource = load("res://resources/special_enemies/training_dummy.tres")
var COMMON_CHEST: EnemyResource = load("res://resources/special_enemies/common_chest.tres")
var GOLDEN_CHEST: EnemyResource = load("res://resources/special_enemies/golden_chest.tres")
var MYSTIC_TRADER: EnemyResource = load("res://resources/special_enemies/mystic_trader.tres")
var MYSTIC_BISON: EnemyResource = load("res://resources/special_enemies/mystic_bison.tres")
var MERCHANT: EnemyResource = load("res://resources/special_enemies/merchant.tres")


var RED_ORC: EnemyResource = load("res://resources/enemies/red_orc.tres")
var GOBLIN: EnemyResource = load("res://resources/enemies/goblin.tres")


var SPECIAL: Array[EnemyResource] = []
var LIST: Array[EnemyResource] = []




func _ready() -> void :
    for file_name in File.get_file_paths(ENEMIES_DIR):
        var file_path: String = ENEMIES_DIR + file_name

        if ".tres.remap" in file_path:
            file_path = file_path.trim_suffix(".remap")

        if ".tmp" in file_path:
            printerr("found temp file: ", file_path, ", please delete")

        var enemy: EnemyResource = load(file_path)
        if System.is_demo() and enemy.floor_number > 15:
            continue
        LIST.push_back(enemy)


    for file_name in File.get_file_paths(SPECIAL_ENEMIES_DIR):
        var file_path: String = SPECIAL_ENEMIES_DIR + file_name

        if ".tres.remap" in file_path:
            file_path = file_path.trim_suffix(".remap")

        if ".tmp" in file_path:
            printerr("found temp file: ", file_path, ", please delete")

        var enemy: EnemyResource = load(file_path)

        SPECIAL.push_back(enemy)

    LIST.sort_custom(sort_enemies)





func get_from_floor(enemy_content: Array[EnemyResource], floor_number: int) -> Array[EnemyResource]:
    var enemy_pool: Array[EnemyResource] = []

    for enemy in enemy_content:
        if enemy.floor_number > floor_number:
            continue

        enemy_pool.push_back(enemy)

    return enemy_pool



func sort_enemies(resource_a: EnemyResource, resource_b: EnemyResource) -> bool:
    if resource_a.floor_number >= resource_b.floor_number:
        return false
    return true







func get_bb_container_data(enemy: Enemy) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.text = T.get_translated_string(enemy.resource.name, "enemy-name")
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE
    bb_container_data.enemy = enemy

    return bb_container_data
