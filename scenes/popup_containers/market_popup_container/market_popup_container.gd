@tool
class_name MarketPopupContainer extends PopupContainer

signal pressed_item(item_resource: ItemResource)


@export var item_holder: GridContainer


var requirement_locked_items: Array[ItemResource] = []
var market_items: Array[ItemResource] = []
var item_cache: Array[Item] = []
var local_player: Player = null




func _ready() -> void :
    tree_exiting.connect( func():
        for item in item_cache:
            item.cleanup()
            item.free()
        )




func _process(_delta: float) -> void :
    super._process(_delta)

    if Engine.is_editor_hint():
        return

    if Input.is_action_just_pressed("press"):
        process_item_press()



func create_item(resource: ItemResource) -> Item:
    var item: Item = Item.new()
    item.resource = resource

    if is_instance_valid(resource.passive):
        item.reforged_passive = resource.passive
        item.reforge_level += 1

    return item


func process_item_press() -> void :
    for idx in item_holder.get_child_count():
        var child = item_holder.get_child(idx)

        if child is ItemTextureRect:
            var item_resource: ItemResource = market_items[idx]

            if not child.hovering:
                continue

            local_player.remove_banish(item_resource)
            item_cache[idx].is_banish = false

            var item_texture_rect_data = ItemTextureRectData.new()
            item_texture_rect_data.item = item_cache[idx]

            update_item_texture(child, item_texture_rect_data)

            pressed_item.emit(item_resource)





func update() -> void :
    var new_texture_rects: int = market_items.size() - item_holder.get_child_count()
    item_cache.resize(market_items.size())

    for _i in new_texture_rects:
        var item_texture_rect: ItemTextureRect = preload("res://scenes/ui/item_texture_rect/item_texture_rect.tscn").instantiate()
        item_holder.add_child(item_texture_rect)



    for idx in item_cache.size():
        if not is_instance_valid(item_cache[idx]):
            item_cache[idx] = create_item(market_items[idx])

        if not item_cache[idx].resource == market_items[idx]:
            item_cache[idx].cleanup()
            item_cache[idx].free()

            item_cache[idx] = create_item(market_items[idx])



    for idx in item_holder.get_child_count():
        var item_texture_rect = item_holder.get_child(idx)
        if item_texture_rect is ItemTextureRect:
            var item_texture_rect_data = ItemTextureRectData.new()
            item_texture_rect_data.item = item_cache[idx]

            item_texture_rect.set_as_multiply()

            if local_player.banished_items.has(item_cache[idx].resource):
                item_cache[idx].is_banish = true

            update_item_texture(item_texture_rect, item_texture_rect_data)




func update_item_texture(item_texture_rect: ItemTextureRect, data: ItemTextureRectData) -> void :
    requirement_locked_items = local_player.get_requirement_locked_items(market_items)
    item_texture_rect.apply_data(data)
    item_texture_rect.rarity_texture_rect.texture = preload("res://assets/textures/rarity_borders/toggle_off_border.png")

    item_texture_rect.set_rarity_texture_rect_alpha(1.0)
    item_texture_rect.set_item_texture_rect_alpha(1.0)
    if data.item.is_banish:
        item_texture_rect.set_rarity_texture_rect_alpha(0.5)

    item_texture_rect.lock_texture_rect.visible = false
    if requirement_locked_items.has(data.item.resource):
        item_texture_rect.lock_texture_rect.visible = true
        item_texture_rect.lock_texture_rect.position.y = 23
        item_texture_rect.set_rarity_texture_rect_alpha(0.5)
        item_texture_rect.set_item_texture_rect_alpha(0.5)
