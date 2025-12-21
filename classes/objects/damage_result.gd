class_name DamageResult extends Object





var attacker: CharacterReference = CharacterReference.new()
var target: CharacterReference = CharacterReference.new()

var result_type: BattleAction = BattleAction.new()
var damage_type: StatResource = StatResource.new()


var take_damage: bool = true

var source: DamageData.Source

var initial_damage: float
var direct_damage: float

var uncapped_total_damage: float
var armor_removed: float
var total_damage: float

var penetration: float
var life_steal: float
var is_lucky: bool
var is_crit: bool



func _init(arg_target: CharacterReference = null, arg_attacker: CharacterReference = null, arg_damage_type: StatResource = null) -> void :
    if is_instance_valid(arg_damage_type):
        damage_type = arg_damage_type

    if is_instance_valid(arg_target):
        target = arg_target

    if is_instance_valid(arg_attacker):
        attacker = arg_attacker


static func get_ref(character_ref) -> Character:
    if is_instance_valid(character_ref):
        return (character_ref as CharacterReference)._ref
    return null


func cleanup() -> void :
    attacker.free()
    target.free()
