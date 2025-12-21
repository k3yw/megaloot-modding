class_name SliderOption extends HBoxContainer


@export var value_label: GenericLabel
@export var name_label: GenericLabel
@export var h_slider: GenericHSlider

@export var show_value: bool
@export var rule: String




func _ready() -> void :
    value_label.visible = show_value




func value_changed() -> bool:
    value_label.text = str(h_slider.value)
    if rule.length():
        value_label.text = rule % h_slider.value

    return h_slider.value_changed
