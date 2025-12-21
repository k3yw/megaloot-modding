extends RoomProcessor




func initialize() -> void :
    action_container = action_container as MerchantActionContainer

    action_container.leave_button.pressed.connect( func():
        if memory.local_player.left_room:
            return

        if action_container.leave_button.is_pressed:
            MultiplayerManager.leave_room()
        )

    action_container.refresh_button.pressed.connect( func():
        gameplay_state.market_manager.try_to_refresh_merchant()
        )

    action_container.refresh_button.hover_info_module.cost_type = Stats.DIAMOND
    action_container.refresh_button.hover_info_module.cost = 1




func process_action_panel() -> void :
    action_container = action_container as MerchantActionContainer

    action_container.refresh_button.disabled = true
    action_container.has_enough_diamonds = false
    action_container.tinker_container.hide()
    action_container.market_container.show()


    if not is_instance_valid(ItemManager.dragged_item_slot):
        return

    if not is_instance_valid(ItemManager.dragged_item_slot.item_container):
        return

    if ItemManager.dragged_item_slot.item_container.resource == ItemContainerResources.MARKET:
        return

    if memory.all_players_left_room():
        return

    if memory.local_player.diamonds > 0:
        action_container.refresh_button.disabled = false

    if memory.local_player.merchant_level == 0:
        return

    var dragged_item: Item = ItemManager.dragged_item_slot.get_item()
    if not is_instance_valid(dragged_item):
        return

    var price: Price = dragged_item.get_tinker_price()
    action_container.has_enough_diamonds = character_manager.can_pay(price)

    var tinker_text: String = T.get_translated_string("upgrade")

    if not dragged_item.can_upgrade():
        if not dragged_item.can_convert_into_tinker_kit():
            return

        tinker_text = T.get_translated_string("convert")


    action_container.tinker_label.text = tinker_text.to_upper()
    action_container.price_label.text = Format.number(price.amount)
    action_container.tinker_container.show()
    action_container.market_container.hide()




func _process(delta: float) -> void :
    action_container = action_container as MerchantActionContainer
    super._process(delta)
    process_action_panel()

    action_container.leave_button.disabled = memory.local_player.left_room
