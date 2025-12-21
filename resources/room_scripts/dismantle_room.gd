extends RoomProcessor





func _process(delta: float) -> void :
    action_container = action_container as DismantleActionContainer
    super._process(delta)

    action_container.leave_button.disabled = true
    action_container.dismantle_button.disabled = false
    action_container.request_to_dismantle_button.hide()
    action_container.dismantle_action_container.show()
    action_container.dismantle_item_slot.show()

    var item_to_dismantle: Item = memory.dismantle.items[0]

    if not memory.partners.is_empty():
        action_container.request_to_dismantle_button.text = T.get_translated_string("Request To Dismantle").to_upper()


        if not memory.dismantling_player_id == memory.local_player.profile_id:
            action_container.request_to_dismantle_button.show()
            action_container.dismantle_action_container.hide()
            action_container.dismantle_item_slot.hide()

            if memory.dismantling_player_id.is_empty():
                if action_container.request_to_dismantle_button.is_pressed:
                    MultiplayerManager.send_request_to_dismantle(Lobby.get_client_id())
                action_container.request_to_dismantle_button.disabled = false
                return

            action_container.request_to_dismantle_button.text = T.get_translated_string("Waiting To Dismantle").to_upper()
            action_container.request_to_dismantle_button.disabled = true
            return



    action_container.dismantle_button.hover_info_module.bb_container_data_arr.clear()
    if not is_instance_valid(item_to_dismantle):
        action_container.leave_button.disabled = false
        action_container.dismantle_button.disabled = true

        if action_container.leave_button.is_pressed:
            MultiplayerManager.send_skip_dismantle(true)
        return



    var stats_to_dismantle: Array[BonusStat] = item_to_dismantle.get_stats_to_dismantle()
    action_container.dismantle_button.hover_info_module.hover_info_name = T.get_translated_string("dismantle", "Button")
    action_container.dismantle_button.hover_info_module.cost = memory.get_dismantle_price()
    action_container.dismantle_button.hover_info_module.cost_type = Stats.DIAMOND
    if stats_to_dismantle.size() > 0:
        for bonus_stat in stats_to_dismantle:
            action_container.dismantle_button.hover_info_module.bb_container_data_arr += Info.from_stat(memory.local_player, bonus_stat, [])



    var can_dismantle: bool = memory.local_player.diamonds >= memory.get_dismantle_price()
    if item_to_dismantle.get_stats_to_dismantle().is_empty():
        can_dismantle = false

    if not can_dismantle:
        action_container.dismantle_button.disabled = true
        return

    if action_container.dismantle_button.is_pressed:
        character_manager.pay(Price.new(Stats.DIAMOND, memory.get_dismantle_price()), false)
        gameplay_state.dismantle_item(item_to_dismantle)
