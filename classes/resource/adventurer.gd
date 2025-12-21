class_name Adventurer extends Resource



@export var name: StringName
@export var portrait: Texture2D
@export var blink: Texture2D

@export var specializations: Array[Specialization] = [Empty.specialization, Empty.specialization, Empty.specialization]
@export var starting_inventory_items: Array[ItemResource] = []
@export var challenge_market_items: Array[ItemResource] = []
@export var starting_market_items: Array[ItemResource] = []
@export var doubled_stat: StatResource
@export var ability: AbilityResource
@export var abilities_to_learn_size: int = 1
@export var passive: Passive

@export var chapters: Array[Chapter] = []

@export var bonus_stats: Array[BonusStat] = []


@export var sockets: Array[SocketType] = [
    SocketTypes.HELMET, 
    SocketTypes.CHESTPLATE, 
    SocketTypes.LEGGINGS, 
    SocketTypes.BOOTS, 
    SocketTypes.NECKLACE, 
    SocketTypes.WEAPON, 
    SocketTypes.RING, 
    SocketTypes.RING, 
    ]

var name_override: StringName
