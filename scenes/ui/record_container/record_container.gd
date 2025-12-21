@tool
class_name RecordContainer extends MarginContainer



@export var place_label: GenericLabel
@export var time_label: GenericLabel
@export var name_label: GenericLabel

@export var color: GlobalColors.Type: set = set_color
@export var is_info: bool = false


func _ready() -> void :
    if is_info:
        place_label.text = "#"
        return
    place_label.text = str(get_parent().get_children().find(self) + 1)


func set_color(value: GlobalColors.Type) -> void :
    color = value
    update_color()


func update_color() -> void :
    if is_instance_valid(name_label):
        name_label.set_text_color(color)

    if is_instance_valid(time_label):
        time_label.set_text_color(color)

    if is_instance_valid(place_label):
        place_label.set_text_color(color)
