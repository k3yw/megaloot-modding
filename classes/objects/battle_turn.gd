class_name BattleTurn extends RefCounted

enum Type{
    ATTACK, 
    ABILITY_0, 
    ABILITY_1, 
    ABILITY_2, 
    STANCE, 
    }

var received_status_effects: Array[StatusEffect] = []
var applied_status_effects: Array[StatusEffect] = []
var cleansed_debuffs: Array[StatusEffect] = []
var consumed_stacks: Array[StatusEffect] = []

var stopped_attacking: bool = false

var abilities: Array[Ability] = []
var stats: Array[Stat] = []

var health_damage_taken: float = 0.0
var armor_damage_taken: float = 0.0

var hits_received: Array[HitData] = []

var magic_shields_broke_on_self: int = 0

var percent_health_recovered: float = 0.0
var ability_activation_count: int = 0
var health_recovered: float = 0.0
var counter_attacks: int = 0
var attack_cycles: int = 0
var backstabs: int = 0
var parries: int = 0
var attacks: int = 0
var misses: int = 0
var dodges: int = 0
var kills: int = 0

var attack_type: StatResource = Empty.stat_resource
var type: Type = Type.ATTACK



func is_used_ability(ability_resource: AbilityResource) -> bool:
    for ability in abilities:
        if not is_instance_valid(ability):
            continue
        if ability.resource == ability_resource:
            return true
    return false


func get_consumed_stacks() -> Array[StatusEffect]:
    var valid_consumed_stacks: Array[StatusEffect] = []

    for status_effect in consumed_stacks:
        if not is_instance_valid(status_effect):
            continue
        valid_consumed_stacks.push_back(status_effect)

    return valid_consumed_stacks




func cleanup() -> void :
    for stat in stats:
        if not is_instance_valid(stat):
            continue
        stat.free()

    for hit_data in hits_received:
        if not is_instance_valid(hit_data):
            continue
        hit_data.free()
