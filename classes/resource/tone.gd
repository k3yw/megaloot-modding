class_name Tone extends Resource



@export var audio: AudioStream
@export var volume_db: float

@export var pitch_min: float = 1.0
@export var pitch_max: float = 1.0





func _init(_audio: AudioStream, _volume_db: float = 0.0) -> void :
    volume_db = _volume_db
    audio = _audio
