class_name EquipmentSlotContainer extends HBoxContainer



@export var equipment_container_0: VBoxContainer
@export var equipment_container_1: VBoxContainer

var equipment_slot_nodes: Array[ItemSlot] = []



func _ready() -> void :
    update_equipment_slot_nodes()




func update_equipment_slot_nodes() -> void :
    equipment_slot_nodes.clear()

    for child in equipment_container_0.get_children():
        if child is ItemSlot:
            equipment_slot_nodes.push_back(child)

    for child in equipment_container_1.get_children():
        if child is ItemSlot:
            equipment_slot_nodes.push_back(child)




func show_highlight(idx: int) -> void :
    var equipment_slot_node: ItemSlot = equipment_slot_nodes[idx]
    (equipment_slot_node.material as ShaderMaterial).set_shader_parameter("type", GlobalColors.Type.HIGHLIGHT_COLOR)


func hide_highlight(idx: int) -> void :
    var equipment_slot_node: ItemSlot = equipment_slot_nodes[idx]
    (equipment_slot_node.material as ShaderMaterial).set_shader_parameter("type", GlobalColors.Type.PRIMARY_COLOR)
