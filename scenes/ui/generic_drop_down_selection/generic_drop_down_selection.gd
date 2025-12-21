class_name GenericDropDownSelection extends MarginContainer



@export var background_color_rect: ColorRect
@export var name_label: GenericLabel

var original_name: String


func _ready() -> void :
    original_name = name_label.text
    reload_label()




func reload_label() -> void :
    name_label.text = T.get_translated_string(original_name, "Drop Down Selection")
