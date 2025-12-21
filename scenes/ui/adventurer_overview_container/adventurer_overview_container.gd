class_name AdventurerOverviewContainer extends MarginContainer


@export var reward_container_holder: HBoxContainer
@export var floor_record_label: GenericLabel
@export var version_drop_down: DropDownOption

var selected_version: String = System.get_version()
var selected_adventurer: Adventurer = null
var active_versions: Array[String] = []


func _ready() -> void :
    version_drop_down.drop_down.selected.connect( func(selected_idx: int):
        selected_version = active_versions[selected_idx]
        update_adventurer(selected_adventurer)
        )



func update_adventurer(adventurer: Adventurer) -> void :
    var floor_text: String = T.get_translated_string("Floor Number").to_upper()
    var highest_floor_text: String = T.get_translated_string("Highest Floor")
    var floor_record: int = UserData.profile.get_floor_record(adventurer, selected_version)
    update_active_versions(adventurer)
    selected_adventurer = adventurer

    floor_record_label.text = highest_floor_text + ": " + str(floor_record + 1)

    for child in reward_container_holder.get_children():
        reward_container_holder.remove_child(child)
        child.queue_free()


    for border in AdventurerBorder.Type.keys().size():
        var reward_container: RewardContainer = preload("res://scenes/ui/reward_container/reward_container.tscn").instantiate()
        reward_container.goal_label.text = floor_text.replace("{NUMBER}", str(AdventurerBorder.get_number(border)))
        reward_container.border_texture_rect.texture = AdventurerBorder.get_texture(border)
        reward_container.adventurer_texture_rect.texture = adventurer.portrait

        reward_container_holder.add_child(reward_container)


    var unlocked: bool = false
    for border in range(AdventurerBorder.Type.keys().size() - 1, -1, -1):
        var rewards_container = reward_container_holder.get_child(border)
        if not rewards_container is RewardContainer:
            continue
        rewards_container = rewards_container as RewardContainer

        if AdventurerBorder.get_type(adventurer, floor_record) == border:
            unlocked = true

        if not unlocked:
            rewards_container.show_as_locked()



func update_active_versions(adventurer: Adventurer) -> void :
    active_versions.clear()

    active_versions.push_back(System.get_version())
    version_drop_down.drop_down.clear_selections()

    for floor_record in UserData.profile.floor_records:
        if not floor_record.adventurer == adventurer:
            continue

        if floor_record.version.is_empty():
            continue

        if active_versions.has(floor_record.version):
            continue

        active_versions.push_back(floor_record.version)

    active_versions.sort()
    active_versions.reverse()

    for version in active_versions:
        version_drop_down.drop_down.add_selection(version)

    version_drop_down.drop_down.reload_selections()
