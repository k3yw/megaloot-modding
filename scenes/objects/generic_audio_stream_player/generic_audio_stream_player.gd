class_name GenericAudioStreamPlayer extends AudioStreamPlayer2D



var original_volume_db: float = 0.0
var origin_state_name: String = ""
var fade_out: bool = false



func _ready() -> void :
    volume_db = original_volume_db


func _process(delta: float) -> void :
    if not fade_out:
        volume_db = move_toward(volume_db, original_volume_db, delta * 12.75)
        return

    volume_db = move_toward(volume_db, -80.0, delta * 12.75)
