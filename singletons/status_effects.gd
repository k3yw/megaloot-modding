extends Node

const DIR: String = "res://resources/status_effects/"

var ENERVATION: StatusEffectResource = load("res://resources/status_effects/enervation.tres")
var WEAKNESS: StatusEffectResource = load("res://resources/status_effects/weakness.tres")
var BLACK_CURSE: StatusEffectResource = load("res://resources/status_effects/black_curse.tres")
var CURSE: StatusEffectResource = load("res://resources/status_effects/curse.tres")


var STUN: StatusEffectResource = load("res://resources/status_effects/stun.tres")
var SLOWNESS: StatusEffectResource = load("res://resources/status_effects/slowness.tres")
var CONFUSION: StatusEffectResource = load("res://resources/status_effects/confusion.tres")
var SILENCE: StatusEffectResource = load("res://resources/status_effects/silence.tres")

var TOXIC_TRANSMUTE: StatusEffectResource = load("res://resources/status_effects/toxic_transmute.tres")
var POISON: StatusEffectResource = load("res://resources/status_effects/poison.tres")
var BLEED: StatusEffectResource = load("res://resources/status_effects/bleed.tres")

var SPARKLE: StatusEffectResource = load("res://resources/status_effects/sparkle.tres")
var MAGIC_SHIELD: StatusEffectResource = load("res://resources/status_effects/magic_shield.tres")
var EPHEMERAL_ARMOR: StatusEffectResource = load("res://resources/status_effects/ephemeral_armor.tres")
var EPHEMERAL_SHELL: StatusEffectResource = load("res://resources/status_effects/ephemeral_shell.tres")
var ELECTRO_CHARGE: StatusEffectResource = load("res://resources/status_effects/electro_charge.tres")
var EPHEMERAL_LOCK: StatusEffectResource = load("res://resources/status_effects/ephemeral_lock.tres")
var EXHAUSTION: StatusEffectResource = load("res://resources/status_effects/exhaustion.tres")
var MALICE_SHIELD: StatusEffectResource = load("res://resources/status_effects/malice_shield.tres")
var ARMOR_SHIELD: StatusEffectResource = load("res://resources/status_effects/armor_shield.tres")
var FREEZE: StatusEffectResource = load("res://resources/status_effects/freeze.tres")
var FEAR: StatusEffectResource = load("res://resources/status_effects/fear.tres")

var INVULNERABILITY: StatusEffectResource = load("res://resources/status_effects/invulnerability.tres")
var INHERITED_SIN: StatusEffectResource = load("res://resources/status_effects/inherited_sin.tres")
var ARTHURS_MARK: StatusEffectResource = load("res://resources/status_effects/arthurs_mark.tres")
var TIMEOUT: StatusEffectResource = load("res://resources/status_effects/timeout.tres")

var CINDER_ESSENCE: StatusEffectResource = load("res://resources/status_effects/cinder_essence.tres")
var COMBAT_INSIGHT: StatusEffectResource = load("res://resources/status_effects/combat_insight.tres")
var MAGIC_BLITZ: StatusEffectResource = load("res://resources/status_effects/magic_blitz.tres")
var OMNI_BLITZ: StatusEffectResource = load("res://resources/status_effects/omni_blitz.tres")
var VIMBLOW: StatusEffectResource = load("res://resources/status_effects/vimblow.tres")
var DREAD: StatusEffectResource = load("res://resources/status_effects/dread.tres")
var FURY: StatusEffectResource = load("res://resources/status_effects/fury.tres")

var COUNTER_ATTACK_CHARGE: StatusEffectResource = load("res://resources/status_effects/counter_attack_charge.tres")
var MULTI_ATTACK_CHARGE: StatusEffectResource = load("res://resources/status_effects/multi_attack_charge.tres")
var STUN_ATTACK_CHARGE: StatusEffectResource = load("res://resources/status_effects/stun_attack_charge.tres")
var DEBUFF_IMMUNITY: StatusEffectResource = load("res://resources/status_effects/debuff_immunity.tres")
var GOLDEN_HEART: StatusEffectResource = load("res://resources/status_effects/golden_heart.tres")
var GOLDEN_LOCK: StatusEffectResource = load("res://resources/status_effects/golden_lock.tres")
var LETHALITY: StatusEffectResource = load("res://resources/status_effects/lethality.tres")
var MADNESS: StatusEffectResource = load("res://resources/status_effects/madness.tres")
var FOCUSED: StatusEffectResource = load("res://resources/status_effects/focused.tres")
var BLINDNESS: StatusEffectResource = load("res://resources/status_effects/blindness.tres")
var CLARITY: StatusEffectResource = load("res://resources/status_effects/clarity.tres")
var ELUSIVE: StatusEffectResource = load("res://resources/status_effects/elusive.tres")


var PURIFICATION: StatusEffectResource = load("res://resources/status_effects/purification.tres")
var GRACE: StatusEffectResource = load("res://resources/status_effects/grace.tres")

var CURSE_OF_THE_TOWER: StatusEffectResource = load("res://resources/status_effects/curse_of_the_tower.tres")

var BLUE_TEAM: StatusEffectResource = load("res://resources/status_effects/blue_team.tres")
var RED_TEAM: StatusEffectResource = load("res://resources/status_effects/red_team.tres")

var LIST: Array[StatusEffectResource] = []


var CHAOS: Array[StatusEffectResource] = [
    COUNTER_ATTACK_CHARGE, 
    MULTI_ATTACK_CHARGE, 
    STUN_ATTACK_CHARGE, 
    DEBUFF_IMMUNITY, 
    EPHEMERAL_SHELL, 
    CINDER_ESSENCE, 
    EXHAUSTION, 
    INHERITED_SIN, 
    ENERVATION, 
    WEAKNESS, 
    DREAD, 
    CURSE, 
    MADNESS, 
    SLOWNESS, 
    CONFUSION, 
    CLARITY, 
    SILENCE, 
    POISON, 
    SPARKLE, 
    FEAR, 
    GRACE, 
    BLINDNESS, 
    FOCUSED, 
    EPHEMERAL_ARMOR, 
    INVULNERABILITY, 
    COMBAT_INSIGHT, 
    GOLDEN_HEART, 
    ARTHURS_MARK, 
    MAGIC_BLITZ, 
    VIMBLOW, 
    MALICE_SHIELD, 
    ARMOR_SHIELD, 
    FURY, 
]




var IMPACT_HEALTH: Array[StatusEffectResource] = [
    GOLDEN_HEART, 
    POISON, 
    CURSE, 
]





func _ready() -> void :
    for property in get_property_list():
        if not property["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE:
            continue

        if not property["type"] == TYPE_OBJECT:
            continue

        LIST.push_back(get(property["name"]))




func get_debuffs() -> Array[StatusEffectResource]:
    var debuffs: Array[StatusEffectResource] = []


    for status_effect in LIST:
        if not status_effect.type == StatusEffectTypes.DEBUFF:
            continue

        debuffs.push_back(status_effect)


    return debuffs



func get_random_status_effect(rand: RandomNumberGenerator, types: Array[StatusEffectType] = []) -> StatusEffectResource:
    var status_effects: Array[StatusEffectResource] = []

    if not types.is_empty():
        status_effects.clear()

    for status_effect in LIST:
        if not types.has(status_effect.type):
            continue
        status_effects.push_back(status_effect)

    return status_effects[RNGManager.pick_random(rand, status_effects.size())]



func get_chaos_status_effects() -> Array[StatusEffectResource]:
    return LIST




func has_active_status_effect_resource(arr_ref: Array[StatusEffect], status_effect_resource: StatusEffectResource) -> bool:
    for status_effect in arr_ref:
        if not is_instance_valid(status_effect):
            continue

        if not is_instance_valid(status_effect.resource):
            continue

        if status_effect.resource == status_effect_resource:
            return true

    return false


func modify_resource(character: Character, status_effect_resource: StatusEffectResource) -> StatusEffectResource:
    if not is_instance_valid(character):
        return status_effect_resource

    if character.get_active_item_sets().has(ItemSets.SHADOW):
        if status_effect_resource == StatusEffects.MAGIC_BLITZ:
            return StatusEffects.OMNI_BLITZ

    return status_effect_resource





func get_bb_container_data(status_effect_resource: StatusEffectResource, amount: float = 0.0, is_percentage: bool = false) -> Array[BBContainerData]:
    var bb_container_data = BBContainerData.new()
    bb_container_data.text = " " + T.get_translated_string(status_effect_resource.name, "Status Effect Name")
    bb_container_data.left_image = status_effect_resource.icon
    bb_container_data.left_image_color = status_effect_resource.color
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE
    bb_container_data.status_effect_resource = status_effect_resource

    if amount:
        var formula_bb_container = BBContainerData.new()
        formula_bb_container.text_color = status_effect_resource.color
        var amount_str: String = str(amount)

        if amount == -1:
            amount_str = "?"

        if is_percentage:
            amount_str = amount_str + "%"

        formula_bb_container.text = "(" + amount_str + ")"

        return [formula_bb_container, bb_container_data]

    return [bb_container_data]
