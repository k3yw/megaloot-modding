class_name LoreContainer extends MarginContainer



@export var chapter_selection_container: VBoxContainer
@export var lore_label: GenericLabel
var chapters: Array[Chapter] = []
var selected_chapter: int = 0
var locked_chapters: int = 0




func update_adventurer(adventurer: Adventurer) -> void :
    clear_all()

    if not adventurer.chapters.size():
        return

    locked_chapters = adventurer.chapters.size()

    if UserData.profile.get_floor_record(adventurer) > 10:
        chapters.push_back(adventurer.chapters[0])
        adventurer.chapters[0].text = T.get_translated_string(adventurer.name, "Chapter " + str(0))
        locked_chapters -= 1

    for idx in chapters.size():
        var label_button = preload("res://scenes/ui/label_button/label_button.tscn").instantiate()
        label_button.text = T.get_translated_string("Chapter") + " " + str(idx + 1)
        chapter_selection_container.add_child(label_button)

    for _i in locked_chapters:
        var label_button = preload("res://scenes/ui/label_button/label_button.tscn").instantiate()
        label_button.text = "???"
        chapter_selection_container.add_child(label_button)

    select_chapter(0)



func clear_all() -> void :
    for child in chapter_selection_container.get_children():
        child.queue_free()

    lore_label.text = ""
    chapters.clear()




func _process(_delta: float) -> void :
    process_selection()



func process_selection() -> void :
    if not Input.is_action_just_pressed("press"):
        return

    for idx in chapter_selection_container.get_child_count():
        var label_button: LabelButton = chapter_selection_container.get_child(idx)
        if UI.is_hovered(label_button):
            select_chapter(idx)
            return



func select_chapter(new_selected_chapter_idx: int) -> void :
    var selected_label_button: LabelButton = chapter_selection_container.get_child(new_selected_chapter_idx)
    var last_label_button: LabelButton = chapter_selection_container.get_child(selected_chapter)

    if new_selected_chapter_idx > chapters.size() - 1:
        return

    last_label_button.selected = false
    selected_label_button.selected = true

    selected_chapter = new_selected_chapter_idx

    lore_label.text = chapters[new_selected_chapter_idx].text
