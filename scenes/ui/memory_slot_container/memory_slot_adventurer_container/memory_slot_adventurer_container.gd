class_name MemorySlotAdventurerContainer extends MarginContainer




@export var adventurer_portrait: AdventurerPortrait
@export var item_container: HBoxContainer

@export var gold_coins_label: GenericLabel







func set_player(player: Player) -> void :
    for child in item_container.get_children():
        item_container.remove_child(child)
        child.queue_free()


    adventurer_portrait.set_adventurer(player.adventurer)

    if player.is_phantom:
        adventurer_portrait.set_as_phantom()

    if player.died:
        adventurer_portrait.close_eyes()


    if player.profile_id == UserData.profile.id:
        adventurer_portrait.set_border(UserData.profile.get_floor_record(player.adventurer))
        UserData.profile.get_floor_record(player.adventurer)


    for item in player.equipment.items:
        if not is_instance_valid(item):
            continue

        var item_texture_rect: ItemTextureRect = preload("res://scenes/ui/item_texture_rect/item_texture_rect.tscn").instantiate()
        var item_texture_rect_data = ItemTextureRectData.new()
        item_texture_rect_data.item = item
        item_container.add_child(item_texture_rect)
        item_texture_rect.apply_data(item_texture_rect_data)
        item_texture_rect.outline_enabled = false



    gold_coins_label.target_value = player.gold_coins
