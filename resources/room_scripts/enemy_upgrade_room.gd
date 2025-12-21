extends RoomProcessor




func _process(delta: float) -> void :
    action_container = action_container as EnemyUpgradeActionContainer
    super._process(delta)

    if not memory.local_player.team == memory.get_team_in_battle():
        action_container.hide()
        return

    var max_enemy_upgrades: int = Balance.get_max_enemy_upgrade(memory.floor_number)
    action_container.upgrade_limit_label.text = str(memory.local_player.enemy_upgrades_this_room)
    action_container.upgrade_limit_label.text += "/"
    action_container.upgrade_limit_label.text += str(max_enemy_upgrades)


    var item_for_upgrade: Item = memory.local_player.enemy_upgrade.items[0]
    action_container.upgrade_enemy_button.disabled = not is_instance_valid(item_for_upgrade)
    if is_instance_valid(item_for_upgrade) and action_container.upgrade_enemy_button.is_pressed:
        var item_data: Dictionary = SaveSystem.get_data(item_for_upgrade)
        MultiplayerManager.upgrade_enemy(-1, item_data, memory.battle.selected_enemy_idx)
        if memory.local_player.enemy_upgrades_this_room >= max_enemy_upgrades:
            MultiplayerManager.leave_room()
        return


    if action_container.leave_button.is_pressed:
        MultiplayerManager.leave_room()

    if memory.local_player.left_room:
        action_container.hide()
