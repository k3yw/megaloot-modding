class_name ProfileState extends Node



@export var adventurer_button_grid: GridContainer
@export var back_button: GenericButton


var sorted_adventureres: Array[Adventurer] = []



func _ready() -> void :
    update_adventurers()




func _process(_delta: float) -> void :
    for idx in adventurer_button_grid.get_child_count():
        var adventurer_button: AdventurerButton = adventurer_button_grid.get_child(idx)

        if not adventurer_button.is_pressed:
            continue

        var adventurer: Adventurer = sorted_adventureres[idx]
        PopupManager.pop(PopupManager.adventurer_profile_popup)

        PopupManager.adventurer_profile_popup.update_all(adventurer)





func update_adventurers() -> void :
    for adventurer in Adventurers.LIST:
        sorted_adventureres.push_back(adventurer)

    sorted_adventureres.sort_custom(Sort.adventurer_by_name)

    for adventurer in sorted_adventureres:
        var border_type: AdventurerBorder.Type = AdventurerBorder.get_type(adventurer, UserData.profile.get_floor_record(adventurer))

        var adventurer_button: AdventurerButton = preload("res://scenes/ui/adventurer_button/adventurer_button.tscn").instantiate()
        adventurer_button.border_texture_rect.texture = AdventurerBorder.get_texture(border_type)
        adventurer_button.set_adventurer(adventurer)
        adventurer_button_grid.add_child(adventurer_button)
