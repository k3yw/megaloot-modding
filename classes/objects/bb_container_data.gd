class_name BBContainerData extends RefCounted




var text: String = ""
var text_color: Color = Color.DARK_GRAY
var outline_color: Color = Color.TRANSPARENT
var tag: BBTag = BBTag.new()


var left_image: Texture2D
var left_image_color: Color = Color.WHITE

var right_image: Texture2D
var right_image_color: Color = Color.WHITE

var size_flags_horizontal: Control.SizeFlags = Control.SIZE_SHRINK_BEGIN
var is_multiplier: bool = false
var is_header: bool = false
var hide_name: bool = false

var status_effect_resource: StatusEffectResource
var item_set_resource: ItemSetResource
var item_set_to_level: ItemSetResource
var stat_resource: StatResource = StatResource.new()
var character: Character
var ability: AbilityResource
var battle_action: BattleAction

var specialization: Specialization
var adventurer: Adventurer
var enemy: Enemy
var trial: Trial


var brightness: float = 0.0
var ref_objects: Array = []

var is_counter: bool = false
var bb_counter: BBCounter

var show_cost: bool = false
var is_value: bool = false

var remove_space: bool = false




func _init(arg_text: String = "", arg_text_color = Color.DARK_GRAY) -> void :
    text = arg_text
    text_color = arg_text_color





func clear_references() -> void :
    bb_counter = null
    status_effect_resource = null
    item_set_resource = null
    item_set_to_level = null
    stat_resource = null
    character = null
    ability = null
    battle_action = null
    specialization = null
    adventurer = null
    enemy = null
    trial = null

    ref_objects.clear()



static func create_counter_hint(arg_resource, amount: int) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.bb_counter = BBCounter.new(arg_resource, amount)
    return bb_container_data


static func create_counter_display(arg_resource, amount: int) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.bb_counter = BBCounter.new(arg_resource, amount)
    bb_container_data.is_counter = true

    return bb_container_data
