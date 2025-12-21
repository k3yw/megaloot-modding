extends Node

const DIR: String = "res://resources/passives/"

var SPIRIT_OF_THE_UNBROKEN: Passive = load("res://resources/passives/spirit_of_the_unbroken.tres")
var EXPLOITED_OPPORTUNITY: Passive = load("res://resources/passives/exploited_opportunity.tres")
var MAGICAL_FROSTFLARE: Passive = load("res://resources/passives/magical_frostflare.tres")
var CONSUMING_DARKNESS: Passive = load("res://resources/passives/consuming_darkness.tres")
var CRYSTAL_HARDENING: Passive = load("res://resources/passives/crystal_hardening.tres")
var TOXIC_REDEMPTION: Passive = load("res://resources/passives/toxic_redemption.tres")
var POTENTIAL_SEEKER: Passive = load("res://resources/passives/potential_seeker.tres")
var GOLDEN_ALTRUISM: Passive = load("res://resources/passives/golden_altruism.tres")
var UNDEAD_BLESSING: Passive = load("res://resources/passives/undead_blessing.tres")
var SHADED_ESSENCE: Passive = load("res://resources/passives/shaded_essence.tres")
var JUDGMENTS_CALL: Passive = load("res://resources/passives/judgments_call.tres")
var ARCANE_CONTROL: Passive = load("res://resources/passives/arcane_control.tres")
var LUMINOUS_TRIAL: Passive = load("res://resources/passives/luminous_trial.tres")
var THUNDERSTRIKE: Passive = load("res://resources/passives/thunderstrike.tres")
var EDGE_OF_DEATH: Passive = load("res://resources/passives/edge_of_death.tres")
var UNDYING_CURSE: Passive = load("res://resources/passives/undying_curse.tres")
var FREEDOM_DRIVE: Passive = load("res://resources/passives/freedom_drive.tres")
var EMPTY_BASTION: Passive = load("res://resources/passives/empty_bastion.tres")
var FAULT_BREAKER: Passive = load("res://resources/passives/faultbreaker.tres")
var CINDER_TOUCH: Passive = load("res://resources/passives/cinder_touch.tres")
var FROZEN_HEART: Passive = load("res://resources/passives/frozen_heart.tres")
var ELDRIDS_FURY: Passive = load("res://resources/passives/eldrids_fury.tres")
var CURSED_CHAIN: Passive = load("res://resources/passives/cursed_chain.tres")
var FEAR_OF_PAIN: Passive = load("res://resources/passives/fear_of_pain.tres")
var WINDS_GRACE: Passive = load("res://resources/passives/winds_grace.tres")
var SHATTERWAVE: Passive = load("res://resources/passives/shatterwave.tres")
var PRIME_GUARD: Passive = load("res://resources/passives/prime_guard.tres")
var ALL_IS_MINE: Passive = load("res://resources/passives/all_is_mine.tres")
var MANA_STEAL: Passive = load("res://resources/passives/mana_steal.tres")
var ABSOLUTION: Passive = load("res://resources/passives/absolution.tres")
var LIBERATION: Passive = load("res://resources/passives/liberation.tres")
var TOXSHIELD: Passive = load("res://resources/passives/toxshield.tres")
var EVIL_MARK: Passive = load("res://resources/passives/evil_mark.tres")
var MANAFLOW: Passive = load("res://resources/passives/manaflow.tres")
var IRONCLAD: Passive = load("res://resources/passives/ironclad.tres")
var EMULATOR: Passive = load("res://resources/passives/emulator.tres")
var ESCAPE: Passive = load("res://resources/passives/escape.tres")



var LIST: Array[Passive] = []


func _ready() -> void :
    File.load_resources(LIST, DIR)



func get_bb_container_data(passive: Passive) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.text = T.get_translated_string(passive.name, "Passive Name")
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE
    bb_container_data.ref_objects.push_back(passive)

    return bb_container_data
