extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("At the end of the turn, conume 1 stack and ", Color.DARK_GRAY))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CLEANSE))

    return bb_container_data
