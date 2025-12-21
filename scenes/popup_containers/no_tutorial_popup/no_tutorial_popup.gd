@tool
class_name NoTutorialPopup extends PopupContainer




@export var proceed_button: GenericButton




func _ready() -> void :
    proceed_button.pressed.connect( func():
        hide()
        )
