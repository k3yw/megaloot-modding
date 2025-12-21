extends Node


enum DisplayMode{NORMAL, AMOUNT, UNKNOWN}

const STATS_DIR: String = "res://resources/stats/"


var TRUE_DAMAGE: StatResource = load("res://resources/stats/true_damage.tres")
var PHYSICAL_DAMAGE: StatResource = load("res://resources/stats/physical_damage.tres")
var ELECTRIC_DAMAGE: StatResource = load("res://resources/stats/electric_damage.tres")
var POISON_DAMAGE: StatResource = load("res://resources/stats/poison_damage.tres")
var FREEZE_DAMAGE: StatResource = load("res://resources/stats/freeze_damage.tres")
var ARMOR_DAMAGE: StatResource = load("res://resources/stats/armor_damage.tres")
var DAZZLE_DAMAGE: StatResource = load("res://resources/stats/dazzle_damage.tres")
var MALICE_DAMAGE: StatResource = load("res://resources/stats/malice_damage.tres")
var CINDER_DAMAGE: StatResource = load("res://resources/stats/cinder_damage.tres")
var MAGIC_DAMAGE: StatResource = load("res://resources/stats/magic_damage.tres")
var BLEED_DAMAGE: StatResource = load("res://resources/stats/bleed_damage.tres")
var BLACKROT_DAMAGE: StatResource = load("res://resources/stats/blackrot_damage.tres")



var OMNI_CRIT_CHANCE: StatResource = load("res://resources/stats/omni_crit_chance.tres")
var CRITICAL_DAMAGE: StatResource = load("res://resources/stats/critical_damage.tres")
var PENETRATION: StatResource = load("res://resources/stats/penetration.tres")
var ELDERSHIP: StatResource = load("res://resources/stats/eldership.tres")


var ARMOR: StatResource = load("res://resources/stats/armor.tres")
var MAX_HEALTH: StatResource = load("res://resources/stats/max_health.tres")
var MAX_MANA: StatResource = load("res://resources/stats/max_mana.tres")
var RECOVERY: StatResource = load("res://resources/stats/recovery.tres")


var POWER: StatResource = load("res://resources/stats/power.tres")

var ADAPTIVE_ATTACK: StatResource = load("res://resources/stats/adaptive_attack.tres")
var PHYSICAL_ATTACK: StatResource = load("res://resources/stats/physical_attack.tres")
var MAGIC_ATTACK: StatResource = load("res://resources/stats/magic_attack.tres")
var FREEZE_ATTACK: StatResource = load("res://resources/stats/freeze_attack.tres")
var ARMORED_ATTACK: StatResource = load("res://resources/stats/armored_attack.tres")

var COMBAT: StatResource = load("res://resources/stats/combat.tres")
var WISDOM: StatResource = load("res://resources/stats/wisdom.tres")
var FAITH: StatResource = load("res://resources/stats/faith.tres")
var MALICE: StatResource = load("res://resources/stats/malice.tres")
var TOXICITY: StatResource = load("res://resources/stats/toxicity.tres")
var ARMOR_STEAL: StatResource = load("res://resources/stats/armor_steal.tres")
var LIFE_STEAL: StatResource = load("res://resources/stats/life_steal.tres")
var OMNI_VAMP: StatResource = load("res://resources/stats/omni_vamp.tres")
var DAZZLE: StatResource = load("res://resources/stats/dazzle.tres")
var ELECTRICITY: StatResource = load("res://resources/stats/electricity.tres")
var ELEMENTAL_POWER: StatResource = load("res://resources/stats/elemental_power.tres")
var LUCK: StatResource = load("res://resources/stats/luck.tres")

var TOUGHNESS: StatResource = load("res://resources/stats/toughness.tres")
var AGILITY: StatResource = load("res://resources/stats/agility.tres")



var ACTIVE_ARMOR: StatResource = load("res://resources/stats/active_armor.tres")
var LETHALITY: StatResource = load("res://resources/stats/lethality.tres")
var HEALTH: StatResource = load("res://resources/stats/health.tres")
var MANA: StatResource = load("res://resources/stats/mana.tres")
var DIAMOND: StatResource = load("res://resources/stats/diamond.tres")
var GOLD: StatResource = load("res://resources/stats/gold.tres")

var GOLD_ON_KILL: StatResource = load("res://resources/stats/gold_on_kill.tres")
var GREED: StatResource = load("res://resources/stats/greed.tres")


var ELEMENTAL_RESISTANCE: StatResource = load("res://resources/stats/elemental_resistance.tres")
var TOTAL_ATTACKS: StatResource = load("res://resources/stats/total_attacks.tres")
var ARMOR_SHIELDS: StatResource = load("res://resources/stats/armor_shields.tres")
var CRIT_CHANCE: StatResource = load("res://resources/stats/crit_chance.tres")
var ACCURACY: StatResource = load("res://resources/stats/accuracy.tres")
var SPELLDOM: StatResource = load("res://resources/stats/spelldom.tres")
var TENACITY: StatResource = load("res://resources/stats/tenacity.tres")

var RANDOM_STAT: StatResource = load("res://resources/stats/random_stat.tres")
var FLOW: StatResource = load("res://resources/stats/flow.tres")


var TRANSFORMED_STATS: Array[StatResource] = []
var LIST: Array[StatResource] = []


var ELEMENTAL_DAMAGE: Array[StatResource] = [
    ELECTRIC_DAMAGE, 
    POISON_DAMAGE, 
    CINDER_DAMAGE, 
    FREEZE_DAMAGE, 
    ]

var PENALTY_DAMAGE: Array[StatResource] = [
    POISON_DAMAGE, 
    BLACKROT_DAMAGE, 
    TRUE_DAMAGE
    ]

var BASE_REFORGE: Array[StatResource] = [
    TOTAL_ATTACKS, 
    ARMOR_SHIELDS, 
    GOLD_ON_KILL, 
]

var ENEMY_UPGRADE_FILTER: Array[StatResource] = [
    GOLD_ON_KILL, 
    ]

var MAIN_DISPLAY: Array[StatResource] = [
    AGILITY, 
    FAITH, 

]


var DISPLAY: Array[StatResource] = [
    MAX_HEALTH, 
    TOTAL_ATTACKS, 
    PHYSICAL_ATTACK, 
    ACCURACY, 
    MAGIC_ATTACK, 
    ARMORED_ATTACK, 
    ARMOR, 
    CRIT_CHANCE, 
    GOLD_ON_KILL, 
    CRITICAL_DAMAGE, 
    POWER, 
    COMBAT, 
    PENETRATION, 
    WISDOM, 
    SPELLDOM, 
    FAITH, 
    RECOVERY, 
    ARMOR_SHIELDS, 
    ARMOR_STEAL, 
    LIFE_STEAL, 
    MALICE, 
    TOXICITY, 
    DAZZLE, 
    FREEZE_ATTACK, 
    ELECTRICITY, 
    ELEMENTAL_RESISTANCE, 
    ELEMENTAL_POWER, 
    ADAPTIVE_ATTACK, 
    TOUGHNESS, 
    LETHALITY, 
    TENACITY, 
    AGILITY, 
    GREED, 
    LUCK, 
]




func _ready() -> void :
    File.load_resources(LIST, STATS_DIR)
    for stat in LIST:
        if is_instance_valid(stat.origin_stat):
            TRANSFORMED_STATS.push_back(stat)




func get_amount_from_rarity(base_amount: float, rarity: int) -> float:
    return base_amount * (rarity + 1)



func get_bb_container_data(stat_resource: StatResource, display_mode: DisplayMode = DisplayMode.NORMAL, amount: float = 0.0) -> BBContainerData:
    var bb_container_data = BBContainerData.new()

    bb_container_data.text = " " + T.get_translated_string(stat_resource.name, "Stat Name")
    bb_container_data.stat_resource = stat_resource
    bb_container_data.left_image = stat_resource.icon
    bb_container_data.left_image_color = stat_resource.color
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE

    if not is_instance_valid(stat_resource.bb_script):
        bb_container_data.text_color = stat_resource.color

    if not display_mode == DisplayMode.NORMAL:
        bb_container_data.right_image = stat_resource.icon
        bb_container_data.right_image_color = stat_resource.color
        bb_container_data.text_color = stat_resource.color
        bb_container_data.left_image = null
        bb_container_data.is_value = true

        var amount_str: String = Format.number(amount, [Format.Rules.USE_SUFFIX])

        bb_container_data.text = ""

        if display_mode == DisplayMode.UNKNOWN:
            amount_str = "?"

        if stat_resource.is_percentage:
            amount_str = amount_str + "%"

        bb_container_data.text = "(" + amount_str + ")"

    return bb_container_data
