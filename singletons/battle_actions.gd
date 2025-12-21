extends Node


var CRITICAL_STRIKE: BattleAction = load("res://resources/battle_actions/critical_strike.tres")
var COUNTER_ATTACK: BattleAction = load("res://resources/battle_actions/counter_attack.tres")
var MULTI_ATTACK: BattleAction = load("res://resources/battle_actions/multi_attack.tres")
var LUCKY_ATTACK: BattleAction = load("res://resources/battle_actions/lucky_attack.tres")
var ARMOR_BREAK: BattleAction = load("res://resources/battle_actions/armor_break.tres")
var OMNI_CRIT: BattleAction = load("res://resources/battle_actions/omni_crit.tres")
var POLYMORPH: BattleAction = load("res://resources/battle_actions/polymorph.tres")
var IMMOLATE: BattleAction = load("res://resources/battle_actions/immolate.tres")
var BACKSTAB: BattleAction = load("res://resources/battle_actions/backstab.tres")
var CLEANSE: BattleAction = load("res://resources/battle_actions/cleanse.tres")
var DODGE: BattleAction = load("res://resources/battle_actions/dodge.tres")
var PARRY: BattleAction = load("res://resources/battle_actions/parry.tres")
var BLOCK: BattleAction = load("res://resources/battle_actions/block.tres")
var GUARD: BattleAction = load("res://resources/battle_actions/guard.tres")
var MISS: BattleAction = load("res://resources/battle_actions/miss.tres")
var HIT: BattleAction = load("res://resources/battle_actions/hit.tres")



var LIST: Array[BattleAction] = []




func _ready() -> void :
    for property in get_property_list():
        if not property["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE:
            continue

        if not property["type"] == TYPE_OBJECT:
            continue

        LIST.push_back(get(property["name"]))




func get_bb_container_data(battle_action: BattleAction, character: Character = null) -> BBContainerData:
    var bb_container_data = BBContainerData.new()

    bb_container_data.text = T.get_translated_string(battle_action.name, "Battle Action Name")
    bb_container_data.battle_action = battle_action
    bb_container_data.left_image = battle_action.icon
    bb_container_data.left_image_color = battle_action.color
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE

    if is_instance_valid(bb_container_data.left_image):
        bb_container_data.text = " " + bb_container_data.text

    return bb_container_data
