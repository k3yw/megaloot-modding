class_name RecordsContainer extends MarginContainer


@export var info_record_container: RecordContainer
@export var record_holder: VBoxContainer
@export var loading_animation: Control
@export var category_holder: HBoxContainer

var options: Options = null

func _ready() -> void :
    OptionsManager.options_loaded.connect( func(): options = OptionsManager.options)


func clear() -> void :
    for child in record_holder.get_children():
        record_holder.remove_child(child)
        child.queue_free()



func update(adventurer: Adventurer) -> void :
    if options.selected_speedrun_category.is_empty():
        options.selected_speedrun_category = Leaderboards.list.keys()[0]

    reset_category_buttons()
    update_category_buttons()

    loading_animation.hide()

    for record in Leaderboards.list[options.selected_speedrun_category][adventurer].records:
        var color: GlobalColors.Type = GlobalColors.Type.PRIMARY_COLOR



        if record.user_id == Net.speedrun_auth.id:
            color = GlobalColors.Type.HIGHLIGHT_COLOR

        add_record(record.username, record.time, color)


func reset_category_buttons() -> void :
    for child in category_holder.get_children():
        category_holder.remove_child(child)
        child.queue_free()

    for category in Leaderboards.list:
        var category_button: GenericButton = preload("res://scenes/ui/flat_generic_button/flat_generic_button.tscn").instantiate()
        category_button.custom_minimum_size.x = 100
        category_holder.add_child(category_button)
        category_button.text = category

        category_button.pressed.connect( func():
            options.selected_speedrun_category = category_button.text
            update_category_buttons()
            )


func update_category_buttons() -> void :
    for child in category_holder.get_children():
        if child is GenericButton:
            child.disabled = true
            if child.text == options.selected_speedrun_category:
                continue

            child.disabled = false



func add_record(player_name: String, time: int, color: GlobalColors.Type) -> RecordContainer:
    var record_container: RecordContainer = preload("res://scenes/ui/record_container/record_container.tscn").instantiate()
    record_container.time_label.text = Format.to_seconds(time)
    record_container.name_label.text = player_name
    record_holder.add_child(record_container)

    record_container.set_color(color)

    return record_container
