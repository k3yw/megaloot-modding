class_name SFXPlayer3D extends AudioStreamPlayer2D







func _process(_delta):
    if not playing:
        queue_free()
