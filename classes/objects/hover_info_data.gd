class_name HoverInfoData extends RefCounted




var name: String = ""
var name_color: Color = Color.WHITE
var name_outline_color: Color = Color.TRANSPARENT
var name_tags: Array[BBTag] = []

var name_icon_colors: Array[Color] = []
var name_icons: Array[Texture2D] = []

var item_set_resources: Array[ItemSetResource] = []

var cost_type: StatResource = null
var pre_discount_cost: float = 0
var cost: float = 0

var top_hint_color: Color = Color.WHITE
var top_hint: String = ""


var bb_container_data_arr: Array[BBContainerData] = []


var show_cost: bool = false

var is_dynamic: bool = false

var bottom_hint_texture: Texture = null
var bottom_hint: String = ""

var owner: Control = null
