class_name LibraryState extends Node

@export var build_planner_container: BuildPlannerContainer

@export var item_scroll_container: GenericScrollContainer
@export var search_line_edit: GenericLineEdit
@export var back_button: GenericButton

@export var bestiary_container: BestiaryContainer
@export var rarity_slider: GenericHSlider

@export var passives_grid_container: GridContainer
@export var synergy_grid_container: GridContainer

var last_frame_search: String = ""
var last_frame_rarity: int = 0


var enemy_resources: Array[EnemyResource] = []
var enemies: Array[Enemy] = []

var library: ItemContainer


var profile: Profile = UserData.profile





func _ready() -> void :
    var available_item_resources: Array[ItemResource] = get_available_item_resources()
    library = ItemContainer.new(ItemContainerResources.LIBRARY, Items.LIST.size())


    for idx in Items.LIST.size():
        var item_resource: ItemResource = Items.LIST[idx]

        var item = ItemManager.create_item(item_resource)

        if not available_item_resources.has(item_resource):
            item.resource = null

        if not profile.encountered_items.has(item_resource):
            item.resource = null

        library.items[idx] = item

        var item_texture_rect_data = ItemTextureRectData.new()
        item_texture_rect_data.item = item

        var item_texture_rect = preload("res://scenes/ui/item_texture_rect/item_texture_rect.tscn").instantiate()
        item_scroll_container.scroll_container.get_child(0).get_child(0).add_child(item_texture_rect)

        item_texture_rect.apply_data(item_texture_rect_data)





    update_bestiary()

    update_synergies()
    update_passives()






func _process(_delta: float) -> void :
    ItemManager.hovered_slot = get_hovered_slot()
    if not is_instance_valid(ItemManager.hovered_slot):
        ItemManager.hovered_slot = Empty.slot



    process_rarity_slider()
    process_search()






















func update_bestiary() -> void :
    for idx in enemy_resources.size():
        var enemy_resource: EnemyResource = enemy_resources[idx]

        var enemy = Enemy.new()
        enemy.resource = enemy_resource
        enemy.battle_count = (enemy.resource.floor_number * 6) + 1
        enemy.set_spawn_floor(enemy.resource.floor_number)
        enemies.push_back(enemy)

        if not profile.encountered_enemies.has(enemy_resource):
            bestiary_container.add_enemy(null)
            continue

        bestiary_container.add_enemy(enemy_resource)











func update_synergies() -> void :
    for item_set in ItemSets.LIST:
        if not Specializations.LIST.has(item_set):
            continue

        for specialization in Specializations.LIST[item_set].arr:
            if not is_instance_valid(specialization.synergy_item_set):
                continue

            var synergy_container: SynergyContainer = preload("res://scenes/ui/synergy_container/synergy_container.tscn").instantiate()
            synergy_grid_container.add_child(synergy_container)
            synergy_container.apply_item_sets(specialization)


func update_passives() -> void :
    var all_passives: Dictionary[Passive, Array] = {}

    for adventurer in Adventurers.LIST:
        if not is_instance_valid(adventurer.passive):
            continue

        if all_passives.has(adventurer.passive):
            all_passives[adventurer.passive].push_back(adventurer)
            continue

        all_passives[adventurer.passive] = [adventurer]


    for item_resource in Items.LIST:
        if not is_instance_valid(item_resource.passive):
            continue

        var item: Item = Item.new()
        item.resource = item_resource

        if all_passives.has(item_resource.passive):
            all_passives[item_resource.passive].push_back(item)
            continue

        all_passives[item_resource.passive] = [item]


    for enemy_resource in Enemies.LIST:
        var enemy: Enemy = null

        if not enemy_resource.passives.is_empty():
            enemy = Enemy.new()
            enemy.resource = enemy_resource
            enemy.update_all()

        for passive in enemy_resource.passives:
            if not is_instance_valid(passive):
                continue

            if all_passives.has(passive):
                all_passives[passive].push_back(enemy)
                continue

            all_passives[passive] = [enemy]



    for passive in all_passives:
        var library_passive_container: LibraryPassiveContainer = preload("res://scenes/ui/library_passive_container/library_passive_container.tscn").instantiate()
        var unknown: bool = true
        for idx in all_passives[passive].size():
            var source = all_passives[passive][idx]

            if source is Item:
                if not UserData.profile.encountered_items.has(source.resource):
                    all_passives[passive][idx] = null
                    continue

            if source is Enemy:
                if not UserData.profile.encountered_enemies.has(source.resource):
                    all_passives[passive][idx] = null
                    continue

            unknown = false

        if not unknown:
            library_passive_container.set_passive(passive, all_passives[passive])

        passives_grid_container.add_child(library_passive_container)


    tree_exiting.connect( func():
        for passive in all_passives:
            for source in all_passives[passive]:
                if not is_instance_valid(source):
                    continue

                if source is Enemy:
                    source.cleanup()
                    source.free()
                    continue

                if source is Item:
                    source.cleanup()
                    source.free()
        )




func get_hovered_slot() -> Slot:
    var items_container: GridContainer = item_scroll_container.scroll_container.get_child(0).get_child(0)

    for idx in items_container.get_child_count():
        var item_texture_rect: ItemTextureRect = items_container.get_child(idx)

        if item_texture_rect.hovering:
            return Slot.new(library, idx)

    for idx in build_planner_container.build_container.get_child_count():
        var item_slot: ItemSlot = build_planner_container.build_container.get_child(idx)
        var item_texture_rect: ItemTextureRect = item_slot.get_item_texture_rect()

        var node_ref = item_slot
        if is_instance_valid(item_texture_rect):
            node_ref = item_texture_rect

        if UI.is_hovered(node_ref):
            return Slot.new(UserData.profile.get_selected_build(), idx)


    return Empty.slot






func get_available_item_resources() -> Array[ItemResource]:
    var available_item_resources: Array[ItemResource] = []

    if not is_instance_valid(profile):
        return Items.LIST.duplicate()

    for item_resource in profile.encountered_items:
        available_item_resources.push_back(item_resource)

    return available_item_resources






func process_rarity_slider() -> void :
    var item_container: GridContainer = item_scroll_container.scroll_container.get_child(0).get_child(0)
    var new_rarity_value: ItemRarity.Type = int(rarity_slider.get_value())


    if not last_frame_rarity == new_rarity_value:
        for idx in library.items.size():
            var item_texture_rect: ItemTextureRect = item_container.get_child(idx)
            var item: Item = library.items[idx]

            if not is_instance_valid(item):
                continue

            item.set_rarity(new_rarity_value)

            var item_texture_rect_data = ItemTextureRectData.new()
            item_texture_rect_data.item = item

            item_texture_rect.apply_data(item_texture_rect_data)

        build_planner_container.update_item_slots()


    last_frame_rarity = new_rarity_value




func process_search() -> void :
    if not last_frame_search == search_line_edit.line_edit.text:
        update_search()

    last_frame_search = search_line_edit.line_edit.text






func update_search() -> void :
    var items_indexes_to_hide: Array[int] = []

    if search_line_edit.line_edit.text.length():
        for idx in Items.LIST.size():
            var hover_info_data = HoverInfoData.new()
            var bb_container_data_arr: Array[BBContainerData] = []
            var item: Item = library.items[idx]
            var to_hide: bool = true

            hover_info_data = Info.from_item(hover_info_data, item, null)

            if not is_instance_valid(item.resource):
                items_indexes_to_hide.push_back(idx)
                continue

            var item_name: String = T.get_translated_string(item.resource.name, "Item Name").to_lower()
            if item_name.contains(search_line_edit.line_edit.text.to_lower()):
                to_hide = false

            bb_container_data_arr += hover_info_data.bb_container_data_arr

            for bb_container_data in bb_container_data_arr:
                if bb_container_data.text.to_lower().contains(search_line_edit.line_edit.text.to_lower()):
                    to_hide = false

            for set_resource in item.get_set_resources():
                if set_resource.name.to_lower().contains(search_line_edit.line_edit.text.to_lower()):
                    to_hide = false

            if to_hide:
                items_indexes_to_hide.push_back(idx)

    var item_container: GridContainer = item_scroll_container.scroll_container.get_child(0).get_child(0)
    for idx in item_container.get_child_count():
        var item_texture_rect: ItemTextureRect = item_container.get_child(idx)
        item_texture_rect.show()
        if items_indexes_to_hide.has(idx):
            item_texture_rect.hide()

    await get_tree().process_frame
    item_scroll_container.update()





func _on_tree_exiting() -> void :
    for item in library.items:
        if profile.get_selected_build().items.has(item):
            continue
        item.cleanup()
        item.free()

    for enemy in enemies:
        enemy.cleanup()
        enemy.free()

    UserData.profile.save()
    ItemManager.reset()
