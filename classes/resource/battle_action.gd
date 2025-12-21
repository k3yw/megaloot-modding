class_name BattleAction extends Resource



@export var name: String
@export var icon: Texture2D
@export var color: Color

@export var use_limit: int

@export var popup_color: Color
@export var popup_text: String
@export var popup_delay: float

@export var screen_shake: bool = true

@export var bb_script: GDScript

func get_action_popup_label_data() -> PopupLabelData:
    var new_popup_text: String = T.get_translated_string(popup_text, "popup").to_upper()
    return PopupLabelData.new(new_popup_text, popup_color)
