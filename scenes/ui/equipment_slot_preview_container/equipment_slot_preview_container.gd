class_name EquipmentSlotPreviewContainer extends MarginContainer




@export var equipment_slot_preview_container_0: VBoxContainer
@export var equipment_slot_preview_container_1: VBoxContainer


var equipment_slot_preview_nodes: Array[EquipmentSlotPreview] = []


func _ready() -> void :
    update_equipment_slot_preview_nodes()




func update_equipment_slot_preview_nodes() -> void :
    equipment_slot_preview_nodes = get_equipment_slot_preview_nodes()



func update_slots(slots: Array[SocketType]) -> void :
    for idx in equipment_slot_preview_nodes.size():
        var child: EquipmentSlotPreview = equipment_slot_preview_nodes[idx]
        child.main_slot_texture_rect.hide()
        child.set_type(slots[idx])



func get_equipment_slot_preview_nodes() -> Array[EquipmentSlotPreview]:
    for child in equipment_slot_preview_container_0.get_children():
        if child is EquipmentSlotPreview:
            equipment_slot_preview_nodes.push_back(child)

    for child in equipment_slot_preview_container_1.get_children():
        if child is EquipmentSlotPreview:
            equipment_slot_preview_nodes.push_back(child)

    return equipment_slot_preview_nodes




func show_highlight(idx: int) -> void :
    var equipment_slot_preview_node: EquipmentSlotPreview = equipment_slot_preview_nodes[idx]
    (equipment_slot_preview_node.background_color_rect.material as ShaderMaterial).set_shader_parameter("type", GlobalColors.Type.HIGHLIGHT_COLOR)


func hide_highlight(idx: int) -> void :
    var equipment_slot_preview_node: EquipmentSlotPreview = equipment_slot_preview_nodes[idx]
    (equipment_slot_preview_node.background_color_rect.material as ShaderMaterial).set_shader_parameter("type", GlobalColors.Type.PRIMARY_COLOR)
