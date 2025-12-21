class_name EnemyResource extends Resource


@export var name: String
@export var texture: Texture
@export var floor_number: int
@export var flying: bool

@export var starting_status_effects: Array[StartingStatusEffects] = []
@export var active_item_sets: Array[ItemSetResource] = []
@export var stats_per_level: Array[BonusStatsArray] = []
@export var base_stats: Array[BonusStat] = []


@export var abilities: Array[AbilityResource] = []
@export var passives: Array[Passive] = []
@export var is_unique: bool = false


@export var hide_stats: bool = false


func get_weight(curr_floor: int) -> float:
    return float(floor_number + 1) / float(curr_floor + 1)
