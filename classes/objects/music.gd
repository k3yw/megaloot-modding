class_name Music extends RefCounted






var stream: AudioStream

var fade_speed: float
var volume_db: float
var delay: float
var sync: bool

var crossfade: bool = true




func _init(_stream: AudioStream, _volume_db: float = 0.0, _fade_speed: float = 0.0, _delay: float = 0.0) -> void :
    fade_speed = _fade_speed
    volume_db = _volume_db
    stream = _stream
    delay = _delay
