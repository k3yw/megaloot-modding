class_name BBContainer extends MarginContainer

@export var header_line_containers: Array[MarginContainer]

@export var left_texture_rect: TextureRect
@export var set_texture_rect: TextureRect
@export var right_texture_rect: TextureRect
@export var enemy_texture_rect: TextureRect


@export var back_label: GenericLabel
@export var label: GenericLabel

var base_brightness: float = 0.0
var interactable: bool = false
var data: BBContainerData




func _process(_delta: float) -> void :
    if not is_visible_in_tree():
        return

    var brightness: float = base_brightness

    if interactable and UI.is_hovered(self):
        brightness -= 0.5

    brightness = maxf(-0.75, brightness)

    set_brightness(brightness)




func apply_data(arg_data: BBContainerData) -> void :
    data = arg_data

    interactable = is_instance_valid(get_hover_info(HoverInfoData.new()))
    base_brightness = data.brightness

    for header_line_container in header_line_containers:
        header_line_container.visible = arg_data.is_header

    size_flags_horizontal = arg_data.size_flags_horizontal
    custom_minimum_size.y = 0
    if arg_data.is_header:
        size_flags_horizontal = Control.SIZE_EXPAND_FILL
        custom_minimum_size.y = 25


    right_texture_rect.hide()
    left_texture_rect.hide()
    back_label.hide()


    if "<.>" in data.text:
        var dot_texture: Texture2D = preload("res://assets/textures/icons/p_dot.png")
        left_texture_rect.custom_minimum_size = dot_texture.get_size()
        left_texture_rect.texture = dot_texture
        set_color(left_texture_rect, data.text_color)
        left_texture_rect.show()
        label.text = ""
        return


    label.set_outline_color(data.outline_color)
    label.set_text_color(0, data.text_color)
    label.text = data.text


    if is_instance_valid(data.left_image):
        left_texture_rect.custom_minimum_size = data.left_image.get_size()
        left_texture_rect.texture = data.left_image
        set_color(left_texture_rect, data.left_image_color)
        left_texture_rect.show()



    if is_instance_valid(data.item_set_resource):
        set_texture_rect.custom_minimum_size = data.item_set_resource.icon.get_size()
        set_texture_rect.texture = data.item_set_resource.icon
        set_color(set_texture_rect, data.item_set_resource.color)

        if is_instance_valid(data.specialization):
            set_texture_rect.texture = data.specialization.original_item_set.icon
            set_color(set_texture_rect, data.specialization.get_color())

        if data.is_multiplier:
            back_label.set_outline_color(data.item_set_resource.color)
            back_label.set_text_color(0, data.item_set_resource.color)
            label.set_outline_color(data.item_set_resource.color)
            label.set_text_color(0, data.item_set_resource.color)

            if is_instance_valid(data.specialization):
                back_label.set_outline_color(data.specialization.get_color())
                back_label.set_text_color(0, data.specialization.get_color())
                label.set_outline_color(data.specialization.get_color())
                label.set_text_color(0, data.specialization.get_color())

            label.text = ")"

            back_label.show()
            back_label.text = " (x"
            if data.remove_space:
                back_label.text = "(x"
            return

        if is_instance_valid(data.specialization):
            label.text = " " + T.get_translated_string(data.specialization.name, "Specialization Name")

        return


    if is_instance_valid(data.right_image):
        right_texture_rect.custom_minimum_size = data.right_image.get_size()
        right_texture_rect.texture = data.right_image
        set_color(right_texture_rect, data.right_image_color)
        right_texture_rect.show()


    if is_instance_valid(data.enemy) and data.text.is_empty():
        enemy_texture_rect.texture = data.enemy.resource.texture


    for ref_object in data.ref_objects:
        if ref_object is Item and data.text.is_empty():
            var item_texture_rect = preload("res://scenes/ui/item_texture_rect/item_texture_rect.tscn").instantiate()
            var item_texture_data = ItemTextureRectData.new()
            item_texture_data.item = ref_object
            add_child(item_texture_rect)

            item_texture_rect.apply_data(item_texture_data)
            item_texture_rect.set_as_multiply()

            item_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
            custom_minimum_size.x = 40





func get_hover_info(hover_info_data: HoverInfoData) -> HoverInfoData:
    var item_set_resource: ItemSetResource = data.item_set_resource
    var stat_resource: StatResource = data.stat_resource

    for ref_object in data.ref_objects:
        if ref_object is Keyword:
            return Info.from_keyword(hover_info_data, ref_object)

        if ref_object is Passive:
            return Info.from_passive(hover_info_data, ref_object)

        if ref_object is Item:
            return Info.from_item(hover_info_data, ref_object, data.character)


    if data.is_counter:
        if is_instance_valid(stat_resource):
            var text: String = T.get_translated_string("required-stat")
            for bb in text.split("|"):
                if bb == "{stat}":
                    hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(stat_resource))
                    continue

                hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(bb, Color.DARK_GRAY))

        if is_instance_valid(item_set_resource):
            var text: String = T.get_translated_string("required-item-sets")
            hover_info_data.bb_container_data_arr.clear()

            for bb in text.split("|"):
                if bb == "{item-set}":
                    hover_info_data.bb_container_data_arr.push_back(ItemSets.get_bb_container_data(item_set_resource, data.specialization))
                    continue

                hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(bb, Color.DARK_GRAY))

        return hover_info_data




    if is_instance_valid(item_set_resource):
        if data.is_multiplier:
            var text: String = T.get_translated_string("Item Multiplier")

            for bb in text.split("|"):
                if bb == "{item-set}":
                    hover_info_data.bb_container_data_arr.push_back(ItemSets.get_bb_container_data(item_set_resource, data.specialization))
                    continue

                hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(bb, Color.DARK_GRAY))

            return hover_info_data


        return Info.from_item_set(hover_info_data, data.character, item_set_resource, data.specialization)


    if is_instance_valid(data.trial):
        return Info.from_trial(hover_info_data, data.trial)

    if is_instance_valid(data.adventurer):
        return Info.from_adventurer(hover_info_data, data.adventurer)

    if is_instance_valid(data.battle_action):
        return Info.from_battle_action(hover_info_data, data.battle_action)

    if is_instance_valid(data.stat_resource) and not data.stat_resource.name.is_empty():
        if data.is_value:
            hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Your ", Color.DARK_GRAY))
            hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(data.stat_resource))
            return hover_info_data

        return Info.from_stat_resource(hover_info_data, data.character, data.stat_resource)

    if is_instance_valid(data.ability):
        return Info.from_ability(hover_info_data, data.ability, data.character)


    if is_instance_valid(data.status_effect_resource) and not data.status_effect_resource == Empty.status_effect_resource:
        return Info.from_status_effect_resource(hover_info_data, data.status_effect_resource, data.character)

    if is_instance_valid(data.enemy):
        return Info.from_enemy(hover_info_data, data.enemy, true)


    hover_info_data.unreference()
    return null



func set_brightness(brightness: float) -> void :
    (right_texture_rect.material as ShaderMaterial).set_shader_parameter("brightness", brightness)
    (left_texture_rect.material as ShaderMaterial).set_shader_parameter("brightness", brightness)
    (set_texture_rect.material as ShaderMaterial).set_shader_parameter("brightness", brightness)
    (back_label.material as ShaderMaterial).set_shader_parameter("brightness", brightness)
    (label.material as ShaderMaterial).set_shader_parameter("brightness", brightness)



func set_color(texture_rect: TextureRect, color: Color) -> void :
    (texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", color)
