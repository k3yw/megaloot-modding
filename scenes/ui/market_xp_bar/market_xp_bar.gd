class_name MarketXPBar extends ProgressBar


@onready var target_value: float = value



func _process(delta: float) -> void :
    value = move_toward(value, target_value, delta * max_value)
