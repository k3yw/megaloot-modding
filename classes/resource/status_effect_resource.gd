class_name StatusEffectResource extends Resource


@export var name: String
@export var icon: Texture2D
@export var color: Color
@export var type: StatusEffectType = StatusEffectTypes.DEBUFF
@export var affected_by_tenacity: bool = false
@export var is_temporary: bool = false
@export var is_percent: bool = false
@export var limit: int = 1

@export var application_message: String
@export var application_sound: AudioStream

@export var bb_script: GDScript
