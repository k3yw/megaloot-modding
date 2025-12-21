class_name StatLabelContiner extends HBoxContainer



@export var icon_texture_rect: TextureRect
@export var multiplier_value_container: HBoxContainer
@export var final_value_label: GenericLabel
@export var multiplier_label: GenericLabel
@export var base_value_label: GenericLabel
@export var name_label: GenericLabel

var stat: StatResource




func _process(_delta: float) -> void :
    multiplier_value_container.visible = multiplier_label.curr_value


func update(arg_stat: StatResource) -> void :
    name_label.text = T.get_translated_string(arg_stat.name, "Stat Name")
    final_value_label.is_percent = arg_stat.is_percentage
    icon_texture_rect.texture = arg_stat.icon
    stat = arg_stat
