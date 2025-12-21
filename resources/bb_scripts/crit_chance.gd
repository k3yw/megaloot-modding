extends BBScript







func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    var battle_action_bb = BattleActions.get_bb_container_data(BattleActions.CRITICAL_STRIKE)
    if args[0] == Stats.OMNI_CRIT_CHANCE:
        battle_action_bb = BattleActions.get_bb_container_data(BattleActions.OMNI_CRIT)

    bb_container_data.push_back(BBContainerData.new("Chance to "))
    bb_container_data.push_back(battle_action_bb)


    return bb_container_data
