class_name ChatPopupContainer extends PopupContainer


func _ready() -> void :
    hide()




func _process(_delta: float) -> void :
    container.position.y = roundi(container.position.y)
