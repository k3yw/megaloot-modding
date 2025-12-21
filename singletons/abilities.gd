extends Node

const DIR: String = "res://resources/abilities/"

var ASTRAL_DISSOLUTION: AbilityResource = load("res://resources/abilities/astral_dissolution.tres")
var NOXIOUS_EMPOWERMENT: AbilityResource = load("res://resources/abilities/noxious_empowerment.tres")
var PERSISTENT_PAYBACK: AbilityResource = load("res://resources/abilities/persistent_payback.tres")
var ENCHANTED_ATTACK: AbilityResource = load("res://resources/abilities/enchanted_attack.tres")
var MULTI_MAGIC_SHIELD: AbilityResource = load("res://resources/abilities/multi_magic_shield.tres")
var SHATTER_STRIKE: AbilityResource = load("res://resources/abilities/shatter_strike.tres")
var TRIPLE_ATTACK: AbilityResource = load("res://resources/abilities/triple_attack.tres")
var MULTI_CLEANSE: AbilityResource = load("res://resources/abilities/multi_cleanse.tres")
var CONFUSION_STRIKE: AbilityResource = load("res://resources/abilities/confusion_strike.tres")
var FROZEN_WIND: AbilityResource = load("res://resources/abilities/frozen_wind.tres")
var STUN_ATTACK: AbilityResource = load("res://resources/abilities/stun_attack.tres")
var HEADBUTT: AbilityResource = load("res://resources/abilities/headbutt.tres")
var STUN_STRIKE: AbilityResource = load("res://resources/abilities/stun_strike.tres")
var GALEFIRE: AbilityResource = load("res://resources/abilities/galefire.tres")
var SPELL_BIND: AbilityResource = load("res://resources/abilities/spell_bind.tres")
var DEATH_STRIKE: AbilityResource = load("res://resources/abilities/death_strike.tres")
var VENOM_SPIT: AbilityResource = load("res://resources/abilities/venom_spit.tres")
var DROP_OF_CHAOS: AbilityResource = load("res://resources/abilities/drop_of_chaos.tres")


var FEAR_OF_FAITH: AbilityResource = load("res://resources/abilities/fear_of_faith.tres")
var MIND_CONTROL: AbilityResource = load("res://resources/abilities/mind_control.tres")
var MULTI_SHIELD: AbilityResource = load("res://resources/abilities/multi_shield.tres")
var TOXIC_ATTACK: AbilityResource = load("res://resources/abilities/toxic_attack.tres")
var MULTI_HEAL: AbilityResource = load("res://resources/abilities/multi_heal.tres")
var SAFEGUARD: AbilityResource = load("res://resources/abilities/safeguard.tres")
var HARNESS: AbilityResource = load("res://resources/abilities/harness.tres")
var BARRIER: AbilityResource = load("res://resources/abilities/barrier.tres")
var PURIFY: AbilityResource = load("res://resources/abilities/purify.tres")

var REPULSE: AbilityResource = load("res://resources/abilities/repulse.tres")

var MANA_REGEN: AbilityResource = load("res://resources/abilities/mana_regen.tres")

var STEAL: AbilityResource = load("res://resources/abilities/steal.tres")



var LIST: Array[AbilityResource] = []



func _ready() -> void :
    File.load_resources(LIST, DIR)



func get_file_name(ability_resource: AbilityResource) -> String:
    return ability_resource.resource_path.replace(DIR, "").replace(".tres", "")


func get_bb_container_data(ability: AbilityResource, show_cost: bool = false) -> Array[BBContainerData]:
    var bb_container_data_arr: Array[BBContainerData] = []
    var bb_container_data = BBContainerData.new()

    bb_container_data_arr.push_back(bb_container_data)

    bb_container_data.text = T.get_translated_string(ability.name, "Ability Name")
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE
    bb_container_data.ability = ability


    if show_cost and ability.mana_cost:
        var mana_bb = Stats.get_bb_container_data(Stats.MANA)
        mana_bb.text = str(ability.mana_cost)
        mana_bb.right_image_color = Stats.MANA.color
        mana_bb.right_image = Stats.MANA.icon
        mana_bb.left_image = null

        bb_container_data_arr.push_back(BBContainerData.new(" (" + T.get_translated_string("Cost") + ": ", Color.WEB_GRAY))
        bb_container_data_arr.push_back(mana_bb)
        bb_container_data_arr.push_back(BBContainerData.new(")", Color.WEB_GRAY))


    return bb_container_data_arr
