class_name Specialization extends Resource



@export var name: String
@export var color: Color

@export var original_item_set: ItemSetResource
@export var synergy_item_set: ItemSetResource


func get_color() -> Color:
    if is_instance_valid(synergy_item_set):
        return synergy_item_set.color
    return color
