extends Node



var UNAVOIDABLE: Keyword = load("res://resources/keywords/unavoidable.tres")
var ANTI_STEAL: Keyword = load("res://resources/keywords/anti_steal.tres")
var ATTACK_DAMAGE: Keyword = load("res://resources/keywords/attack_damage.tres")
var EXECUTE: Keyword = load("res://resources/keywords/execute.tres")
var ASCEND: Keyword = load("res://resources/keywords/ascend.tres")
var TINKER: Keyword = load("res://resources/keywords/tinker.tres")
var HEAL: Keyword = load("res://resources/keywords/heal.tres")

var TIER_I_REWARD: Keyword = load("res://resources/keywords/tier_i_reward.tres")



var LIST: Array[Keyword] = []



func _ready() -> void :
    for property in get_property_list():
        if not property["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE:
            continue

        if not property["type"] == TYPE_OBJECT:
            continue

        LIST.push_back(get(property["name"]))



func get_bb_container_data(keyword: Keyword) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.text = T.get_translated_string(keyword.name, "Keyword Name")
    bb_container_data.ref_objects.push_back(keyword)
    bb_container_data.left_image = keyword.icon
    bb_container_data.left_image_color = keyword.color
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE

    if is_instance_valid(bb_container_data.left_image):
        bb_container_data.text = " " + bb_container_data.text

    return bb_container_data
