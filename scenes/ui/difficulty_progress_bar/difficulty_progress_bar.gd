class_name DifficultyProgressBar extends GenericMarginContainer

@export var current_battle_container: HBoxContainer
@export var floor_number_label: GenericLabel
@export var rooms_left_label: GenericLabel

@export var battle_container: PanelContainer
@export var bar_container: HBoxContainer


var updating: bool = false




func set_floor(floor_number: int, max_floor: int) -> void :
    var floor_txt: String = str(floor_number)
    var max_floor_txt: String = " |" + str(max_floor)

    current_battle_container.show()

    if max_floor == -1:
        max_floor_txt = ""

    if floor_number >= 999:
        floor_txt = "X"

    floor_number_label.text = floor_txt + max_floor_txt

    if floor_number > max_floor and not max_floor == -1:
        floor_number_label.text = T.get_translated_string("final-floor").to_upper()
        current_battle_container.hide()



func set_remaining_rooms(remaining_rooms: int) -> void :
    rooms_left_label.text = str(remaining_rooms)
