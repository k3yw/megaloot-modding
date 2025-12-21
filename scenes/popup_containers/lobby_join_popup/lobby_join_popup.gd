@tool
class_name LobbyJoinPopup extends PopupContainer


@export var line_edit: GenericLineEdit
@export var join_button: GenericButton





func show_as_password() -> void :
    line_edit.line_edit.placeholder_text = T.get_translated_string("enter-password") + "..."
    PopupManager.pop(self)


func show_as_ip() -> void :
    line_edit.line_edit.placeholder_text = T.get_translated_string("enter-ip") + "..."
    PopupManager.pop(self)
