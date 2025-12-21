extends RoomProcessor




func initialize() -> void :
    action_container = action_container as MysticTraderActionContainer
    gameplay_state.market_manager.refresh_market(ItemContainerResources.MYSTIC_TRADER)

    action_container.leave_button.pressed.connect( func():
        if memory.local_player.left_room:
            return

        if action_container.leave_button.is_pressed:
            MultiplayerManager.leave_room()
        )

    action_container.refresh_button.pressed.connect( func():
        gameplay_state.market_manager.try_to_refresh_mystic_trader()
        )

    action_container.refresh_button.hover_info_module.cost_type = Stats.DIAMOND
    action_container.refresh_button.hover_info_module.cost = 1





func _process(delta: float) -> void :
    action_container = action_container as MysticTraderActionContainer
    super._process(delta)

    action_container.refresh_button.disabled = memory.local_player.diamonds == 0
    action_container.leave_button.disabled = memory.local_player.left_room
