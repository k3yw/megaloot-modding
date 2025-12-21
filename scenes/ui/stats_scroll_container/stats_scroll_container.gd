class_name StatsScrollContainer extends MarginContainer


@export var scroll_container: GenericScrollContainer
@export var search_line_edit: GenericLineEdit
@export var stats_holder: AnimatedBoxContainer
var stat_labels: Dictionary = {}



func _ready() -> void :
    visibility_changed.connect( func(): sort())



func add_stat(stat: StatResource) -> void :
    var stat_label_container: StatLabelContiner = preload("res://scenes/ui/stat_label_container/stat_label_container.tscn").instantiate()
    stats_holder.add_child(stat_label_container)
    stat_labels[stat] = stat_label_container
    stat_label_container.update(stat)
    stat_label_container.final_value_label.update_value(1, true)



func get_stat(stat: StatResource) -> StatLabelContiner:
    if not is_instance_valid(stat_labels[stat]):
        return null

    return stat_labels[stat] as StatLabelContiner



func _process(_delta: float) -> void :
    sort()


func sort() -> void :
    var child_count: int = stats_holder.get_child_count()
    for idx in range(0, child_count - 1):
        var child: Node = stats_holder.get_child(idx)

        if child is StatLabelContiner:
            var next_child: Node = stats_holder.get_child(idx + 1)

            if next_child is StatLabelContiner:
                if child.final_value_label.target_value >= next_child.final_value_label.target_value:
                    continue

                stats_holder.move_child(child, idx + 1)
