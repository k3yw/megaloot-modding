extends Node


const DIR: String = "res://resources/item_sets/"


var CONSUMABLE: ItemSetResource = load("res://resources/item_sets/consumable.tres")
var ESSENTIAL: ItemSetResource = load("res://resources/item_sets/essential.tres")
var GENERIC: ItemSetResource = load("res://resources/item_sets/generic.tres")
var TOME: ItemSetResource = load("res://resources/item_sets/tome.tres")


var ANCIENT_SHELL: ItemSetResource = load("res://resources/item_sets/ancient_shell.tres")

var ANCIENT_ICE: ItemSetResource = load("res://resources/item_sets/ancient_ice.tres")
var CHROMALURE: ItemSetResource = load("res://resources/item_sets/chromalure.tres")
var BLACKTHORN: ItemSetResource = load("res://resources/item_sets/blackthorn.tres")
var UNCHAINED: ItemSetResource = load("res://resources/item_sets/unchained.tres")
var SWIFTNESS: ItemSetResource = load("res://resources/item_sets/swiftness.tres")
var MERCENARY: ItemSetResource = load("res://resources/item_sets/mercenary.tres")
var BERSERKER: ItemSetResource = load("res://resources/item_sets/berserker.tres")
var CATACLYSM: ItemSetResource = load("res://resources/item_sets/cataclysm.tres")
var CELESTIAL: ItemSetResource = load("res://resources/item_sets/celestial.tres")
var VAMPIRIC: ItemSetResource = load("res://resources/item_sets/vampiric.tres")
var ZEPHYRON: ItemSetResource = load("res://resources/item_sets/zephyron.tres")
var BASTOLIC: ItemSetResource = load("res://resources/item_sets/bastolic.tres")
var DARKNESS: ItemSetResource = load("res://resources/item_sets/darkness.tres")
var REFORGE: ItemSetResource = load("res://resources/item_sets/reforge.tres")
var PHANTOM: ItemSetResource = load("res://resources/item_sets/phantom.tres")
var POVERTY: ItemSetResource = load("res://resources/item_sets/poverty.tres")
var DEMONIC: ItemSetResource = load("res://resources/item_sets/demonic.tres")
var WARRIOR: ItemSetResource = load("res://resources/item_sets/warrior.tres")
var THUNDER: ItemSetResource = load("res://resources/item_sets/thunder.tres")
var ARCANUM: ItemSetResource = load("res://resources/item_sets/arcanum.tres")
var CURSED: ItemSetResource = load("res://resources/item_sets/cursed.tres")
var SILVER: ItemSetResource = load("res://resources/item_sets/silver.tres")
var SHADOW: ItemSetResource = load("res://resources/item_sets/shadow.tres")
var HUNTER: ItemSetResource = load("res://resources/item_sets/hunter.tres")
var GOLDEN: ItemSetResource = load("res://resources/item_sets/golden.tres")
var LEGACY: ItemSetResource = load("res://resources/item_sets/legacy.tres")
var ROYAL: ItemSetResource = load("res://resources/item_sets/royal.tres")
var ORION: ItemSetResource = load("res://resources/item_sets/orion.tres")
var FLESH: ItemSetResource = load("res://resources/item_sets/flesh.tres")
var SCOUT: ItemSetResource = load("res://resources/item_sets/scout.tres")
var MAGMA: ItemSetResource = load("res://resources/item_sets/magma.tres")
var WOOD: ItemSetResource = load("res://resources/item_sets/wood.tres")
var JADE: ItemSetResource = load("res://resources/item_sets/jade.tres")




var LIST: Array[ItemSetResource] = []


var PASSIVES: Dictionary[ItemSetResource, PassiveArray] = {}
var STATS: Dictionary[ItemSetResource, StatArray] = {}


class PassiveArray:
    var arr: Array[Passive] = []

class StatArray:
    var arr: Array[StatResource] = []



func _ready() -> void :
    Items.initialized.connect(cache_arrays)

    for file_name in File.get_file_paths(DIR):
        var file_path: String = DIR + file_name

        if ".tres.remap" in file_path:
            file_path = file_path.trim_suffix(".remap")

        var res = load(file_path)
        if not is_instance_valid(res):
            print("failed to load stat resource: " + file_path)
            continue

        LIST.push_back(load(file_path))




func cache_arrays() -> void :
    for item in Items.LIST:
        var item_set: ItemSetResource = item.set_resources[0]

        if not PASSIVES.has(item_set):
            PASSIVES[item_set] = PassiveArray.new()

        if not STATS.has(item_set):
            STATS[item_set] = StatArray.new()

        if not PASSIVES[item_set].arr.has(item.passive):
            PASSIVES[item_set].arr.push_back(item.passive)

        for stat in item.bonus_stats:
            if not STATS[item_set].arr.has(stat.resource):
                STATS[item_set].arr.push_back(stat.resource)






func pick_random(amount: int, pool: Array[ItemSetResource] = []) -> Array[ItemSetResource]:
    var item_sets: Array[ItemSetResource] = []

    pool.shuffle()

    for _i in amount:
        var result = pool.pop_back()
        if not is_instance_valid(result):
            break
        item_sets.push_back(result)

    return item_sets




func get_sets_for_reforge(floor_number: int, filter: Array[ItemResource] = []) -> Array[ItemSetResource]:
    var sets: Array[ItemSetResource] = []

    for item_resource in Items.LIST:
        if item_resource.spawn_floor > floor_number:
            continue

        if filter.has(item_resource):
            continue

        for item_set in item_resource.set_resources:
            if sets.has(item_set):
                continue
            sets.push_back(item_set)

    sets.erase(CONSUMABLE)
    sets.erase(ESSENTIAL)
    sets.erase(PHANTOM)
    sets.erase(GENERIC)

    return sets



func get_bb_container_data(item_set_resource: ItemSetResource, specialization: Specialization = null) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.text = " " + T.get_translated_string(item_set_resource.name, "Item Set Name")
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE
    bb_container_data.item_set_resource = item_set_resource
    bb_container_data.specialization = specialization

    return bb_container_data
