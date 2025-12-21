class_name HoverInfo extends CanvasGroup

signal initial_pos_set

@onready var animation_player = $AnimationPlayer
@export var main_container: MarginContainer

@export var top_container: HBoxContainer

@export var set_icon_container: HBoxContainer
@export var name_label: GenericLabel

@export var cost_texture_rect: TextureRect
@export var discount_cost_label: RichTextLabel
@export var cost_label: RichTextLabel
@export var top_hint_label: RichTextLabel

@export var cost_container: HBoxContainer
@export var top_hint_container: HBoxContainer

@export var scroll_container: GenericScrollContainer
@export var info_label: GenericRichTextLabel

@export var bottom_hint_seperator: AspectRatioContainer
@export var bottom_hint_panel: PanelContainer
@export var bottom_hint_texture_rect: TextureRect
@export var bottom_hint_label: GenericLabel

@export var hold_progress_bar: TextureProgressBar

var default_lock_time: float = 0.75
var lock_time_left: float = 0.75

var hover_owner: Control = null
var follow_mouse: bool = false
var is_under: bool = false
var data: HoverInfoData



func _ready() -> void :
    scroll_container.view_order = get_index() + 1
    update_hold_progress_bar()

    await initial_pos_set

    if is_under:
        animation_player.play("spawn_under")
        return

    animation_player.play("spawn")



func _process(delta: float) -> void :
    if lock_time_left >= 0:
        lock_time_left -= delta

        var snap_animation: String = "snap"
        if lock_time_left <= 0:
            if is_under:
                snap_animation = "snap_under"

            animation_player.play(snap_animation)


    update_hold_progress_bar()
    update_position()








func set_lock_time(amount: float) -> void :
    default_lock_time = amount
    lock_time_left = amount


func update_hold_progress_bar() -> void :
    hold_progress_bar.max_value = default_lock_time
    hold_progress_bar.value = default_lock_time - lock_time_left

    if lock_time_left <= 0:
        hold_progress_bar.hide()
        return

    hold_progress_bar.show()



func apply_data(arg_data: HoverInfoData) -> void :
    data = arg_data

    top_container.hide()
    cost_container.hide()
    bottom_hint_texture_rect.hide()
    bottom_hint_seperator.hide()
    bottom_hint_panel.hide()
    top_hint_container.hide()
    info_label.hide()

    for child in set_icon_container.get_children():
        set_icon_container.remove_child(child)
        child.queue_free()


    for idx in data.name_icons.size():
        var name_icon: Texture2D = data.name_icons[idx]
        var color: Color = Color.WHITE

        if data.name_icon_colors.size() > idx:
            color = data.name_icon_colors[idx]

        add_set_texture(name_icon, color)


    for idx in data.item_set_resources.size():
        var item_set_resource: ItemSetResource = data.item_set_resources[idx]
        add_set_texture(item_set_resource.icon, item_set_resource.color)


    if is_instance_valid(data.bottom_hint_texture):
        bottom_hint_texture_rect.texture = data.bottom_hint_texture
        bottom_hint_texture_rect.show()


    set_icon_container.visible = set_icon_container.get_child_count()


    if arg_data.name.length():
        bottom_hint_seperator.show()
        top_container.show()

    if data.cost > 0 or data.show_cost:
        cost_container.show()

    if data.bottom_hint.length():
        bottom_hint_seperator.show()
        bottom_hint_panel.show()

    if data.top_hint.length():
        top_hint_container.show()
        top_hint_label.modulate = data.top_hint_color
        top_hint_label.text = data.top_hint


    info_label.set_bb_containers(data.bb_container_data_arr)
    info_label.update_minimum_size()
    scroll_container.custom_minimum_size.y = minf(138, info_label.get_minimum_size().y)
    scroll_container.visible = data.bb_container_data_arr.size() > 0
    info_label.show()


    name_label.text = data.name
    name_label.set_text_color(GlobalColors.Type.CUSTOM, data.name_color)
    name_label.set_outline_color(data.name_outline_color)

    if is_instance_valid(data.cost_type):
        var cost_text: String = Format.number(data.cost, [Format.Rules.USE_SUFFIX])
        discount_cost_label.hide()

        if data.pre_discount_cost > 0.0:
            var discount_cost_text: String = Format.number(data.pre_discount_cost, [Format.Rules.USE_SUFFIX])
            discount_cost_label.parse_bbcode(discount_cost_text)
            discount_cost_label.show()

        cost_texture_rect.texture = data.cost_type.icon
        cost_texture_rect.modulate = data.cost_type.color
        cost_label.parse_bbcode(cost_text)
        cost_label.modulate = data.cost_type.color

    bottom_hint_label.text = data.bottom_hint


    if is_instance_valid(arg_data.owner):
        hover_owner = arg_data.owner
        update_position()
        return

    if is_instance_valid(hover_owner):
        data.owner = hover_owner






func add_set_texture(texture: Texture2D, color = Color.WHITE) -> void :
    var texture_rect = TextureRect.new()
    texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    texture_rect.texture = texture

    texture_rect.material = ShaderMaterial.new()
    texture_rect.material.resource_local_to_scene = true
    texture_rect.material.shader = preload("res://resources/shaders/set_texture_rect.gdshader")
    texture_rect.material.set_shader_parameter("main_col", color)

    set_icon_container.add_child(texture_rect)




func update_position() -> void :

    if not is_instance_valid(data):
        return


    if not is_instance_valid(hover_owner):
        return


    main_container.size = Vector2.ZERO

    global_position = hover_owner.get_global_rect().position

    if is_instance_valid(hover_owner.get_viewport()):
        var sub_viewport_container: SubViewportContainer = hover_owner.get_viewport().get_parent()
        if is_instance_valid(sub_viewport_container):
            global_position += sub_viewport_container.get_global_rect().position




    main_container.update_minimum_size()


    set_initial_pos()

    global_position.x += floori(float(hover_owner.get_global_rect().size.x) / 2)
    global_position.x -= floori(float(main_container.size.x) / 2)


    if global_position.x + main_container.size.x > get_viewport_rect().size.x - 1:
        global_position.x -= global_position.x + main_container.size.x - get_viewport_rect().size.x + 2

    if global_position.y + main_container.size.y > get_viewport_rect().size.y - 1:
        global_position.y -= global_position.y + main_container.size.y - get_viewport_rect().size.y + 2

    if global_position.x < 1:
        global_position.x += abs(global_position.x) + 3

    if global_position.y < 1:
        global_position.y += abs(global_position.y) + 3




func set_initial_pos() -> void :
    if hover_owner.get_global_rect().get_center().y < get_viewport_rect().size.y / 2:
        global_position.y += (hover_owner.get_global_rect().size.y - 1)
        is_under = true

        initial_pos_set.emit()
        return

    global_position.y -= (main_container.size.y - 2)

    initial_pos_set.emit()




func get_bb_containers() -> Array[BBContainer]:
    return info_label.bb_containers
