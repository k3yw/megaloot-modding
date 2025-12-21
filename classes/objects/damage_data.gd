class_name DamageData extends Object

enum Source{
    LIFE_FOR_POWER_BLOOD_SLASH, 
    CURSE_OF_THE_TOWER, 
    TOXIC_REDEMPTION, 
    COUNTER_ATTACK, 
    VENGEFUL_EDGE, 
    BLOODCASTER, 
    ELECTRICITY, 
    SHATTERWAVE, 
    VAMPIERCER, 
    CHROMALURE, 
    BLACKTHORN, 
    CURSED_SET, 
    LETHALITY, 
    IRON_PACT, 
    BLACKROT, 
    BASTOLIC, 
    ZEPHYRON, 
    BACKSTAB, 
    PASSIVE, 
    POISON, 
    ATTACK, 
    FREEZE, 
    CINDER, 
    MALICE, 
    DAZZLE, 
    PARRY, 
    BLEED, 
}

const HIT_SOURCES: Array[Source] = [
    Source.COUNTER_ATTACK, 
    Source.BACKSTAB, 
    Source.ATTACK, 
    Source.PARRY
]

var status_effects_on_hit: Array[StatusEffect] = []

var damage: float = 0.0
var is_crit: bool = false

var penetration: float = 0.0
var accuracy: float = 0.0

var unavoidable: bool = false
var is_lucky: bool = false
var missed: bool = false
var pure: bool = false

var type: StatResource
var source: Source

var crit_damage_percent: int





func _init(arg_source: Source, arg_type: StatResource, arg_damage: float) -> void :
    source = arg_source
    damage = arg_damage
    type = arg_type





func activate_damage_boosters(attacker: Character, target: Character) -> void :
    var attackers_item_sets: Array[ItemSetResource] = attacker.get_active_item_sets()
    var grace_multiplier: float = 1.0 + (attacker.battle_profile.get_status_effect_amount(StatusEffects.GRACE) * 0.01)
    var attackers_elemental_boost: float = 1.0

    if is_instance_valid(attacker):
        if is_crit:
            var crit_multiplier: float = (attacker.get_stat_amount(Stats.CRITICAL_DAMAGE)[0] + 100.0) * 0.01
            damage += ceilf(damage * crit_multiplier)


    apply_multiplier(grace_multiplier)









func apply_multiplier(amount: float) -> void :
    if amount == 0.0:
        damage = 0.0
        return

    if is_equal_approx(damage, 0.0):
        return

    if type == Stats.TRUE_DAMAGE or pure:
        return

    var operation: Math.Operation = Math.Operation.ROUND_UP

    if amount < 1.0:
        operation = Math.Operation.ROUND_DOWN

    match operation:
        Math.Operation.ROUND_DOWN: damage = floorf(damage * amount)
        Math.Operation.ROUND_UP: damage = ceilf(damage * amount)

    if not amount:
        damage = 0.0





func get_status_effects_on_land() -> Array[StatusEffect]:
    var status_effects_on_land: Array[StatusEffect] = []

    return status_effects_on_land
