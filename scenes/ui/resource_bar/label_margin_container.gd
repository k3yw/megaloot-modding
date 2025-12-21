extends MarginContainer





func _notification(what: int) -> void :
    match what:
        NOTIFICATION_SORT_CHILDREN:
            resized.emit()
