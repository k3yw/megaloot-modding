class_name ToneEventResource extends Resource

enum SpaceType{NONE, _2D, _3D}

@export var tones: Array[Tone] = []
@export var default_cooldown: float
@export var delay_min: float
@export var delay_max: float
@export var stackable: bool

@export var space_type: SpaceType
@export var position: Vector2
