class_name StatResource extends Resource




@export var name: String
@export var icon: Texture2D
@export var color: Color
@export var is_attack_type: bool = false
@export var is_percentage: bool = false
@export var max_amount: int = -1
@export var origin_stat: StatResource

@export var ignore_minimum_amount: bool = false
@export var minimum_amount: float = 0.0

@export var stat_script: GDScript
@export var bb_script: GDScript
