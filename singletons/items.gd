extends Node

signal initialized

const ITEMS_DIR: String = "res://resources/items/"

var RIBBON_OF_FORTUNE: ItemResource = preload("res://resources/items/ribbon_of_fortune.tres")
var MERCHANT_UPGRADE: ItemResource = preload("res://resources/items/merchant_upgrade.tres")
var INSIGHTUS: ItemResource = preload("res://resources/items/insightus.tres")

var STAT_ADAPTERS: Array[ItemResource] = []
var CONSUMABLES: Array[ItemResource] = []
var ESSENTIALS: Array[ItemResource] = []
var ARTIFACTS: Array[ItemResource] = []
var SPECIAL: Array[ItemResource] = []
var MARKET: Array[ItemResource] = []
var TOMES: Array[ItemResource] = []

var LIST: Array[ItemResource] = []

var HIGHEST_PRICE_PER_FLOOR: Array[float] = []
var PASSIVES_PER_FLOOR: Array[Array] = []
var SETS_PER_FLOOR: Array[Array] = []


func _ready() -> void :
    var items_per_floor: Array[Array] = []

    for file_name in File.get_file_paths(ITEMS_DIR):
        var file_path: String = ITEMS_DIR + file_name

        if ".tres.remap" in file_path:
            file_path = file_path.trim_suffix(".remap")

        var item_resource: ItemResource = load(file_path)


        if not is_instance_valid(item_resource):
            print("error loading item:", file_path)
            continue

        var item_floor: int = item_resource.spawn_floor - 1
        var arr: Array[ItemResource] = MARKET

        if System.is_demo() and item_floor > 15:
            continue

        if item_resource.is_essential() or item_resource.is_special:
            item_resource.set_resources = [ItemSets.ESSENTIAL]
            arr = ESSENTIALS

        if item_resource.is_tome():
            item_resource.set_resources = [ItemSets.TOME]
            arr = TOMES

        if item_resource.is_stat_adapter():
            item_resource.set_resources = [ItemSets.CONSUMABLE]
            STAT_ADAPTERS.push_back(item_resource)

        if item_resource.is_consumable():
            item_resource.set_resources = [ItemSets.CONSUMABLE]
            arr = CONSUMABLES

        if item_resource.is_artifact:
            ARTIFACTS.push_back(item_resource)

        if not item_resource.is_special:
            arr.push_back(item_resource)

        var price: float = item_resource.get_price()


        if items_per_floor.size() - 1 < item_floor:
            items_per_floor.resize(item_floor + 1)
        items_per_floor[item_floor].push_back(item_resource)


        if HIGHEST_PRICE_PER_FLOOR.size() - 1 < item_floor:
            HIGHEST_PRICE_PER_FLOOR.resize(item_floor + 1)

        if HIGHEST_PRICE_PER_FLOOR[item_floor] < price:
            HIGHEST_PRICE_PER_FLOOR[item_floor] = price

        if SETS_PER_FLOOR.size() - 1 < item_floor:
            PASSIVES_PER_FLOOR.resize(item_floor + 1)
            SETS_PER_FLOOR.resize(item_floor + 1)


        for item_set in item_resource.set_resources:
            if not SETS_PER_FLOOR[item_floor].has(item_set):
                SETS_PER_FLOOR[item_floor].push_back(item_set)

        if not PASSIVES_PER_FLOOR[item_floor].has(item_resource.passive):
            PASSIVES_PER_FLOOR[item_floor].push_back(item_resource.passive)



    for items_per_floor_arr in items_per_floor:
        items_per_floor_arr.sort_custom(sort_item_resources)


    for items_per_floor_arr in items_per_floor:
        for item_resource in items_per_floor_arr:
            LIST.push_back(item_resource as ItemResource)



    for idx in SETS_PER_FLOOR.size():
        var stat_arr: Array = SETS_PER_FLOOR[idx]
        if idx == 0:
            continue

        var lower_stat_arr: Array = SETS_PER_FLOOR[idx - 1]
        for stat in lower_stat_arr:
            if stat_arr.has(stat):
                continue
            stat_arr.push_back(stat)

    initialized.emit()




func create_atlas() -> void :
    var size: int = ceili(sqrt(LIST.size()))

    var sub_viewport = SubViewport.new()
    sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    sub_viewport.size = Vector2(size, size) * 32
    sub_viewport.transparent_bg = true
    add_child(sub_viewport)

    for idx in LIST.size():
        var item: ItemResource = LIST[idx]
        var texture_rect = TextureRect.new()
        texture_rect.size = Vector2(32, 32)
        texture_rect.texture = item.texture
        sub_viewport.add_child(texture_rect)
        texture_rect.position = Vector2(32 * (idx % size), 32 * floori(float(idx) / size))

    await RenderingServer.frame_post_draw
    var result: ImageTexture = ImageTexture.create_from_image(sub_viewport.get_texture().get_image())

    for idx in LIST.size():
        var item: ItemResource = LIST[idx]
        item.texture = AtlasTexture.new()
        (item.texture as AtlasTexture).atlas = result
        (item.texture as AtlasTexture).region.size = Vector2(32, 32)
        (item.texture as AtlasTexture).region.position = Vector2(32 * (idx % size), 32 * floori(float(idx) / size))

    sub_viewport.queue_free()




func get_most_expensive_item_price(starting_floor: int) -> float:
    var fixed_starting_floor: int = min(starting_floor, HIGHEST_PRICE_PER_FLOOR.size() - 1)
    var price: float = 0

    for idx in range(fixed_starting_floor, -1, -1):
        if HIGHEST_PRICE_PER_FLOOR[idx] == 0:
            continue
        price = HIGHEST_PRICE_PER_FLOOR[idx]
        break

    return price




func get_resources(item_content: Array[ItemResource], floor_number: int = -1) -> Array[ItemResource]:
    var available_items: Array[ItemResource] = []

    for item_resource in item_content:
        if not is_instance_valid(item_resource):
            continue

        if not floor_number == -1:
            if item_resource.spawn_floor - 1 > floor_number:
                continue

        available_items.push_back(item_resource)

    return available_items



func get_bb_container_data(item: Item) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.text = T.get_translated_string(item.resource.name, "item-name")
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE
    bb_container_data.ref_objects.push_back(item)

    return bb_container_data




func sort_item_resources(resource_a: ItemResource, resource_b: ItemResource) -> bool:
    if resource_a.get_price() >= resource_b.get_price():
        return false
    return true
