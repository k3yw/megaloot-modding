class_name LibraryPassiveContainer extends MarginContainer


@export var hover_info_module: HoverInfoModule
@export var label: GenericLabel


var base_brightness: float = 0.0
var interactable: bool = false






func set_passive(passive: Passive, sources: Array) -> void :
    hover_info_module.data = [passive]
    interactable = true

    if not sources.is_empty():
        hover_info_module.misc_bb.push_back(BBContainerData.new("\n"))
        hover_info_module.misc_bb.push_back(BBContainerData.new("\n"))
        hover_info_module.misc_bb.push_back(BBContainerData.new("sources: ", Color.DIM_GRAY))

    for idx in sources.size():
        var source = sources[idx]
        if source is Item:
            hover_info_module.misc_bb.push_back(Items.get_bb_container_data(source))

        if source is Enemy:
            hover_info_module.misc_bb.push_back(Enemies.get_bb_container_data(source))

        if source is Adventurer:
            hover_info_module.misc_bb.push_back(Adventurers.get_bb_container_data(source))

        if not is_instance_valid(source):
            hover_info_module.misc_bb.push_back(BBContainerData.new("???", Color.DIM_GRAY))

        if not sources.is_empty() and not idx == sources.size() - 1:
            hover_info_module.misc_bb.push_back(BBContainerData.new(", ", Color.DIM_GRAY))


    label.text = T.get_translated_string(passive.name, "passive-name")




func _process(_delta: float) -> void :
    var brightness: float = base_brightness

    if not interactable or UI.is_hovered(self):
        brightness -= 0.5

    brightness = maxf(-0.75, brightness)

    set_brightness(brightness)



func set_brightness(brightness: float) -> void :
    (label.material as ShaderMaterial).set_shader_parameter("brightness", brightness)
