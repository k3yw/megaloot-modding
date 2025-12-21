class_name SmallResourceBar extends MarginContainer





@export var progress_bar: ProgressBar



func _process(_delta: float) -> void :
    match progress_bar.max_value:
        40.0: custom_minimum_size.x = 31
        30.0: custom_minimum_size.x = 24
        20.0: custom_minimum_size.x = 17
        10.0: custom_minimum_size.x = 10
