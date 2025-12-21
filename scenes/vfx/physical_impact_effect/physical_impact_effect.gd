extends AnimatedEffect


func _ready() -> void :
    super._ready()
    rotation_degrees = randi_range(-360, 360)
