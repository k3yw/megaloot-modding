class_name MemorySlotContainer extends MarginContainer

signal selected


@export var adventurer_portrait_container: VBoxContainer
@export var seperator_labels: Array[GenericLabel]
@export var floor_number_label: GenericLabel
@export var game_mode_label: GenericLabel
@export var ascension_label: GenericLabel
@export var floor_label: GenericLabel

@export var selection_panel: NinePatchRect



var is_selected: bool = false
var hovering: bool = false


var memory_slot_idx: int = -1






func _process(_delta: float) -> void :
    hovering = UI.is_hovered(self)
    is_selected = false


    if hovering and Input.is_action_just_pressed("press"):
        is_selected = true
        selected.emit()



func update(memory: Memory) -> void :
    game_mode_label.text = memory.game_mode.get_translated_name()
    floor_number_label.text = Format.number(memory.floor_number + 1)
    seperator_labels[1].hide()
    ascension_label.hide()
    floor_label.show()



    if memory.can_ascend():
        floor_number_label.text = T.get_translated_string("final-floor-reached")
        floor_label.hide()

    if memory.ascension > 0:
        ascension_label.text = T.get_translated_string("ascension-level").replace("{level}", str(memory.ascension))
        seperator_labels[1].show()
        ascension_label.show()

    for child in adventurer_portrait_container.get_children():
        adventurer_portrait_container.remove_child(child)
        child.queue_free()



    var local_player_container: MemorySlotAdventurerContainer = preload("res://scenes/ui/memory_slot_container/memory_slot_adventurer_container/memory_slot_adventurer_container.tscn").instantiate()
    adventurer_portrait_container.add_child(local_player_container)
    local_player_container.set_player(memory.local_player)

    for idx in memory.partners.size():
        var partner: Player = memory.partners[idx]
        var pratner_player_container: MemorySlotAdventurerContainer = preload("res://scenes/ui/memory_slot_container/memory_slot_adventurer_container/memory_slot_adventurer_container.tscn").instantiate()

        adventurer_portrait_container.add_child(pratner_player_container)
        pratner_player_container.set_player(partner)
