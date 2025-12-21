class_name GameplayCanvasLayer extends CanvasLayer

@export var popup_manager: GameplayPopupManager
@export var vfx_manager: VFXManager

@export var effect_container_holder: EffectContainerHolder

@export var market_popup_container: MarketPopupContainer
@export var market_button: GenericButton

@export var player_container: GenericTabContainer

@export var main_tab_button: TabButton
@export var stats_button: TabButton
@export var battle_log_button: TabButton

@export var battle_log_tab_container: BattleLogTabContainer

@export var adventurer_portrait: AdventurerPortrait

@export var difficulty_progress_bar: DifficultyProgressBar

@export var resource_bar_holder: VBoxContainer
@export var health_bar_holder: HBoxContainer
@export var armor_bar_holder: HBoxContainer

@export var mana_bar: SmallResourceBar
@export var health_bar: ResourceBar
@export var armor_bar: ResourceBar


@export var gold_coins_container: GoldCoinsContainer
@export var diamonds_container: StatContainer


@export var stats_scroll_container: StatsScrollContainer

@export var equipment_slot_preview_container: EquipmentSlotPreviewContainer
@export var inventory_contents_container: GridContainer
@export var equipment_slot_container: EquipmentSlotContainer

@export var market_refresh_button: MarketRefreshButton
@export var market_slot_container: HBoxContainer
@export var market_margin: MarginContainer
@export var hub_action_panel: HubActionPanel

@export var warning_holder: Control

@export var wait_for_connection_container: MarginContainer

@export var full_screen_transition: GameplayScreenTransition
@export var screen_transition: GameplayScreenTransition


@export_group("Room Screen")
@export var room_screen: RoomScreen

@export var loot_stash_popup_container: LootStashPopupContainer
@export var loot_stash_button: LootStashButton

@export var chat_popup_container: ChatPopupContainer
@export var chat_button: ChatButton



func _ready() -> void :
    stats_scroll_container.search_line_edit.changed.connect(_on_stats_scroll_container_search_changed)
    T.language_changed.connect( func(): update_stat_scroll_container())
    update_stat_scroll_container()




func _on_stats_scroll_container_search_changed() -> void :
    for stat in Stats.DISPLAY:
        var stat_name: String = T.get_translated_string(stat.name, "Stat Name").to_lower()
        var stat_label_container: StatLabelContiner = stats_scroll_container.get_stat(stat)
        stat_label_container.show()

        if not stats_scroll_container.search_line_edit.line_edit.text.length():
            continue

        if not stat_name.contains(stats_scroll_container.search_line_edit.line_edit.text.to_lower()):
            stat_label_container.hide()

    stats_scroll_container.stats_holder.process_size()
    stats_scroll_container.scroll_container.update()




func _process(_delta: float) -> void :
    armor_bar_holder.hide()
    for child in armor_bar_holder.get_children():
        if child.visible:
            armor_bar_holder.show()





func update_stat_scroll_container() -> void :
    for child in stats_scroll_container.stats_holder.get_children():
        stats_scroll_container.stats_holder.remove_child(child)
        child.queue_free()

    for stat in Stats.DISPLAY:
        stats_scroll_container.add_stat(stat)








func get_stat_label_container(stat: StatResource) -> StatLabelContiner:
    return stats_scroll_container.get_stat(stat)





func get_item_slot(slot: Slot) -> ItemSlot:
    var item_slots: Array[ItemSlot] = get_item_slots(slot.item_container.resource)
    if item_slots.size() <= slot.index or slot.index == -1:
        return null

    return item_slots[slot.index]




func get_all_item_slots() -> Array[ItemSlot]:
    var item_slots: Array[ItemSlot] = []

    for item_container in ItemContainerResources.GAMEPLAY_ITEM_CONTAINERS:
        item_slots += get_item_slots(item_container)

    return item_slots




func update_health_info(selected_player: Player) -> void :
    var status_effects: Array[StatusEffect] = []

    health_bar.update_as_health(selected_player)

    for status_effect in selected_player.battle_profile.get_active_status_effects():
        if StatusEffects.IMPACT_HEALTH.has(status_effect.resource):
            status_effects.push_back(status_effect)

    health_bar.effect_container_holder.update_effects(status_effects, selected_player)

    if selected_player.has_magic_shield() and not armor_bar.visible:
        health_bar.set_color(Color("#8ab1ff"))




func update_armor_info(selected_player: Player) -> void :
    var active_armor: float = selected_player.get_stat_amount(Stats.ACTIVE_ARMOR)[0]
    var armor: float = selected_player.get_stat_amount(Stats.ARMOR)[0]

    armor_bar.set_color(Color("#4a5462"))
    armor_bar.visible = armor


    armor_bar.set_target_value_under(active_armor)
    armor_bar.set_target_value(active_armor)
    armor_bar.set_max_value(armor)

    armor_bar.max_amount_label.target_value = armor
    armor_bar.amount_label.target_value = active_armor

    if selected_player.has_magic_shield():
        armor_bar.set_color(Color("#8ab1ff"))







func get_item_slots(item_container: ItemContainerResource) -> Array[ItemSlot]:
    var item_slots: Array[ItemSlot] = []

    for item_slot in get_tree().get_nodes_in_group(ItemSlot.get_group_name(item_container)):
        item_slot = item_slot as ItemSlot
        item_slots.push_back(item_slot)

    return item_slots








func get_item_texture_rect(slot: Slot) -> ItemTextureRect:
    var item_slots: Array[Node] = get_tree().get_nodes_in_group(ItemSlot.get_group_name(slot.item_container.resource))
    if not item_slots.is_empty():
        var item_slot: ItemSlot = item_slots[slot.index] as ItemSlot
        return item_slot.get_item_texture_rect()

    return null






func update_item_slots(item_containers: Array[ItemContainer], dragged_slot: Slot):
    for item_container in item_containers:
        var item_slots: Array[ItemSlot] = get_item_slots(item_container.resource)
        var items: Array[Item] = item_container.get_items_with_null()

        for item_index in items.size():
            var dragged_item: Item = dragged_slot.get_item()
            var item: Item = items[item_index]

            if is_instance_valid(dragged_slot) and is_instance_valid(item) and not Platform.is_mobile():
                if dragged_slot.item_container.resource == item_container.resource:
                    if is_instance_valid(dragged_item) and dragged_item == item:
                        item = null

            var inside_canvas_group: bool = false
            var reference_slot: Control

            if item_container.resource == ItemContainerResources.LOOT_STASH:
                inside_canvas_group = true

            if item_slots.size() - 1 < item_index:
                continue

            reference_slot = item_slots[item_index]


            if not is_instance_valid(reference_slot):
                continue

            reference_slot.update(item, inside_canvas_group)











func get_inventory_slot_nodes() -> Array[ItemSlot]:
    var inventory_slot_nodes: Array[ItemSlot] = []

    for child in inventory_contents_container.get_children():
        if child is ItemSlot:
            inventory_slot_nodes.push_back(child)

    return inventory_slot_nodes




func play_impact(type: StatResource, idx: int) -> void :
    var enemy_container: EnemyContainer = room_screen.get_enemy_container(idx)
    if not is_instance_valid(enemy_container):
        return

    vfx_manager.create_impact_effect(type, enemy_container)



func create_item_received_popup(item: Item, sender_name: String = ""):
    var pos: Vector2 = room_screen.get_global_rect().get_center() - Vector2(0, 125)
    popup_manager.create_item_received_popup(item, pos, sender_name)




func create_popup_label(popup_label_data: PopupLabelData, wait_time: float = 0.0):
    var pos: Vector2 = room_screen.get_global_rect().get_center() - Vector2(0, 25)
    popup_label_data.position = pos

    popup_manager.create_popup_label(popup_label_data, wait_time)


func _on_visibility_changed() -> void :
    loot_stash_popup_container.hide()
