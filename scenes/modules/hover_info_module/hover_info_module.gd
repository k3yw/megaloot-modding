class_name HoverInfoModule extends Node

enum PressType{NONE, PRESS, ALT_PRESS}


@export var hover_info_name: String = ""
@export var name_tags: Array[BBTag] = []
@export var hover_info_name_color: Color = Color("#a9a9a9")
@export var translate: bool = true
@export var show_disabled: bool
@export var is_dynamic: bool

@export var bb_script: GDScript

@export var press_type: PressType
@export var bottom_hint: String

@export var use_limit: int


var bb_container_data_arr: Array[BBContainerData] = []
var misc_bb: Array[BBContainerData] = []
var data: Array = []
var usage_count: int

var cost_type: StatResource = Stats.GOLD
var cost: int





func get_hover_info_data() -> HoverInfoData:
    var owner_name: String = get_parent().name
    var hover_info_data = HoverInfoData.new()

    var translation_key_name: String = owner_name


    if hover_info_name.length():
        translation_key_name = hover_info_name


    if not data.is_empty():
        var arg_0 = data[0]

        if arg_0 is Specialization:
            hover_info_data = Info.from_item_set(hover_info_data, null, arg_0.original_item_set, arg_0)

        if arg_0 is ItemSetResource:
            hover_info_data = Info.from_item_set(hover_info_data, null, arg_0)

        if arg_0 is AbilityResource:
            var character: Character = null
            if data.size() > 1:
                character = data[1]

            hover_info_data = Info.from_ability(hover_info_data, arg_0, character)

        if arg_0 is Adventurer:
            hover_info_data = Info.from_adventurer(hover_info_data, arg_0)

        if arg_0 is Passive:
            hover_info_data = Info.from_passive(hover_info_data, arg_0)


        if not hover_info_data.bb_container_data_arr.is_empty():
            hover_info_data.bb_container_data_arr += misc_bb
            return hover_info_data


    if not is_instance_valid(bb_script) and not translate:
        return null


    hover_info_data.name = hover_info_name
    hover_info_data.name_color = hover_info_name_color
    hover_info_data.is_dynamic = is_dynamic

    hover_info_data.bb_container_data_arr = bb_container_data_arr
    hover_info_data.cost_type = cost_type
    hover_info_data.cost = cost


    if use_limit:
        hover_info_data.top_hint_color = Color.DARK_GRAY
        hover_info_data.top_hint = str(usage_count) + "/" + str(use_limit)


    if translate and T.is_initialized() and hover_info_name.length():
        hover_info_data.name = T.get_translated_string(hover_info_name, "hover-name")


    if is_instance_valid(bb_script):
        var script: BBScript = bb_script.new() as BBScript
        hover_info_data.bb_container_data_arr = script.get_bb_container_data([translation_key_name] + data)

        if T.is_initialized() and translate:
            var new_bb: Array[BBContainerData] = T.get_translated_bb_code(translation_key_name, "hover-description").duplicate()
            if not new_bb.is_empty():
                hover_info_data.bb_container_data_arr = new_bb

        script.free()



    if bottom_hint.length() > 1:
        match press_type:
            PressType.PRESS: hover_info_data.bottom_hint_texture = Action.get_press_texture()
            PressType.ALT_PRESS: hover_info_data.bottom_hint_texture = Action.get_alt_press_texture()
        hover_info_data.bottom_hint = T.get_translated_string(translation_key_name, "hover-bottom-hint")


    for idx in hover_info_data.bb_container_data_arr.size():
        if not is_instance_valid(hover_info_data.bb_container_data_arr[idx]):
            continue
        if hover_info_data.bb_container_data_arr[idx].text_color == Color.WHITE:
            hover_info_data.bb_container_data_arr[idx].text_color = Color.DIM_GRAY



    return hover_info_data
